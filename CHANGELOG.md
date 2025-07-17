# Changelog
**0.10.0**
---

CHANGES:
* node: zkVerify version upgraded to `0.10.0-0.17.0-relay`
* automation: `update.sh` script removes variables from the `.env` file if they no longer exist in the template.

**0.9.1+1**
---

CHANGES:
* node: zkVerify version upgraded to `0.9.1-0.14.0-relay`
* node: all the substrate parameters in the `.env` file that do not require a value such as `--validator` (**ZKV_CONF_VALIDATOR**) were switched to the following format for example:
  * ZKV_CONF_VALIDATOR=true → ZKV_CONF_VALIDATOR=yes
* node: for `rpc` node, adding an option to set a limit for the max length per RPC batch request
  > ⚠️ **Important:** When using the `update.sh` script to enable this setting, manually add the `ZKV_CONF_RPC_MAX_BATCH_REQUEST_LEN` variable to your `.env` file **before starting the compose project**.
  > This variable expects a **non-negative integer** value.

**0.9.1**

* This release includes version **0.9.1** of the [zkVerify](https://github.com/HorizenLabs/zkVerify) project and introduces the the max connections parameter for the rpc nodes setting it to 1000. 

**0.9.0**
---
**March 21, 2025**

> ⚠️  **This release brings re-genesis on TESTNET network**

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
