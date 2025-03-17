# Changelog

**0.9.0**
---
**March 21, 2025**

> ⚠️  **Re-genesis is required on TESTNET for this release**

CHANGES:
* node: zkVerify version upgraded to `0.9.0-0.12.0-relay`
* node: for `validator` and `boot` nodes, 'node_key' and/or 'secret_phrase' values are now sourced from environment variables `ZKV_NODE_KEY` and `ZKV_SECRET_PHRASE` respectively defined in the **.env** file
* automation: `re-genesis` script added [regenesis.sh](./scripts/regenesis.sh) to perform an upgrade from node version **< 0.9.0**
  * Ensure all the secrets are securely stored and retrievable **before** running the script(if applicable).
  * Refer to [README](./README.md#re-genesis) for more details

ENVIRONMENT VARIABLE CHANGES:
* `ZKV_NODE_KEY_FILE` → replaced by `ZKV_NODE_KEY`
* `ZKV_SECRET_PHRASE_PATH` → replaced by `ZKV_SECRET_PHRASE`

**0.8.0**

* This release includes version **0.8.0** of the [zkVerify](https://github.com/HorizenLabs/zkVerify) project.
  
**0.7.0**

* This release includes version **0.7.0** of the [zkVerify](https://github.com/HorizenLabs/zkVerify) project.
  
**0.6.0**

* This release includes version **0.6.0** of the [zkVerify](https://github.com/HorizenLabs/zkVerify) project.

**0.5.1**

* This release includes version **0.5.1** of the [zkVerify](https://github.com/HorizenLabs/zkVerify) project.

**0.5.0**

* This release includes version **0.5.0** (exactly **0.5.0-0.5.0**, **node_version-runtime_version**) of the [zkVerify](https://github.com/HorizenLabs/zkVerify) project.
  From hereon the tag on this repository will match the node part (first part) of the tag on the zkVerify repository.

**0.4.0**

* This release includes version **0.4.0** of the [zkVerify](https://github.com/HorizenLabs/zkVerify) project.

**0.3.0**

* This release includes version **0.3.0** of the [zkVerify](https://github.com/HorizenLabs/zkVerify) project.

**0.2.0**

* This release includes version **0.2.0** of the [zkVerify](https://github.com/HorizenLabs/zkVerify) project.

**0.2.0-rc2**

* This release includes version **0.2.0-rc2** of the [zkVerify](https://github.com/HorizenLabs/zkVerify) project.
