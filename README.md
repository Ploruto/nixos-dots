# NixOS configuration

My laptop and desktop configuration: Umbriel, Noctalia, and Home Manager.
Uses NixOS 26.05 with selected applications from nixpkgs unstable.

## Structure

- `flake.nix` / `flake.lock`: machine definitions and pinned dependencies.
- `hosts/laptop/`, `hosts/desktop/`: hardware and machine-specific settings.
- `modules/common.nix`: shared system settings and user account.
- `modules/desktop.nix`: desktop services, login screen, fonts, and Home Manager imports.
- `modules/umbriel.nix`: window management and shortcuts.
- `modules/shell.nix`: Noctalia bar, wallpaper, themes, and locking.
- `modules/terminal.nix`, `modules/browser.nix`, `modules/neovim/`: applications.
- `modules/development.nix`: GitHub CLI, mise, Rust, C/C++ tools, and Antigravity.
- `modules/checks.nix`: generated desktop configuration checks using the laptop profile.

Both machines use the `garou` account and the same applications. The laptop
uses 2× scaling on `eDP-1`; the desktop uses default monitor settings and has
no battery widget. Compatibility versions are set per host; they should not
be changed just to upgrade packages.

## Apply

```bash
nix build .#checks.x86_64-linux.desktop-config
sudo nixos-rebuild switch --flake .#laptop
```

Use `.#desktop` on the PC. Reboot when changing the login screen or compositor.

### Set up the desktop

After installing NixOS, clone this repository on the PC and replace the
hardware placeholder with the file generated during installation:

```bash
cp /etc/nixos/hardware-configuration.nix hosts/desktop/hardware-configuration.nix
git add hosts/desktop/hardware-configuration.nix
nix flake check
sudo nixos-rebuild switch --flake .#desktop
```

The configuration assumes x86_64, UEFI, and systemd-boot, with Secure Boot
disabled. GPU drivers and any other hardware-specific options belong in
`hosts/desktop/configuration.nix`. Check the installed system's `stateVersion`
before the first switch. If the installer created a different user, set a
password for Garou with `sudo passwd garou` before rebooting.

The desktop placeholder deliberately blocks system builds until replaced.
Until then, run the targeted check shown above: `nix flake check` evaluates
both hosts and will fail on the placeholder. Once the hardware file is present,
use `nix flake check` to evaluate both hosts and run the generated settings check.
That check uses the laptop profile; build the PC's full system with
`nix build .#nixosConfigurations.desktop.config.system.build.toplevel`.
New files must be tracked by Git to be included in the flake.

## Development

GitHub CLI (`gh`), mise with Bash integration, and Antigravity CLI (`agy`) and
IDE (`antigravity-ide`) are installed on both machines. Sign in to GitHub with
`gh auth login`; Antigravity credentials are configured at runtime.

Rust includes Cargo, rustfmt, Clippy, and rust-analyzer. C/C++ tools include
Clang, clangd, clang-format, CMake, Ninja, and pkg-config. Neovim enables the
Rust and C/C++ language servers. Project-specific libraries and build inputs
belong in project development shells. Mise is available for additional runtimes;
the default Rust toolchain is managed by Nix.

## Desktop notes
Noctalia derives application colors from the wallpaper. Select images from
`~/Pictures/Wallpapers` in its wallpaper picker. Kitty and Neovim use custom
reload hooks so theme changes work with Nix-managed configuration files.

Noctalia GUI settings in `~/.local/state/noctalia/settings.toml` override the
Nix defaults. A one-time migration archives pre-Umbriel settings under
`~/.local/state/noctalia/before-umbriel.*`.

The screen locks after five minutes, turns off after six, and locks before
suspend. The greeter syncs appearance from Noctalia; its display scaling is
configured separately from the compositor in the host configuration.

| Shortcut | Action |
| --- | --- |
| Super+Space | Launcher |
| Super+Return | Kitty |
| Super+B | Firefox |
| Super+Q | Close window |
| Super+H/J/K/L | Focus window |
| Super+1…9 | Select workspace |
| Super+Shift+1…9 | Move window to workspace |
| Super+F | Fullscreen |
| Super+V | Clipboard |
| Super+Shift+L | Lock |
| Print | Screenshot region |

Other bindings come from the pinned Umbriel example. See
[Neovim's README](modules/neovim/README.md) for editor shortcuts.

The checks validate generated settings and theme integration. Login,
suspend/resume, external displays, and screen sharing need testing in a real
session.

## Credits

Appearance inspired by [evgen2571/my-nixos](https://github.com/evgen2571/my-nixos)
and [niii-san/nixos-config](https://github.com/niii-san/nixos-config).
