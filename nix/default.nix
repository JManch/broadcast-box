{
  lib,
  buildNpmPackage,
  buildGoApplication,
  importNpmLock,
}:
let
  name = "broadcast-box";
  version = "git";

  src = ../.;

  frontend = buildNpmPackage {
    inherit version;
    pname = "${name}-web";
    src = ../web;

    npmDeps = importNpmLock {
      npmRoot = ../web;
    };

    npmConfigHook = importNpmLock.npmConfigHook;

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
    substituteInPlace main.go \
      --replace-fail './web/build' '${placeholder "out"}/share/broadcast-box'
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
