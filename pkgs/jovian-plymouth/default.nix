{ lib
, stdenv
, logo
}:

stdenv.mkDerivation {
  pname = "steamdeck-hw-theme";
  version = "1.0";

  src = ./.;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    sed -i "s|/usr/|$out/|g" jovian.plymouth

    mkdir -p $out/share/plymouth/themes/jovian
    cp -vt $out/share/plymouth/themes/jovian \
      jovian*
    cp -v ${logo} $out/share/plymouth/themes/jovian/jovian.png
  '';

  meta = with lib; {
    description = "Jovian NixOS plymouth theme";
  };
}
