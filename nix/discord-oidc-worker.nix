# The Worker that `terraform/modules/discord-oidc` deploys, bundled into one
# module as Cloudflare takes it. The module's bindings and compatibility date
# follow the version pinned here.
{
  buildNpmPackage,
  fetchFromGitHub,
  esbuild,
}:

buildNpmPackage {
  pname = "discord-oidc-worker";
  version = "5.0.0";
  src = fetchFromGitHub {
    owner = "Aiko-IT-Systems";
    repo = "cloudflare-discord-oidc-worker";
    rev = "2a0ff62803372348226d7d50207ea6999cecf6c9";
    hash = "sha256-EcDoxBNs2TFidE5wr4HWVHntAZUpvfhsiEDhBHKtol4=";
  };
  npmDepsHash = "sha256-Pl/K+EumJ7MpGIkTXHzdn8fkmjspEz/ATDxoRLM2aOo=";
  npmFlags = [ "--ignore-scripts" ];
  nativeBuildInputs = [ esbuild ];
  buildPhase = ''
    esbuild src/index.ts --bundle --format=esm --target=es2022 \
      --conditions=workerd,worker,browser --minify --keep-names \
      --outfile=worker.js
  '';
  installPhase = "install -Dm644 worker.js $out/worker.js";
}
