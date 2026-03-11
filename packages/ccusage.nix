{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs_25,
  pnpm_10,
  pnpmConfigHook,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ccusage";
  version = "18.0.8";

  src = fetchFromGitHub {
    owner = "ryoppippi";
    repo = "ccusage";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YxT2RVa0RaCepod+ZRLk3qoF5YguZLbjozDmJ4Om2tk=";
  };

  nativeBuildInputs = [
    nodejs_25
    pnpmConfigHook
    pnpm_10
    makeWrapper
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-z1o2NEnMQRic/3lvQrQ4wJGlakCHkxIhcp05A7JT/Jk=";
  };

  # The build script runs "generate:schema && tsdown". Schema generation
  # requires bun and is not needed for the CLI, so run tsdown directly.
  buildPhase = ''
    runHook preBuild
    cd apps/ccusage
    node_modules/.bin/tsdown
    cd ../..
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/ccusage $out/bin

    cp -r apps/ccusage/dist/ $out/lib/ccusage/

    makeWrapper ${nodejs_25}/bin/node $out/bin/ccusage \
      --add-flags "$out/lib/ccusage/dist/index.js"

    runHook postInstall
  '';

  meta = {
    description = "Usage analysis tool for Claude Code";
    homepage = "https://github.com/ryoppippi/ccusage";
    license = lib.licenses.mit;
    mainProgram = "ccusage";
  };
})
