# ansible_workstation_atomic

Intall additional software and configure the system (Fedora Silverblue or Bluefin with Gnome Desktop Environment) in accordance with my requirements.

## Supported OS

Fedora Silverblue

- <https://fedoraproject.org/atomic-desktops/silverblue/>

Bluefin

- <https://projectbluefin.io/>

## Usage

- boot to desktop environment + login
  - Bluefin: enable Developer Mode (<https://docs.projectbluefin.io/bluefin-dx/#step-1-turn-it-on>)
- clone this repo to the home directory of the current user
  - `cd $HOME`
  - `git clone https://gitlab.com/sanmue/ansible_workstation_atomic.git`
- cd into the repo folder
  - `cd $HOME/ansible_workstation_atomic`
- execute the initial bash script
  - `./start.sh`
  - script also starts ansible playbook `site.yml`

## Execute selected tasks of ansible playbook using 'tags'

Aliases in `.bashrc` + `.zshrc`

- `upnnnplugs`: create / update 'nnn' plugins + xterm conf for nnn-peview-tui
- `upshellrc`: create / update shell conf (e.g. .bashrc, .zshrc)
- `upvic`: extensions update + conf for vicinae desktop launcher
  - vicinae currently not installed, alias `upvic` not available
- `upvimrc`: create / update vim conf + plugins
