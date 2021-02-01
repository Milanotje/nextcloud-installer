#!/bin/bash

set -e

#######################################################################
#                                                                     #
# Project 'nextcloud-installer'                                       #
#                                                                     #
# By: Milanotje#6666                                                  #
#                                                                     #
#   Quick notes:                                                      #  
#                                                                     #
#   This installer is in very early beta and issues are expected.     #
#   It uses apache2 as webserver, NGINX coming soon!                  #
#   This is made for ubuntu 20.04, but might work with other os's.    #
#   This script is NOT associated with the official Nextcloud project.#
#   We are not responsible for data loss or any other stuff.          #
#                                                                     #
#######################################################################

SCRIPT_VERSION="v0.0.1"

# exit with error status code if user is not root
if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

output() {
  echo -e "* ${1}"
}

error() {
  COLOR_RED='\033[0;31m'
  COLOR_NC='\033[0m'

  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}

done=false

output "Nextcloud installation script @ $SCRIPT_VERSION"
output
output "This script is not associated with the official Nextcloud Project."
output
output "By using this script you have read and agreed to the quick notes section."
output 
output "When finished you will be able to acces it by going to this link: <ip>/nextcloud"
output

nextcloud() {
  bash <(curl -s https://raw.githubusercontent.com/Milanotje/nextcloud-installer/main/installer.sh)
}

quit() {
  ^C
}


while [ "$done" == false ]; do
  options=(
    "Install Nextcloud with apache"
    "Quit Installation script"
  )

  actions=(
    "nextcloud"
    "quit"
  )

  output "What would you like to do?"

  for i in "${!options[@]}"; do
    output "[$i] ${options[$i]}"
  done

  echo -n "* Input 0-$((${#actions[@]}-1)): "
  read -r action

  [ -z "$action" ] && error "Input is required" && continue

  valid_input=("$(for ((i=0;i<=${#actions[@]}-1;i+=1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && eval "${actions[$action]}"
done
