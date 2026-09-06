#!/usr/bin/env bash

#set -x   # enable debug mode
set -uo pipefail

REPO_NAME="ansible_workstation_atomic"
PLAYBOOK="site.yml"
# suche funktioniert so nur, wenn nur 1 Treffer:
# repo_path=$(find "${HOME}" -type d -name "${REPO_NAME}" -not -path '*/.*' 2>/dev/null)
# schneller, da versteckte Verzeichnisse direkt übersprungen werden:
repo_path=$(find "${HOME}" -path '*/.*' -prune -o -type d -name "${REPO_NAME}" -print 2>/dev/null)

# Check if repo_path empty (path to folder 'REPO_NAME' not found)
if [ -z "${repo_path}" ]; then
    echo -e "\e[31m- Folder '${REPO_NAME}' not found.\e[0m"

    repo_path="${HOME}/.${REPO_NAME}_repo"
    echo "- setting target repo_path to '${repo_path}'"

    # Check if new path for REPR_DIR already exists (already cloned)
    if [ ! -d "${repo_path}" ]; then # if repo dir does not yet exist
        git clone "https://gitlab.com/sanmue/${REPO_NAME}.git" "${repo_path}"
    else # if repo already exists (cloned) -> update
        # cd "${repo_path}" && git pull
        if ! git -C "${repo_path}" pull; then
            echo "Git pull failed"
            exit 1
        fi
    fi
else
    # will not be executed, since repo will be cloned in if-statement above, if folder REPO_NAME not found
    echo -e "- Folder '${REPO_NAME}' found at: \n${repo_path}"
fi

# Check number of parameters
# if [ $# -le 0 ] || [ $# -gt 1 ]; then # if no parameter or more than 1 parameter passed
if [ $# -ne 1 ]; then
    echo -e "\e[31m- No parameter or more than 1 parameter passed to the script.\e[0m"
    exit 1
else
    tag="${1}"
    echo "- Parameter passed to the script: '${tag}'"
fi

ansible-playbook "${repo_path}/${PLAYBOOK}" -v -K --tags "${tag}"
