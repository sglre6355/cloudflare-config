# cloudflare-config

Manage Cloudflare domains and shared Zero Trust settings with OpenTofu. This repository currently
configures domain zones and email sign-in with a one-time PIN for Cloudflare Access.

## Getting started

You need Nix and the private GPG key that can decrypt `secrets.yaml`. The development shell provides
OpenTofu, the Cloudflare CLI, SecretSpec, SOPS, and the other tools used by this repository.

Run these commands from the repository root to load the tools and sign in to Cloudflare.

```sh
nix develop
cf auth login
```

If you use direnv, you can run `direnv allow` instead of `nix develop`.

Check the account ID and domain list in `terraform/terraform.tfvars`. Then initialize OpenTofu and
review the proposed changes.

```sh
secretspec run -- tofu -chdir=terraform init
secretspec run -- tofu -chdir=terraform plan
```

Apply the changes after reviewing the plan.

```sh
secretspec run -- tofu -chdir=terraform apply
```

## Authentication and secrets

Run OpenTofu through `secretspec run --` so it receives the credentials defined in
`secretspec.toml`.

- `CLOUDFLARE_API_TOKEN` comes from the active `cf` CLI login and uses that login's permissions.
  SecretSpec reads the OAuth token from the CLI on each run. No separate API token is configured.
- `TF_VAR_state_passphrase` encrypts OpenTofu state and saved plan files. The passphrase is stored
  in `secrets.yaml`, which SOPS encrypts for the GPG key specified in `.sops.yaml`.

On another machine, clone the repository, make the private GPG key available, and sign in with
`cf auth login`. Without access to the passphrase, you cannot decrypt the existing state. The
Cloudflare resources still exist and can be imported into new state.

## Working with state

The encrypted state is kept in `terraform/terraform.tfstate` and committed to Git. There is no
shared state locking, so only one person should apply changes at a time.

Pull the latest changes before applying. After a successful apply, commit and push the updated
configuration and state so the next person starts from the current version.

## Layout

`terraform/` contains the root module. Reusable modules live in `terraform/modules/`. Configuration
used only once lives in its own directory directly under `terraform/`.
