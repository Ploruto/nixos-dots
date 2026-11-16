# nixos-dots

NixOS 26.05 configuration for my desktop and laptop, using Home Manager,
Umbriel and Noctalia. Selected packages come from nixos-unstable.

Desktop apps: Firefox, Thunderbird, Spotify, Kitty, Nautilus, imv and
Antigravity IDE. The desktop bar includes Headroom for Codex and Antigravity
usage. Wallpapers live in ~/Pictures/Wallpapers.

Terminal tools: Neovim (also aliased to n), tmux, Git, gh, Codex, Antigravity
CLI, just, mise, devenv, direnv, zoxide and Starship. Development tools include
Rust, Cargo, Clippy, rustfmt, rust-analyzer, Clang, CMake, Ninja, Icarus Verilog,
Verilator, Typst and Tinymist. Direnv loads approved project environments in Bash.

The desktop uses DP-3 at 2560×1440, 144 Hz and 1.5× scaling. The laptop uses
2× scaling on eDP-1.

Core shortcuts:

- Super+Space: launcher
- Super+Return: terminal
- Super+B: Firefox
- Super+W: close window
- Super+H/J/K/L: focus window
- Super+1–9: switch workspace
- Super+Shift+1–9: move window to workspace
- Super+F: fullscreen
- Super+V: clipboard
- Super+Alt+W: wallpaper picker
- Super+Shift+L: lock
- Print: region screenshot

Appearance inspired by [evgen2571/my-nixos](https://github.com/evgen2571/my-nixos)
and [niii-san/nixos-config](https://github.com/niii-san/nixos-config).
