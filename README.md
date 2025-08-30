# nix

my own nixos config

## what is this

personal nixos setup for gaming, development, and creative stuff. runs on my asus tuf gaming a15 laptop (amd ryzen 9 7940hs + rtx 4050 max-q).

**warning**: this is made for my specific hardware. you'll need to change things for your system. made with help from claude ai.

## features

### gaming
- steam with gamescope
- gamemode for better performance
- mangohud for fps monitoring
- lutris, bottles, heroic for other games
- nvidia + amd hybrid graphics setup
- 32-bit game support

### development
- docker (rootless mode)
- languages: nodejs, python, rust, go, java 17
- vscode and neovim
- git, github cli, insomnia for api testing
- build tools: gcc, clang, cmake, maven, gradle

### creative work
- blender for 3d stuff
- gimp and inkscape for graphics
- kdenlive for video editing
- obs studio for recording/streaming
- audacity for audio

### terminal setup
- fish shell with clean white/gray theme
- starship prompt with git info
- modern cli tools: bat, eza, ripgrep, fd, fzf
- minimal fastfetch config

### desktop
- gnome with bloat removed
- useful extensions: dash to dock, blur my shell, pop shell
- gnome tweaks and dconf-editor

### auto-installed apps
- vesktop (better discord)
- sober (roblox for linux)
- signal and telegram

## installation

1. check your hardware first:
   ```bash
   lspci | grep VGA
   ```

2. edit the config:
   - update gpu bus ids in nvidia section
   - remove nvidia stuff if you don't have nvidia
   - adjust other hardware settings

3. replace your config:
   ```bash
   sudo cp configuration.nix /etc/nixos/
   ```

4. rebuild:
   ```bash
   sudo nixos-rebuild switch
   sudo reboot
   ```

## compatibility

**works on:**
- my asus tuf gaming a15
- probably other similar amd + nvidia laptops

**needs changes for:**
- intel systems
- amd-only graphics
- different laptop brands
- desktop computers

## customization

add software by editing the packages list in configuration.nix

install flatpaks manually:
```bash
flatpak install flathub com.example.App
```

## notes

- fish is the default shell
- flatpak apps install on first boot
- uses stable nvidia drivers
- includes lots of fonts for terminal icons

## credits

made with claude ai. thanks to the nixos community for great docs.

---

enjoy!
