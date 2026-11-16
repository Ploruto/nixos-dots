{ config, lib, pkgs, ... }:
{
  services.remmina = {
    enable = true;
    systemdService.enable = false;
  };

  home.activation.remminaSharedFolder = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "${config.home.homeDirectory}/work" "${config.xdg.configHome}/remmina"
    run ${pkgs.python3}/bin/python3 - "${config.xdg.configHome}/remmina/remmina.pref" "${config.home.homeDirectory}/work" <<'PY'
    import configparser
    import os
    import pathlib
    import sys
    import tempfile

    path = pathlib.Path(sys.argv[1])
    prefs = configparser.RawConfigParser(strict=False)
    prefs.optionxform = str
    if path.exists():
        prefs.read(path)
    if not prefs.has_section("remmina"):
        prefs.add_section("remmina")
    prefs.set("remmina", "drive", "work," + sys.argv[2])

    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as output:
        temporary = output.name
        try:
            prefs.write(output)
            output.close()
            os.replace(temporary, path)
        finally:
            if os.path.exists(temporary):
                os.unlink(temporary)
    PY
  '';
}
