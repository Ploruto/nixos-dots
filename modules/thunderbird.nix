{ ... }:
{
  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        "extensions.activeThemeID" = "default-theme@mozilla.org";
        "mail.biff.show_alert" = true;
        "mail.biff.use_system_alert" = true;
        "mail.biff.play_sound" = false;
        "mailnews.start_page.enabled" = false;
        "mail.shell.checkDefaultClient" = false;
      };
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
      "message/rfc822" = [ "thunderbird.desktop" ];
    };
  };
}
