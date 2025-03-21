#!/bin/bash
set -eEuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
source "${ROOT_DIR}"/scripts/utils.sh

check_requirements

select_node_type

select_network

set_deployment_dir

if ! [ -d "${DEPLOYMENT_DIR}" ]; then
  fn_die "\nDeployment directory does not exist. Exiting...\n"
fi

log_red "\n***Re-genesis operation will erase the node's Docker volumes and restart the node from scratch***"

if [[ "${NODE_TYPE}" =~ ^(boot|validator)-node$ ]]; then
  log_red "\n***Make sure 'node_key' file/value generated during initial deployment was saved IN A SAFE PLACE and can be retrieved***"
fi

if [[ "${NODE_TYPE}" == "validator-node" ]]; then
  log_red "\n***Make sure 'secret_phrase' file/value generated during initial deployment was saved IN A SAFE PLACE and can be retrieved***"
fi

log_red "\n**************************************************"
log_red "🚨🚨🚨 THE NEXT STEP WILL DESTROY THE DOCKER ENVIRONMENT INCLUDING NODE VOLUME DATA 🚨🚨🚨"
log_red "**************************************************\n"

confirm_delete="$(selection_yn "\nDo you want to proceed?")"
if [ "${confirm_delete}" = "no" ]; then
  fn_die "Aborting ...\n"
fi

containers="$(docker compose -f "${DEPLOYMENT_DIR}"/docker-compose.yml ps -a -q)" || fn_die "\nError: could not identify existing containers to stop. Exiting...\n"
if [ -n "${containers}" ]; then
  log_info "\n=== Stopping the project..."
  docker compose -f "${DEPLOYMENT_DIR}"/docker-compose.yml down
  log_info "\n=== Project has been stopped successfully."
fi

log_info "\n=== Removing Docker volumes..."
docker compose -f "${DEPLOYMENT_DIR}"/docker-compose.yml down --volumes

backup_dir=${DEPLOYMENT_DIR}_BK_$(date +%Y%m%d%H%M%S)
log_warn "\nBacking up current deployment directory in ${backup_dir} for the reference\n"
cp -r "${DEPLOYMENT_DIR}" "${backup_dir}" || fn_die "\nError: could not backup deployment directory. Fix it before proceeding any further. Exiting...\n"
rm -rf "${DEPLOYMENT_DIR?}" || fn_die "\nError: could not remove deployment directory. Fix it before proceeding any further. Exiting...\n"

log_info "\n**************************************************"
log_info "✅ The node has been reset and will be configured from scratch ✅"
log_info "**************************************************\n"

"${ROOT_DIR}/scripts/init.sh"

log_info "\n=== Re-genesis has been performed successfully."

exit 0
