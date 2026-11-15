{ pkgs, ... }:
{
  programs.bash.enable = true;
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    options = [ "--cmd cd" ];
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.kitty = {
    enable = true;
    font = {
      name = "Maple Mono NF";
      size = 20;
    };
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      background_opacity = "0.90";
      window_padding_width = 10;
    };
    # Noctalia owns the generated colors; Home Manager owns the base config.
    extraConfig = "include themes/noctalia.conf";
  };
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    mouse = true;
    prefix = "C-b";
    escapeTime = 0;
    historyLimit = 50000;
    baseIndex = 1;
    extraConfig =
      ''
        set -g status-position bottom
        set -g status-interval 5
        set -g status-style 'bg=default,fg=default'
        set -g window-status-style 'bg=default,fg=default'
        set -g status-left ""
        set -g status-right ""
        set -g window-status-separator '  '
        set -g window-status-format '#I:#W'
        set -g window-status-current-format '#[bg=colour8] #I:#W '
        set -g window-status-current-style 'bg=default,fg=default'
        set -g renumber-windows on
      '';
  };
  home.packages = [
    pkgs.iverilog
    pkgs.verilator
  ];
}
