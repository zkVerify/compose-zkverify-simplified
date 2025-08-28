#!/bin/bash

log() {
  # Usage: log style color "message"
  # style: bold, italic, normal, light
  # color: black, red, green
  # Example: log bold red "Error: Something went wrong"

  # styles
  # shellcheck disable=SC2034
  local normal=0
  local bold=1
  # shellcheck disable=SC2034
  local shadow=2
  # shellcheck disable=SC2034
  local italic=3
  # colors
  # shellcheck disable=SC2034
  local black=30
  local red=31
  # shellcheck disable=SC2034
  local green=32
  # shellcheck disable=SC2034
  local yellow=33

  local usage="Usage: ${FUNCNAME[0]} style color \"message\"\nStyles: bold, italic, normal, light\nColors: black, red, green, yellow\nExample: log bold red \"Error: Something went wrong\""
  [ "$#" -lt 3 ] && {
    echo -e "\033[${bold};${red}m${FUNCNAME[0]} error: function requires three arguments.\n${usage}\033[0m"
    exit 1
  }
  # vars
  local style="${1}"
  local color="${2}"
  local message="${3}"
  # validate style is in bold, italic, normal, shadow
  if [[ ! "${style}" =~ ^(bold|italic|normal|shadow)$ ]]; then
    message="Error: Invalid style. Must be one of normal, bold, italic, shadow."
    echo -e "\033[${bold};${red}m${message}\033[0m"
    exit 1
  fi
  # validate color is in black, red, green
  if [[ ! "${color}" =~ ^(black|red|green|yellow)$ ]]; then
    message="Error: Invalid color. Must be one of black, red, green or yellow."
    echo -e "\033[${bold};${red}m${message}\033[0m"
    exit 1
  fi
  echo -e "\033[${!style};${!color}m${message}\033[0m"
}

log_info() {
  local usage="Log a message in bold green - Usage: ${FUNCNAME[0]} {message}"
  [ "${1:-}" = "usage" ] && log_debug "${usage}" && return
  [ "$#" -ne 1 ] && fn_die "\n${FUNCNAME[0]} error: function requires exactly one argument.\n\n${usage}"
  log bold green "${1}" >&2
}

log_debug() {
  local usage="Log a message in normal green - Usage: ${FUNCNAME[0]} {message}"
  [ "${1:-}" = "usage" ] && log_debug "${usage}" && return
  [ "$#" -ne 1 ] && fn_die "\n${FUNCNAME[0]} error: function requires exactly one argument.\n\n${usage}"
  log normal green "${1}" >&2
}

log_warn() {
  local usage="Log a message in normal yellow - Usage: ${FUNCNAME[0]} {message}"
  [ "${1:-}" = "usage" ] && log_debug "${usage}" && return
  [ "$#" -ne 1 ] && fn_die "\n${FUNCNAME[0]} error: function requires exactly one argument.\n\n${usage}"
  log normal yellow "${1}" >&2
}

log_red() {
  local usage="Log a message in bold red - Usage: ${FUNCNAME[0]} {message}"
  [ "${1:-}" = "usage" ] && log_debug "${usage}" && return
  [ "$#" -ne 1 ] && fn_die "\n${FUNCNAME[0]} error: function requires exactly one argument.\n\n${usage}"
  log bold red "${1}" >&2
}

fn_die() {
  log_red "${1}" >&2
  exit "${2:-1}"
}

selection() {
  local usage="Use select method for multi choice interaction with user - usage: ${FUNCNAME[0]} {string_to_be_used}"
  [ "${1:-}" = "usage" ] && log_debug "${usage}" && return
  [ "$#" -ne 1 ] && fn_die "\n${FUNCNAME[0]} error: function requires exactly one argument.\n\n${usage}"

  local select_from_string="${1:-}"
  local user_exit_err_code=234

  select item in ${select_from_string} "quit"; do
    case "${item}" in
    "quit")
      fn_die "Exiting" "${user_exit_err_code}"
      ;;
    "")
      log_warn "\nInvalid selection. Please type the number of the option you want to use."
      ;;
    *)
      log_info "\nYou have selected: ${item}"
      echo "${item}"
      break
      ;;
    esac
  done
}

