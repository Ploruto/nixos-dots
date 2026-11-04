{ config, ... }:
let
  d = config.desktop;
  c = d.theme.colors;
  p = d.theme.palette;
in
{
  desktop.shortcuts = {
    "terminal.open" = {
      description = "Open Kitty with tmux";
      keys = [
        d.keyboard.modifier
        "Return"
      ];
      command = [ "kitty" ];
    };
    "terminal.plain" = {
      description = "Open a plain terminal";
      keys = [
        d.keyboard.modifier
        "SHIFT"
        "Return"
      ];
      command = [
        "kitty"
        "--"
        "bash"
      ];
    };
  };
  flake.modules.homeManager.terminal = { pkgs, ... }: {
    programs.kitty = {
      enable = true;
      font = {
        name = d.fonts.family;
        size = d.fonts.effectiveSizes.terminal;
      };
      settings = {
        shell = "${pkgs.tmux}/bin/tmux new-session -A -s main";
        background = c.background;
        foreground = c.text;
        selection_background = c.selection;
        selection_foreground = c.text;
        cursor = c.accent;
        url_color = p.blue;
        active_border_color = c.accent;
        inactive_border_color = c.border;
        window_padding_width = d.geometry.terminalPadding;
        hide_window_decorations = true;
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        color0 = p.surface1;
        color1 = p.red;
        color2 = p.green;
        color3 = p.yellow;
        color4 = p.blue;
        color5 = p.pink;
        color6 = p.teal;
        color7 = p.subtext1;
        color8 = p.surface2;
        color9 = p.red;
        color10 = p.green;
        color11 = p.yellow;
        color12 = p.blue;
        color13 = p.pink;
        color14 = p.teal;
        color15 = p.text;
      };
    };
    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      keyMode = "vi";
      mouse = true;
      escapeTime = 0;
      historyLimit = 50000;
      baseIndex = 1;
      extraConfig = ''
        set -as terminal-features ',xterm-kitty:RGB'
        set -g renumber-windows on
        set -g status-style 'bg=${c.panel},fg=${c.text}'
        set -g window-status-current-style 'bg=${c.selection},fg=${c.accent}'
        set -g pane-border-style 'fg=${c.border}'
        set -g pane-active-border-style 'fg=${c.accent}'
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        bind | split-window -h -c '#{pane_current_path}'
        bind - split-window -v -c '#{pane_current_path}'
        bind c new-window -c '#{pane_current_path}'
      '';
    };
  };
}
