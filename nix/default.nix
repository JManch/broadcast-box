{
  lib,
  buildNpmPackage,
  buildGoApplication,
}:
let
  name = "broadcast-box";
  version = "git";

  src = ../.;

  frontend = buildNpmPackage {
    inherit version;
    pname = "${name}-web";
    src = ../web;

    npmDepsHash = "sha256-KGp4f0D/5AxxucrX1K7XRMolRSqTYoEbpg08nuxDNCg=";

    preBuild = ''
      cp "${src}/.env.production" ../
    '';

    installPhase = ''
      mkdir -p $out
      cp -r build $out
    '';
  };
in
buildGoApplication {
  inherit version src frontend;
  pname = name;
  pwd = src;
  doCheck = false;
  modules = ./gomod2nix.toml;

  postPatch = ''
    substituteInPlace internal/environment/environment.go \
      --replace-fail 'frontendPath := os.Getenv(frontendPath)' 'frontendPath := "${placeholder "out"}/share/broadcast-box"'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/broadcast-box
    cp -r ${frontend}/build/* $out/share/broadcast-box
    cp -r "$GOPATH/bin" $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "WebRTC broadcast server";
    homepage = "https://github.com/Glimesh/broadcast-box";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "broadcast-box";
  };
}