selection_yn() {
  local usage="Request user input - usage: ${FUNCNAME[0]} {message}"
  [ "${1:-}" = "usage" ] && log_debug "${usage}" && return
  [ "$#" -ne 1 ] && fn_die "\n${FUNCNAME[0]} error: function requires exactly one argument.\n\n${usage}"

  local message="${1}"
  local user_exit_err_code=234

  log_warn "${message}"
  response="$(selection "yes no")"
  if [[ ! "${response}" =~ ^(yes|no)$ ]]; then
    exit "${user_exit_err_code}"
  fi
  echo "${response}"
}

verify_required_commands() {

  command -v jq &>/dev/null || fn_die "${FUNCNAME[0]} Error: 'jq' is required to run this script, see installation instructions at 'https://jqlang.github.io/jq/download/'."

  command -v docker &>/dev/null || fn_die "${FUNCNAME[0]} Error: 'docker' is required to run this script, see installation instructions at 'https://docs.docker.com/engine/install/'."

  (docker compose version 2>&1 | grep -q v2) || fn_die "${FUNCNAME[0]} Error: 'docker compose' is required to run this script, see installation instructions at 'https://docs.docker.com/compose/install/'."

  if [ "$(uname)" = "Darwin" ]; then
    command -v gsed &>/dev/null || fn_die "${FUNCNAME[0]} Error: 'gnu-sed' is required to run this script in MacOS environment, see installation instructions at 'https://formulae.brew.sh/formula/gnu-sed'. Make sure to add it to your PATH."
  fi
}

check_requirements() {
  log_info "\n=== Checking all the requirements"
  # Making sure the script is not being run as root
  LOCAL_USER_ID="$(id -u)"
  LOCAL_GROUP_ID="$(id -g)"
  if [ "${LOCAL_USER_ID}" == 0 ] || [ "${LOCAL_GROUP_ID}" == 0 ]; then
    fn_die "\nError: This script should not be run as root. Exiting...\n"
  fi

  verify_required_commands

  docker info >/dev/null 2>&1 || fn_die "${FUNCNAME[0]} Error: 'docker daemon' is not running, start it before running this script."
}

check_env_var() {
  local usage="Check if required environmental variable is empty and produce an error - usage: ${FUNCNAME[0]} {env_var_name}"
  [ "${1:-}" = "usage" ] && echo "${usage}" && return
  [ "$#" -ne 1 ] && {
    fn_die "${FUNCNAME[0]} error: function requires exactly one argument.\n\n${usage}"
  }

  local var="${1}"
  if [ -z "${!var:-}" ]; then
    fn_die "Error: Environment variable ${var} is required. Exiting ..."
  fi
}

check_required_variables() {
  TO_CHECK=(
    "COMPOSE_PROJECT_NAME"
    "NODE_VERSION"
    "NODE_ROLE"
    "NODE_NET_P2P_PORT"
    "ZKV_CONF_NAME"
    "ZKV_CONF_BASE_PATH"
    "ZKV_CONF_CHAIN"
  )

  if [ "${NODE_TYPE}" = "boot-node" ]; then
    TO_CHECK+=(
      "INTERNAL_NETWORK_SUBNET"
      "ACME_VHOST"
      "ACME_DEFAULT_EMAIL"
      "ACME_CHALLENGE_TYPE"
      "NGINX_NET_IP_ADDRESS"
      "NODE_NET_IP_ADDRESS"
      "NODE_NET_P2P_PORT_WS"
      "ZKV_CONF_LISTEN_ADDR"
      "ZKV_NODE_KEY"
    )
    
    # Only check DNS configuration if DNS-01 challenge is selected
    if [ "${ACME_CHALLENGE_TYPE:-}" = "DNS-01" ]; then
      TO_CHECK+=(
        "ACMESH_DNS_API_CONFIG"
      )
    fi
  fi

  if [ "${NODE_TYPE}" = "validator-node" ]; then
    TO_CHECK+=(
      "ZKV_CONF_VALIDATOR"
      "ZKV_NODE_KEY"
      "ZKV_SECRET_PHRASE"
    )
  fi

  if [ "${NODE_TYPE}" = "rpc-node" ]; then
    TO_CHECK+=(
      "NODE_NET_RPC_PORT"
      "ZKV_CONF_RPC_CORS"
      "ZKV_CONF_RPC_EXTERNAL"
      "ZKV_CONF_RPC_METHODS"
      "ZKV_CONF_PRUNING"
    )
  fi

  for var in "${TO_CHECK[@]}"; do
    check_env_var "${var}"
  done
}

