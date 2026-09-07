#!/usr/bin/env bash

# set -x # enable debug mode

### ---
### Functions
### ---
# shellcheck source=start.shlib
# source start.shlib

### ---
### Variables
### ---
python_version=$(python --version | cut -d' ' -f2)
python_requirements="requirements.txt"
ansible_requirements="requirements.yml"
playbook="site.yml"
os=$(grep -e "^NAME=" /etc/os-release | cut -d '"' -f 2 | xargs)
# vaultpasswordfile="${HOME}/.vault/ansibleVaultKey" # 'vault_password_file' defined in 'ansible.cfg'
PIP_INSTALL_FLAG="${HOME}/.ansible_python-pip-requirements_installed"
STARTSCRIPT_REBOOT_FLAG="${HOME}/.ansible_startscript_reboot"
PLAYBOOK_FINISHED_FLAG="${HOME}/.ansible_playbook_finished"

### ---
### Init
### ---
echo -e "\n\e[0;35mInitial steps\e[0m"

echo -e "\nHomebrew"
if [[ -d /var/home/linuxbrew/.linuxbrew ]]; then
    echo "Homebrew already installed"
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo -e "\nmise"
if command -v mise; then
    echo "mise already installed"
else
    brew install mise
fi
eval "$(mise activate bash)"

echo -e "\nPython - user-wide (via mise)"
# if [[ -n $(mise ls | grep "${python_version}") ]]; then
if mise ls | grep -q "${python_version}"; then
    echo "- Python version '${python_version}' already installed"
else
    mise use --global python@"${python_version}" # use same python version as the system python version - user-wide (--global)
fi

echo -e "\nPython - install requirements - python packages via pip (user)"
if [[ -f "$PIP_INSTALL_FLAG" ]]; then
    echo "- Installation of required python packages via pip (user) already done"
else
    eval "$(mise activate bash)"
    if pip install --user -r "${python_requirements}"; then
        touch "$PIP_INSTALL_FLAG"
    fi
fi

echo -e "\nAnsible - install requirements - collections"
ansible-galaxy collection install -r "${ansible_requirements}"

echo -e "\nAdditional Software (Layering)"
# Bluefin: you can use `ujust devmode, ...` which installs: VS Code, distrobox, qemu/kvm + virtual machine manager, docker + podman, ...
if command -v rpm-ostree && [[ "${os}" = "Fedora Linux" ]]; then
    if ! command -v gcc >/dev/null 2>&1; then
        echo "- installing gcc"
        sudo rpm-ostree install gcc # because homebrew is complaining
    fi
    if ! command -v distrobox >/dev/null 2>&1; then
        echo "- installing distrobox"
        sudo rpm-ostree install distrobox # alternative to toolbx
    fi
    if ! command -v tmux >/dev/null 2>&1; then
        echo "- installing tmux"
        sudo rpm-ostree install tmux
    fi
    if ! command -v vim >/dev/null 2>&1; then
        echo "- installing vim"
        sudo rpm-ostree install vim
    fi
    if ! command -v zsh >/dev/null 2>&1; then
        echo "- installing zsh"
        sudo rpm-ostree install zsh
    fi

    # Virtualization
    if ! command -v virsh >/dev/null 2>&1; then
        echo "- installing virtualization packages"
        sudo rpm-ostree install virt-install libvirt-daemon libvirt-daemon-common libvirt-daemon-config-network libvirt-daemon-kvm \
        libvirt-daemon-driver-qemu qemu-kvm   guestfs-tools   virt-manager virt-viewer \
        cockpit-machines cockpit-networkmanager cockpit-ostree cockpit-podman cockpit-selinux cockpit-storaged cockpit-system
    fi

    # Visual Studio Code # because of restrictions when installing as flatpak app
    if ! command -v code >/dev/null 2>&1; then
        echo "- installing Visual Studio Code"
        curl -o /tmp/vscode.repo https://packages.microsoft.com/yumrepos/vscode/config.repo 
        sudo install -o 0 -g 0 -m644 /tmp/vscode.repo /etc/yum.repos.d/vscode.repo
        sudo rpm-ostree install code
    fi

    # -------------------------------------------------------------------------
    if [[ ! -f "${STARTSCRIPT_REBOOT_FLAG}" ]]; then
        echo "**********"
        echo "* REBOOT *"
        echo "**********"
        
        echo -e "\n!!! Reboot needed, press any key to reboot the system. Start this script afterwards again !!!"
        touch "${STARTSCRIPT_REBOOT_FLAG}"
        read -r
        systemctl reboot
    fi
    # -------------------------------------------------------------------------

    if command -v virsh && [[ -f "${STARTSCRIPT_REBOOT_FLAG}" ]]; then
        echo -e "\n- start and enable libvirtd.service"
        if ! systemctl is-enabled --quiet libvirtd.service; then
            sudo systemctl enable libvirtd.service
        fi

        if ! groups "$USER" | grep -q '\blibvirt\b'; then
            echo -e "\n- adding current user '$USER' to 'libvirt' group"
            grep -E '^libvirt:' /usr/lib/group | sudo tee -a /etc/group && sudo usermod -aG libvirt "$USER"
        
            # -------------------------------------------------------------------------
            echo "**********"
            echo -e "\n!!! Reboot needed, press any key to reboot the system. You must this start the script after the reboot again !!!"
            read -r
            systemctl reboot
            # -------------------------------------------------------------------------
        fi
    fi
fi


### ----------------
### Ansible Playbook
### ----------------
echo -e "\n\e[0;35mAnsible Playbook\e[0m"

executePlaybook="y"
if [[ -e "${PLAYBOOK_FINISHED_FLAG}" ]]; then
    read -rp "The playbook has already been executed. Start again? (y=yes, other input: no): " executePlaybook
    if [[ ! "${executePlaybook}" = "y" ]]; then executePlaybook="no"; fi
fi

if [[ "${executePlaybook}" = "y" ]]; then
    # 'vault_password_file' defined in 'ansible.cfg'
    if ansible-playbook "${playbook}" -vv -K; then
    #if ansible-playbook "${playbook}" --ask-vault-pass -vv -K; then
    #if ansible-playbook "${playbook}" -vv -K --vault-password-file="${vaultpasswordfile}"; then
        echo "No error when executing playbook, creating flag file."
        touch "${PLAYBOOK_FINISHED_FLAG}"
    else
        echo "Error when executing playbook."
    fi
fi

echo -e "\n\e[0;33mScript finished.\e[0m"
