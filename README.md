# ansible_workstation_atomic

Intall additional software and configure the system (Fedora Silverblue, Bluefin (classic), Bluefin Dakota; with Gnome Desktop Environment) in accordance with my requirements.

## Supported OS

### Fedora Silverblue

- <https://fedoraproject.org/atomic-desktops/silverblue/>

### Bluefin

- <https://projectbluefin.io/>
- with developer mode enabled (<https://docs.projectbluefin.io/bluefin-dx/#step-1-turn-it-on>) and `ujust bluefin-cli`

### Bluefin Daktoa

- <https://projectbluefin.io/dakota/>

## Usage

- boot to desktop environment + login
  - Bluefin: enable Developer Mode + bluefin-cli
- clone this repo to the home directory of the current user
  - `cd $HOME`
  - `git clone https://gitlab.com/sanmue/ansible_workstation_atomic.git`
- cd into the repo folder
  - `cd $HOME/ansible_workstation_atomic`
- execute the initial bash script
  - `./start.sh`
  - script also starts ansible playbook `site.yml`
- Bluefin Dakata (optional): setup virtualization
  - `ujust setup-virtualization`

## Execute selected tasks of ansible playbook using 'tags'

Aliases in `.bashrc` + `.zshrc`

- `upnnnplugs`: create / update 'nnn' plugins + xterm conf for nnn-peview-tui
- `uppipuv`: update / install python libs defined in requirements.txt and update / install python tools (via uv tool)
- `upshellrc`: create / update shell conf (e.g. .bashrc, .zshrc, uv config)
- `upvic`: extensions update + conf for vicinae desktop launcher
  > :warning: vicinae currently not installed, alias `upvic` not available
- `upvimrc`: create / update vim conf + plugins