select_node_type() {
  log_warn "\nSelect 'node type' to proceed with the operation: "
  node_types="rpc-node validator-node boot-node"
  NODE_TYPE="$(selection "${node_types}")"
  export NODE_TYPE
}

select_network() {
  log_warn "\nWhat 'network' would you like to use: "
  NETWORKS="testnet"
  NETWORK="$(selection "${NETWORKS}")"
  export NETWORK
}

set_deployment_dir() {
  DEPLOYMENT_DIR="${ROOT_DIR}/deployments/${NODE_TYPE}/${NETWORK}"
  export DEPLOYMENT_DIR
}

set_env_file() {
  ENV_FILE_TEMPLATE="${ROOT_DIR}/env/.env.${NODE_TYPE}.${NETWORK}.template"
  ENV_FILE="${DEPLOYMENT_DIR}/.env"
  export ENV_FILE_TEMPLATE
  export ENV_FILE
}

create_node_key() {
  node_key_provided="false"
  use_existing_node_key_answer="$(selection_yn "\nDo you want to import an already existing node key?")"
  if [ "${use_existing_node_key_answer}" = "yes" ]; then
    log_warn "\nPlease type or paste now the node key you want to import: "
    read -rp "#? " node_key
    set_existing_node_key_answer="$(selection_yn "\nDo you confirm this is the node key you want to import: ${node_key}?")"
    if [ "${set_existing_node_key_answer}" = "no" ]; then
      fn_die "Node key import aborted; please run again the init.sh script. Exiting ...\n"
    fi
    node_key_provided="true"
  else
    if ! node_key="$(docker run --rm --entrypoint zkv-relay horizenlabs/zkverify:"${NODE_VERSION}" key generate-node-key)"; then
      fn_die "\nError: could not generate node key. Fix it before proceeding any further. Exiting...\n"
    fi
  fi
  if [ -z "${node_key}" ]; then
    fn_die "\nError: node key is empty. Fix it before proceeding any further. Exiting...\n"
  fi
  sed -i "s/ZKV_NODE_KEY=.*/ZKV_NODE_KEY=\"${node_key}\"/g" "${ENV_FILE}" || fn_die "\nError: could not set name 'ZKV_NODE_KEY' variable in ${ENV_FILE} file. Fix it before proceeding any further. Exiting...\n"
  if [ "${node_key_provided}" != "true" ]; then
    printf "%s" "${node_key}" > "${DEPLOYMENT_DIR}/configs/node/secrets/node_key.dat"
    chmod 0400 "${DEPLOYMENT_DIR}/configs/node/secrets/node_key.dat"
    log_info "\nFile ${DEPLOYMENT_DIR}/configs/node/secrets/node_key.dat was created."
    log_red "\n***STORE A COPY OF THE FILE IN A SAFE PLACE. ONCE STORED THE FILE CAN BE DELETED. IT IS REQUIRED TO RECOVER (IF NEEDED) THE NODE***"
  fi
}

