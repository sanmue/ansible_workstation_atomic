#!/usr/bin/env bash

if [ ! "$(ls "${HOME}/mnt/pCloud")" ]; then
    echo -e "\e[1;33mPfad '${HOME}/mnt/pCloud' noch nicht vorhanden, wird erstellt...\e[0m"
    mkdir -pv "${HOME}/mnt/pCloud"
fi

echo -e "\nMounting pcloud to '${HOME}/mnt/pCloud'"
echo "Leave terminal window / session open as long as mount is required."
echo -e "To stop / unmount: press <CTRL>+<C> or close terminal window / session.\n"

rclone --vfs-cache-mode writes mount pcloud: "${HOME}/mnt/pCloud"
