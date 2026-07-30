# Compose zkVerify simplified

This repository contains all the necessary resources for deploying zkVerify nodes, including RPC, validator, and boot nodes.

## Project overview

There are three types of nodes that can be deployed:

1. rpc
2. validator
3. boot

All scripts in this repository prompt for selection of the **node type** and the **network** to deploy.

---

## Requirements

* docker
* docker compose (v2 or newer)
* jq
* gnu-sed for Darwin distribution

---

## Instructions

⚠️ **Please review the `OPTIONAL` steps before manually starting the project after running the `./scripts/init.sh` script.**

Run the [init.sh](./scripts/init.sh) script and follow the instructions to prepare the deployment for the first time.

This script will generate all necessary deployment files under the [deployments](deployments) directory and provide the command to start the project. **However, it will not start the project automatically.**

```shell
./scripts/init.sh
```

### Optional: ZKV Node Data Snapshots

To reduce the time required for a node's startup, **daily snapshots of chain data** are available for:
- Mainnet: https://bootstraps.zkverify.io/
- Testnet: https://bootstraps.zkverify.io/volta

Snapshots are available in two forms:

- **Node snapshot**
- **Archive node snapshot**

Each snapshot is a **.tar.gz** archive containing the **db** directory, intended to replace the **db** directory generated during the initial node run.

To use a snapshot:

1. Stop the running node:
   ```shell
   ./scripts/stop.sh
   ```
2. Navigate to the zkVerify node's data directory. This may require `sudo` permissions. For an RPC node, the path is:
    - For testnet:
        ```
        cd /var/lib/docker/volumes/zkverify-rpc-testnet_node-data/_data/node/chains/zkv_testnet
        ```
    - For mainnet:
        ```
        cd /var/lib/docker/volumes/zkverify-rpc_node-data/_data/node/chains/zkv_mainnet
        ```
3. Note the owner and permissions of the existing `db` directory, then delete it.
4. Extract the downloaded snapshot and move its `db` directory into the current directory.
5. Ensure the new `db` directory has the same permissions as the original db directory.
6. Return to the project directory and start the node:
   ```shell
   ./scripts/start.sh
   ```
7. Verify the snapshot is working by checking the node's Docker logs to ensure the block height starts near its respective current chain height and continue steadily increasing.

### Optional: ZKV Node Secrets Injection

During the initial deployment **depending on the node type**, if prompted, the script will generate and store **ZKV_NODE_KEY** and **ZKV_SECRET_PHRASE** values in the `.env` file.

Alternatively, these secrets can be injected at runtime using a custom container entrypoint script to avoid keeping them in plaintext on disk.

Use the following steps to implement this approach:

1. Delete values of **ZKV_NODE_KEY** and **ZKV_SECRET_PHRASE** under the `deployments/${NODE_TYPE}/${NETWORK}/.env`
    ```bazaar
    ZKV_NODE_KEY=""
    ZKV_SECRET_PHRASE=""
    ```
2. Create **entrypoint_secrets.sh** file under `deployments/${NODE_TYPE}/${NETWORK}/` directory. For example:
    ```
    #!/usr/bin/env sh
    set -eu
    
    # TODO: Implement logic to inject secrets into the environment
   
    # Run the application entrypoint
    echo "=== 🚀 Starting the application entrypoint now..."
    exec /app/entrypoint.sh "$@"
    ```
3. Modify `deployments/${NODE_TYPE}/${NETWORK}/docker-compose.yml` file to mount and execute **custom entrypoint** script
    ```
    volumes:
      - "node-data:/data:rw"
      - "./entrypoint_secrets.sh:/app/entrypoint_secrets.sh:rw"
    entrypoint: ["/app/entrypoint_secrets.sh"]
    ```
4. Start compose project using the command provided in the end of [init.sh](./scripts/init.sh) script execution.

### Optional: Public Address

The **ZKV_CONF_PUBLIC_ADDR** variable sets the node's `--public-addr` parameter and is optional. Declining is valid and safe, and is the right choice if you are unsure.

[init.sh](./scripts/init.sh) asks for this during first-time setup. Answer **yes** only if this node runs on a machine with a public IP address or hostname that other nodes can connect to. A wrong address is worse than none.

Choose an address type from the menu:

- ipv4 address
- hostname

Enter the address on its own, without the `/ip4/` or `/dns/` prefix and without the `/tcp/<port>` suffix; the script adds those. The port always comes from **NODE_NET_P2P_PORT**, so it differs between node types. In the `.env` file the result looks like `ZKV_CONF_PUBLIC_ADDR="/ip4/<your-public-ipv4>/tcp/<NODE_NET_P2P_PORT>"`. Choose `done` to finish, or add another address first.

The script rejects addresses that can never work as a public address, including private ranges, loopback, link-local, multicast, carrier-grade NAT, documentation addresses, and local or reserved hostnames.

If you decline, the script comments the variable out (`#ZKV_CONF_PUBLIC_ADDR=""`) so the node starts without the parameter. Set a value and remove the leading `#` at any time.

⚠️ Other validators may not be able to reach this node, and a future node version will require a public address.

[update.sh](./scripts/update.sh) asks for this variable once, on the first run where it has not yet been set or declined. If you quit at the prompt, the next run asks again.

### Update

To update the project to a new version (e.g., when a new release is available):

1. Pull the latest changes from the repository.
2. Run the [update.sh](./scripts/update.sh) script.

⚠️ If the script prompts to update values in the `.env` file, it is **recommended** to accept all changes, unless there is a specific reason not to.

If **ZKV_CONF_PUBLIC_ADDR** has not yet been set or declined, the script asks for it once. See [Optional: Public Address](#optional-public-address).

```shell
./scripts/update.sh
```

### Destroy

Run the [destroy.sh](./scripts/destroy.sh) script to destroy the node stack and all the associated resources. The script will prompt for confirmation before removing any resources.

```shell
./scripts/destroy.sh
```

### Re-genesis

> ⚠️  **Run this script ONLY if your currently running zkVerify node is on a version earlier than 0.9.0**
>
> For a fresh deployment, use [init.sh](./scripts/init.sh) script instead

#### To comply with re-genesis:

1. Pull the latest changes from the repository.
2. Run the [regenesis.sh](./scripts/regenesis.sh) script.

```shell
./scripts/regenesis.sh
```

---

## Usage Guide

### Start

Run the [start.sh](./scripts/start.sh) script to start the node stack.

```shell
./scripts/start.sh
```

### Stop

Run the [stop.sh](./scripts/stop.sh) script to just stop the node stack.

```shell
./scripts/stop.sh
```

---

## Contributing Guidelines

Please refer to the [CONTRIBUTING.md](CONTRIBUTING.md) file for information on how to contribute to this project.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