create_secret_phrase() {
  use_existing_secret_phrase_answer="$(selection_yn "\nDo you want to import an already existing secret phrase?")"
  if [ "${use_existing_secret_phrase_answer}" = "yes" ]; then
    log_warn "\nPlease type or paste now the secret phrase you want to import: "
    read -rp "#? " secret_phrase
    set_existing_secret_phrase_answer="$(selection_yn "\nDo you confirm this is the secret phrase you want to import: ${secret_phrase}?")"
    if [ "${set_existing_secret_phrase_answer}" = "no" ]; then
      fn_die "Secret phrase import aborted; please run again the init.sh script. Exiting ...\n"
    fi
  else
    if ! secret_json="$(docker run --rm --entrypoint zkv-relay horizenlabs/zkverify:"${NODE_VERSION}" key generate --output-type json)"; then
      fn_die "\nError: could not generate secret phrase. Fix it before proceeding any further. Exiting...\n"
    fi
    if [ -z "${secret_json}" ]; then
      fn_die "\nError: secret json is empty. Fix it before proceeding any further. Exiting...\n"
    fi
    printf "%s" "${secret_json}" > "${DEPLOYMENT_DIR}/configs/node/secrets/secret.json"
    chmod 0400 "${DEPLOYMENT_DIR}/configs/node/secrets/secret.json"
    log_info "\nFile ${DEPLOYMENT_DIR}/configs/node/secrets/secret.json was created."
    log_red "\n***STORE A COPY OF THE FILE IN A SAFE PLACE. ONCE STORED THE FILE CAN BE DELETED. IT IS REQUIRED TO RECOVER (IF NEEDED) THE NODE***"
    sleep 2
    secret_phrase="$(jq -r '.secretPhrase' "${DEPLOYMENT_DIR}/configs/node/secrets/secret.json")"
  fi
  if [ -z "${secret_phrase}" ]; then
    fn_die "\nError: secret phrase is empty. Fix it before proceeding any further. Exiting...\n"
  fi
  sed -i "s/ZKV_SECRET_PHRASE=.*/ZKV_SECRET_PHRASE=\"${secret_phrase}\"/g" "${ENV_FILE}" || fn_die "\nError: could not set name 'ZKV_SECRET_PHRASE' variable in ${ENV_FILE} file. Fix it before proceeding any further. Exiting...\n"
  sleep 2
}

set_up_node_name_env_var() {
  custom_node_name_answer="$(selection_yn "\nDo you want to choose a custom node name? (defaults to 'ext-${NODE_TYPE}-<random_number>')")"
  if [ "${custom_node_name_answer}" = "no" ]; then
    log_debug "\nSetting node name dynamically"
    node_name="ext-${NODE_TYPE}-$((RANDOM % 100000 + 1))" || fn_die "\nError: could not set name variable for some reason. Fix it before proceeding any further. Exiting...\n"
  else
    log_warn "\nPlease provide the node name you want to use: "
    read -rp "#? " node_name
    while [ -z "${node_name}" ]; do
      log_warn "\nNode name cannot be empty. Try again..."
      read -rp "#? " node_name
    done
  fi
  sed -i "s/ZKV_CONF_NAME=.*/ZKV_CONF_NAME=${node_name}/g" "${ENV_FILE}" || fn_die "\nError: could not set name variable in ${ENV_FILE} file. Fix it before proceeding any further. Exiting...\n"
}

set_up_rpc_methods_env_var() {
  rpc_methods_answer="$(selection_yn "\nDo you want to set custom rpc methods? (defaults to 'safe')")"
  if [ "${rpc_methods_answer}" = "yes" ]; then
    log_warn "\nPlease select the rpc methods you want to use: "
    rpc_methods="$(selection "safe unsafe auto")"
    sed -i "s/ZKV_CONF_RPC_METHODS=.*/ZKV_CONF_RPC_METHODS=${rpc_methods}/g" "${ENV_FILE}" || fn_die "\nError: could not set rpc methods variable in ${ENV_FILE} file. Fix it before proceeding any further. Exiting...\n"
  fi
}

set_up_pruning_env_var() {
  pruning_answer="$(selection_yn "\nDo you want to run an rpc archival node (this will keep a local copy of all blocks, enabling full historical data access)?")"
  if [ "${pruning_answer}" = "no" ]; then
    log_warn "\nPlease specify how many blocks to keep: "
    read -rp "#? " pruning_value
    while [ -z "${pruning_value}" ]; do
      log_warn "\nPruning value cannot be empty. Try again..."
      read -rp "#? " pruning_value
    done
    sed -i "s/ZKV_CONF_PRUNING=.*/ZKV_CONF_PRUNING=${pruning_value}/g" "${ENV_FILE}" || fn_die "\nError: could not set pruning configuration variable in ${ENV_FILE} file. Fix it before proceeding any further. Exiting...\n"
  fi
}

