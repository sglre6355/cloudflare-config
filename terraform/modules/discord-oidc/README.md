# discord-oidc

Signing in to Cloudflare Access with Discord. Discord offers only OAuth2, so a Worker built from
[Aiko-IT-Systems/cloudflare-discord-oidc-worker](https://github.com/Aiko-IT-Systems/cloudflare-discord-oidc-worker)
serves it as OpenID Connect. `script_path` points to a bundle of that Worker, and the bindings in
`main.tf` follow the version pinned in `nix/discord-oidc-worker.nix`.

## Discord application

Discord applications cannot be made through an API, so the application is created by hand in the
Discord Developer Portal. Its OAuth2 redirects list the `redirect_uri` output. Its application ID is
`application_id`, and its OAuth2 client secret is `application_secret`.

## Secrets

- `application_secret` is the application's OAuth2 client secret.
- `signing_key` is the private RSA JWK, with a `kid`, that the Worker signs ID tokens with. Anyone
  with it can sign in to any Access application that accepts this identity provider.

Both end up in the state as Worker secrets, so the state needs the same protection as the secrets.
