# Making requests:

1. Follow [Code of Conduct](./CODE_OF_CONDUCT.md)
2. Please gpg sign your commits, otherwise final merging into `main` will be blocked
3. For pull request
   1. Perform a rebase on `main` branch before opening
   2. Make sure it goes to the `main` branch (trunk-based)


# Filing bug reports:

1. Follow the GitHub issue guide
2. If it requires secrecy, email security@zkverify.io

# What we're looking for:

1. Simply people who like to code and are nice people to work with. That's it!

# Versioning and releases

Tags are repo-level semver, not the node version. Each release's node version is set per network in the env templates (`NODE_VERSION`) and listed in `CHANGELOG.md`. One tag covers both networks, which may run different node versions.

- Node bump: minor or major. Other changes: patch or minor.
- If only one network moves, still one repo bump; name that network in the CHANGELOG (e.g. `1.0.3` set testnet to `2.0.0-rc1`, mainnet unchanged).

Release: bump the env templates, add a `## <version>` CHANGELOG entry, open a PR, then cut a gpg-signed tag `<version>` on `main` after merge.

# Naming conventions

- Roles: `boot-node`, `rpc-node`, `validator-node`.
- Paths: `compose_files/docker-compose-<role>.yml`, `env/<network>/.env.<role>.template` (`<network>` is `testnet` or `mainnet`).
- Env prefixes: `NODE_*` (node and container metadata), `ZKV_CONF_*` (zkVerify node substrate arguments).
- `COMPOSE_PROJECT_NAME`: mainnet bare, testnet appends `-testnet` (`zkverify-rpc`, `zkverify-rpc-testnet`).
- Image: `zkverify/relay-node:${NODE_VERSION}`.
