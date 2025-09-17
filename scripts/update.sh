#!/bin/bash
set -eEuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
source "${ROOT_DIR}"/scripts/utils.sh

check_requirements

select_node_type

select_network

set_deployment_dir

set_env_file

if ! [ -d "${DEPLOYMENT_DIR}" ]; then
  fn_die "\nDeployment directory does not exist, you may need to run 'init.sh' script first.. Exiting...\n"
fi

backup_dir=${DEPLOYMENT_DIR}_BK_$(date +%Y%m%d%H%M%S)
log_warn "\nBacking up deployment directory in ${backup_dir}"
cp -r "${DEPLOYMENT_DIR}" "${backup_dir}" || fn_die "\nError: could not backup deployment directory. Fix it before proceeding any further. Exiting...\n"
cp "${ROOT_DIR}/compose_files/docker-compose-${NODE_TYPE}.yml" "${DEPLOYMENT_DIR}/docker-compose.yml"
chmod 0600 "${ENV_FILE}"

# Define the auto update variables
auto_update_vars=(
  "NODE_VERSION"
  "ZKV_CONF_RPC_EXTERNAL"
  "ZKV_CONF_VALIDATOR"
)

conditional_update_vars=()

optional_do_not_remove_vars=(
  "ZKV_CONF_RPC_MAX_CONNECTIONS"
  "ZKV_CONF_RPC_MAX_BATCH_REQUEST_LEN"
  "ZKV_CONF_POOL_LIMIT"
  "ZKV_CONF_POOL_KBYTES"
)

# Read the .env.template file line by line, skip blank lines and comments, store each of the other lines in an array
log_info "\n=== Reading ${ENV_FILE_TEMPLATE} file"
while IFS= read -r line; do
  [ -z "${line}" ] && continue
  [ "${line:0:1}" = "#" ] && continue
  env_template_lines+=("${line}")
done <"${ENV_FILE_TEMPLATE}"

# Remove variables from ENV_FILE that no longer exist in the template
log_info "\n=== Removing obsolete variables from ${ENV_FILE} that are no longer in the template..."

# Get all var names from the template
template_var_names=()
for line in "${env_template_lines[@]}"; do
  var_name="$(cut -d'=' -f1 <<< "${line}")"
  template_var_names+=("${var_name}")
done

# Read all variable lines from current .env
while IFS= read -r line; do
  [[ -z "${line}" || "${line:0:1}" == "#" ]] && continue
  env_var_name="$(cut -d'=' -f1 <<< "${line}")"

  # Skip vars that are in the do-not-remove list
  if printf '%s\n' "${optional_do_not_remove_vars[@]}" | grep -q -P "^${env_var_name}$"; then
    log_info "\n========================"
    log_blue "Preserving optional variable '${env_var_name}'"
    log_info "========================\n"
    continue
  fi

  # Remove vars not in template
  if ! printf '%s\n' "${template_var_names[@]}" | grep -q -P "^${env_var_name}$"; then
    log_info "\n========================"
    log_warn "Removing obsolete variable '${env_var_name}' from ${ENV_FILE}"
    log_info "\n========================"
    sed -i "/^${env_var_name}=.*/d" "${ENV_FILE}"
  fi
done < <(grep -v '^#' "${ENV_FILE}")

# Append new env vars to .env file
log_info "\n=== Appending new env vars to ${ENV_FILE} file"
for line in "${env_template_lines[@]}"; do
  var_name="$(cut -d'=' -f1 <<< "${line}")"
  if ! grep -q "^${var_name}=" "${ENV_FILE}"; then
    echo -e "\n${line}" >>"${ENV_FILE}"
  fi
done

# Update the values of the auto update variables
log_info "\n=== Updating the values of the auto update variables..."
for line in "${env_template_lines[@]}"; do
  var_name="$(cut -d'=' -f1 <<< "${line}")"
  for item in "${auto_update_vars[@]}"; do
    if [[ "${item}" == "${var_name}" ]]; then
      sed -i "/^${var_name}=/c\\${line}" "${ENV_FILE}"
      break
    fi
  done
done

# Update the values of the conditional update variables if approved by the user
log_info "\n=== Updating the values of the conditional update variables..."
for line in "${env_template_lines[@]}"; do
  var_name="$(cut -d'=' -f1 <<< "${line}")"
  if ! [ ${#conditional_update_vars[@]} -eq 0 ]; then
    for item in "${conditional_update_vars[@]}"; do
      if [[ "${item}" == "${var_name}" ]]; then
        if ! grep -q "^${line}" "${ENV_FILE}"; then
          log_debug "\nThe value of ${var_name} in the ${ENV_FILE} file is different from the value in the ${ENV_FILE_TEMPLATE} file."
          log_debug "${ENV_FILE} value: \033[1m$(grep "^${var_name}=" "${ENV_FILE}")\033[0m"
          log_debug "${ENV_FILE_TEMPLATE} value: \033[1m${line}\033[0m\n"
          var_value="$(cut -d'=' -f2- <<< "${line}")"
          answer="$(selection_yn "Update '${var_name}' in ${ENV_FILE} to '${var_value}' from the template?")"
          if [ "${answer}" = "yes" ]; then
            sed -i "/^${var_name}=/c\\${line}" "${ENV_FILE}"
          fi
        fi
        break
      fi
    done
  fi
done

log_info "\n=== ${ENV_FILE} update completed successfully"

log_info "\n=== Please review the changes in the ${ENV_FILE} file, if there is anything wrong you can restore from the backup ${backup_dir}"

log_info "\n=== Project has been updated correctly for ${NODE_TYPE} on ${NETWORK}"
log_info "\n=== Start the compose project with the following command: "
log_info "\n========================"
log_warn "docker compose -f ${DEPLOYMENT_DIR}/docker-compose.yml up -d --pull=always --force-recreate"
log_info "========================\n"

exit 0
