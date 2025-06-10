# Compose zkverify simplified

This repository contains all the resources for deploying a zkverify rpc, validator, or boot node, on testnet.


## Project overview

There are three types of nodes that can be deployed:

1. rpc
2. validator
3. boot

When using any of the scripts provided in this repository, it will be requested to select **node type** and the **network** to run on(testnet).

---

## Requirements

* docker
* docker compose
* jq
* gnu-sed for Darwin distribution

---

## Installation instructions

Run the [init.sh](./scripts/init.sh) script and follow the instructions in order to prepare the deployment for the first time.

```shell
./scripts/init.sh
```

The script will generate the required deployment files under the [deployments](deployments) directory.

## Optional: ZKV Node Data Snapshots

To reduce the time required for a node's startup, **daily snapshots of chain data** are available [here](https://bootstraps.zkverify.io).

Snapshots are available in two forms:

- **Full node snapshot**
- **Archive node snapshot**

Each snapshot is a **.tar.gz** archive containing the **db** directory, intended to replace the **db** directory generated during the initial node run.

### Update

When a new version of the node is released this project will be updated with the new version modified in the `.env.*.template` files.

There may also be other changes to environment variables or configuration files that may need to be updated.

In order to update the project to the new version:

1. Pull the latest changes from the repository.
2. Run the [update.sh](./scripts/update.sh) script.

```shell
./scripts/update.sh
```

Should the script prompt you to update some of the values in .env file, it is recommended to accept all the changes
unless you know what you are doing.

### Destroy

Run the [destroy.sh](./scripts/destroy.sh) script to destroy the node stack and all the associated resources.

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