set_up_rpc_max_batch_request_len() {
  max_batch_request_len_answer="$(selection_yn "\nDo you want to set a limit for the max length per RPC batch request")"
  if [ "${max_batch_request_len_answer}" = "yes" ]; then
    log_warn "\nPlease specify the maximum number of requests allowed in a single RPC batch (must be a whole number): "
    read -rp "#? " max_batch_request_len_value
    while [ -z "${max_batch_request_len_value}" ]; do
      log_warn "\nMaximum number of requests allowed in a single RPC batch value cannot be empty. Try again..."
      read -rp "#? " max_batch_request_len_value
    done
    echo "ZKV_CONF_RPC_MAX_BATCH_REQUEST_LEN=${max_batch_request_len_value}" >> "${ENV_FILE}" || fn_die "\nError: could not set a limit for the max length per RPC batch request variable in ${ENV_FILE} file. Fix it before proceeding any further. Exiting...\n"
  fi
}

# Function to set and check if the FQDN is valid
set_acme_vhost() {
  while true; do
    log_warn "\nPlease type or paste a valid FQDN value for Let's Encrypt to use for 'p2p/wss' support setup.\nIt has to satisfy the following requirements: https://github.com/nginx-proxy/acme-companion/blob/904b5e38b17183c7c40e194869faad08b09fa9dc/README.md#http-01-challenge-requirements"
    read -rp "#? " fqdn

    # Check if the input is empty
    if [ -z "${fqdn}" ]; then
      log_warn "\nFQDN value cannot be empty. Try again..."
      continue
    fi

    # Check if the FQDN matches the regex pattern
    if [[ "${fqdn}" =~ ^([a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$ ]]; then
      # Ask for confirmation
      nginx_value_confirm="$(selection_yn "\nDo you confirm this is the FQDN value you want to use: ${fqdn}?")"
      if [ "${nginx_value_confirm}" = "yes" ]; then
        # If the user confirms, break the loop and return success
        sed -i "s/ACME_VHOST=.*/ACME_VHOST=${fqdn}/g" "${ENV_FILE}" || fn_die "\nError: could not set 'ACME_VHOST' variable value in ${ENV_FILE} file. Fix it before proceeding any further. Exiting...\n"
        return 0
      else
        # If the user says no, ask for input again
        log_warn "\nYou chose not to use this FQDN. Please enter a new one..."
        continue
      fi
    else
      # Invalid FQDN
      log_red "\nInvalid FQDN: ${fqdn}. Please try again..."
    fi
  done
}

# Function to set and check if the email address is valid
set_acme_email_address() {
  while true; do
    log_warn "\nPlease type or paste a valid email address that will be used by Let's Encrypt to warn you of impending certificate expiration (should the automated renewal fail) and to recover your account:"
    read -rp "#? " email

    # Check if the input is empty
    if [ -z "${email}" ]; then
      log_warn "\nEmail address cannot be empty. Try again..."
      continue
    fi

    # Check if the email matches a simple regex pattern
    if [[ "${email}" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
      # Ask for confirmation
      email_confirm="$(selection_yn "\nDo you confirm this is the email address you want to use: ${email}?")"
      if [ "${email_confirm}" = "yes" ]; then
        # If the user confirms, save the email and break the loop
        sed -i "s/ACME_DEFAULT_EMAIL=.*/ACME_DEFAULT_EMAIL=${email}/g" "${ENV_FILE}" || fn_die "\nError: could not set 'ACME_DEFAULT_EMAIL' variable value in ${ENV_FILE} file. Fix it before proceeding any further. Exiting...\n"
        return 0
      else
        # If the user says no, ask for input again
        log_warn "\nYou chose not to use this email address. Please enter a new one..."
        continue
      fi
    else
      # Invalid email format
      log_red "\nInvalid email address: ${email}. Please try again..."
    fi
  done
}

# Function to select ACME challenge type
select_acme_challenge_type() {
  log_warn "\nSelect the ACME challenge type for Let's Encrypt certificate validation:"
  log_info "HTTP-01: Uses HTTP validation (requires port 80 accessible)"
  log_info "DNS-01: Uses DNS validation (requires DNS provider API access)"
  challenge_types="HTTP-01 DNS-01"
  ACME_CHALLENGE_TYPE="$(selection "${challenge_types}")"
  sed -i "s/ACME_CHALLENGE_TYPE=.*/ACME_CHALLENGE_TYPE=${ACME_CHALLENGE_TYPE}/g" "${ENV_FILE}" || fn_die "\nError: could not set 'ACME_CHALLENGE_TYPE' variable value in ${ENV_FILE} file. Fix it before proceeding any further. Exiting...\n"
  export ACME_CHALLENGE_TYPE
}

# Function to configure DNS provider for DNS-01 challenge
configure_dns_provider() {
  log_warn "\nSelect your DNS provider for DNS-01 challenge:"
  log_info "Common providers: Cloudflare, Route53, DigitalOcean, etc."
  log_info "For full list see: https://github.com/acmesh-official/acme.sh/wiki/dnsapi"
  
  # Common DNS providers with their acme.sh DNS API names
  dns_providers="dns_cf dns_aws dns_do dns_gd dns_he dns_ovh dns_linode dns_ns1 other"
  provider_names="Cloudflare Route53/AWS DigitalOcean GoDaddy Hurricane_Electric OVH Linode NS1 Other"
  
  log_warn "\nSelect your DNS provider:"
  for i in $(seq 1 $(echo ${provider_names} | wc -w)); do
    provider_display=$(echo ${provider_names} | cut -d' ' -f${i})
    provider_api=$(echo ${dns_providers} | cut -d' ' -f${i})
    echo "${i}) ${provider_display} (${provider_api})"
  done
  echo "$(echo ${provider_names} | wc -w | awk '{print $1+1}')) quit"
  
  read -rp "Enter selection: " selection_num
  
  if [ "${selection_num}" = "$(echo ${provider_names} | wc -w | awk '{print $1+1}')" ]; then
    fn_die "Exiting" 234
  fi
  
  if [ "${selection_num}" -lt 1 ] || [ "${selection_num}" -gt $(echo ${provider_names} | wc -w) ]; then
    log_warn "\nInvalid selection. Please try again."
    configure_dns_provider
    return
  fi
  
  DNS_API=$(echo ${dns_providers} | cut -d' ' -f${selection_num})
  provider_display=$(echo ${provider_names} | cut -d' ' -f${selection_num})
  
  if [ "${DNS_API}" = "other" ]; then
    log_warn "\nPlease enter the acme.sh DNS API name (e.g., dns_cf, dns_aws):"
    read -rp "#? " DNS_API
    while [ -z "${DNS_API}" ]; do
      log_warn "\nDNS API name cannot be empty. Try again..."
      read -rp "#? " DNS_API
    done
  fi
  
  log_info "\nYou selected: ${provider_display} (${DNS_API})"
  
  # Configure provider-specific credentials
  configure_dns_credentials "${DNS_API}"
}

# Function to configure DNS provider credentials
configure_dns_credentials() {
  local dns_api="${1}"
  local dns_config=""
  
  case "${dns_api}" in
    "dns_cf")
      log_info "\nConfiguring Cloudflare DNS API"
      log_warn "You can use either an API Key or API Token (Token is recommended)"
      log_warn "API Token: https://dash.cloudflare.com/profile/api-tokens"
      log_warn "API Key: https://dash.cloudflare.com/profile/api-tokens"
      
      auth_method="$(selection "API-Token API-Key")"
      
      if [ "${auth_method}" = "API-Token" ]; then
        log_warn "\nEnter your Cloudflare API Token:"
        log_warn "Make sure it has Zone:Edit and Zone:Read permissions for your domain"
        read -rp "#? " cf_token
        while [ -z "${cf_token}" ]; do
          log_warn "\nCloudflare API Token cannot be empty. Try again..."
          read -rp "#? " cf_token
        done
        dns_config="{\"DNS_API\": \"dns_cf\", \"CF_Token\": \"${cf_token}\"}"
      else
        log_warn "\nEnter your Cloudflare API Key:"
        read -rp "#? " cf_key
        while [ -z "${cf_key}" ]; do
          log_warn "\nCloudflare API Key cannot be empty. Try again..."
          read -rp "#? " cf_key
        done
        
        log_warn "\nEnter your Cloudflare Email:"
        read -rp "#? " cf_email
        while [ -z "${cf_email}" ]; do
          log_warn "\nCloudflare Email cannot be empty. Try again..."
          read -rp "#? " cf_email
        done
        dns_config="{\"DNS_API\": \"dns_cf\", \"CF_Key\": \"${cf_key}\", \"CF_Email\": \"${cf_email}\"}"
      fi
      ;;
      
    "dns_aws")
      log_info "\nConfiguring AWS Route53 DNS API"
      log_warn "You need your AWS Access Key ID and Secret Access Key"
      log_warn "Make sure your AWS credentials have Route53 permissions"
      
      log_warn "\nEnter your AWS Access Key ID:"
      read -rp "#? " aws_access_key_id
      while [ -z "${aws_access_key_id}" ]; do
        log_warn "\nAWS Access Key ID cannot be empty. Try again..."
        read -rp "#? " aws_access_key_id
      done
      
      log_warn "\nEnter your AWS Secret Access Key:"
      read -rp "#? " aws_secret_access_key
      while [ -z "${aws_secret_access_key}" ]; do
        log_warn "\nAWS Secret Access Key cannot be empty. Try again..."
        read -rp "#? " aws_secret_access_key
      done
      
      # Format as JSON for acme-companion
      dns_config="{\"DNS_API\": \"dns_aws\", \"AWS_ACCESS_KEY_ID\": \"${aws_access_key_id}\", \"AWS_SECRET_ACCESS_KEY\": \"${aws_secret_access_key}\"}"
      ;;
      
    "dns_do")
      log_info "\nConfiguring DigitalOcean DNS API"
      log_warn "You need your DigitalOcean API Token"
      log_warn "Get your API token from: https://cloud.digitalocean.com/account/api/tokens"
      
      log_warn "\nEnter your DigitalOcean API Token:"
      read -rp "#? " do_api_key
      while [ -z "${do_api_key}" ]; do
        log_warn "\nDigitalOcean API Token cannot be empty. Try again..."
        read -rp "#? " do_api_key
      done
      
      # Format as JSON for acme-companion
      dns_config="{\"DNS_API\": \"dns_do\", \"DO_API_KEY\": \"${do_api_key}\"}"
      ;;
      
    *)
      log_info "\nConfiguring ${dns_api} DNS API"
      log_warn "Please refer to the documentation for ${dns_api} at:"
      log_warn "https://github.com/acmesh-official/acme.sh/wiki/dnsapi"
      log_warn "\nFor most providers, you'll need API credentials."
      log_warn "Please format your configuration as JSON:"
      log_warn "Example: {\"DNS_API\": \"${dns_api}\", \"API_KEY\": \"your_key\", \"API_SECRET\": \"your_secret\"}"
      
      log_warn "\nEnter your DNS API configuration in JSON format:"
      read -rp "#? " custom_config
      while [ -z "${custom_config}" ]; do
        log_warn "\nDNS API configuration cannot be empty. Try again..."
        read -rp "#? " custom_config
      done
      dns_config="${custom_config}"
      ;;
  esac
  
  # Save DNS configuration to environment file
  # Escape quotes for the environment file
  escaped_config=$(echo "${dns_config}" | sed 's/"/\\"/g')
  sed -i "s/ACMESH_DNS_API_CONFIG=.*/ACMESH_DNS_API_CONFIG=\"${escaped_config}\"/g" "${ENV_FILE}" || fn_die "\nError: could not set 'ACMESH_DNS_API_CONFIG' variable value in ${ENV_FILE} file. Fix it before proceeding any further. Exiting...\n"
  
  log_info "\nDNS provider configuration saved successfully."
}
