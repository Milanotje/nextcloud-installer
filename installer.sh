#!/bin/bash

set -e

######## General checks #########

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

########## Variables ############

# Default MySQL credentials
MYSQL_DB="nextcloud_db"
MYSQL_USER="nextcloud_user"
MYSQL_PASSWORD="nextcloud_pass"

# Environment
email=""

# download URLs
NEXTCLOUD_DL_URL="https://download.nextcloud.com/server/releases/nextcloud-20.0.6.zip"
NEXTCLOUD_DL_FILENAME="nextcloud-20.0.6.zip"
####### lib func #######

array_contains_element () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

####### Visual functions ########

print_error() {
  COLOR_RED='\033[0;31m'
  COLOR_NC='\033[0m'

  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}

print_warning() {
  COLOR_YELLOW='\033[1;33m'
  COLOR_NC='\033[0m'
  echo ""
  echo -e "* ${COLOR_YELLOW}WARNING${COLOR_NC}: $1"
  echo ""
}

print_brake() {
  for ((n=0;n<$1;n++));
    do
      echo -n "#"
    done
    echo ""
}

hyperlink() {
  echo -e "\e]8;;${1}\a${1}\e]8;;\a"
}

##### User input functions ######

required_input() {
  local  __resultvar=$1
  local  result=''

  while [ -z "$result" ]; do
      echo -n "* ${2}"
      read -r result

      [ -z "$result" ] && print_error "${3}"
  done

  eval "$__resultvar="'$result'""
}

password_input() {
  local  __resultvar=$1
  local  result=''
  local default="$4"

  while [ -z "$result" ]; do
    echo -n "* ${2}"

    # modified from https://stackoverflow.com/a/22940001
    while IFS= read -r -s -n1 char; do
      [[ -z $char ]] && { printf '\n'; break; } # ENTER pressed; output \n and break.
      if [[ $char == $'\x7f' ]]; then # backspace was pressed
          # Only if variable is not empty
          if [ -n "$result" ]; then
            # Remove last char from output variable.
            [[ -n $result ]] && result=${result%?}
            # Erase '*' to the left.
            printf '\b \b' 
          fi
      else
        # Add typed char to output variable.
        result+=$char
        # Print '*' in its stead.
        printf '*'
      fi
    done
    [ -z "$result" ] && [ -n "$default" ] && result="$default"
    [ -z "$result" ] && print_error "${3}"
  done

  eval "$__resultvar="'$result'""
}

##### Main installation functions #####

# update os
update_os() {
  echo "* Checking for updates.."
  sudo apt update -y && sudo apt upgrade -y
  echo "* Updates installed!"
}

# Install net-tools
install_net_tools() {
  echo "* Installing net-tools.."
  sudo apt install net-tools -y
  echo "* net-tools installed!"
}

# Install apache
install_apache() {
  echo "* Installing Apache web server.."
  sudo apt install -y apache2 libapache2-mod-php bzip2
  echo "* Apache Web server installed!"
}

# Install required PHP modules for nextcloud
install_phpmodules() {
  echo "* Installing PHP Modules for nextcloud.."
  sudo apt install -y php-gd php-json php-mysql php-curl php-mbstring php-intl php-imagick php-xml php-zip php-sqlite3
  echo "* PHP modules succesfully installed!"
}

# Enable Mod_rewrite
enable_mod_rewrite() {
  echo "* Enabling mod_rewrite for nextcloud to function properly.."
  sudo a2enmod rewrite
  echo "* mod_rewrite succesfully enabled!"
}

# Enable additional Apache modules
enable_apachemodules() {
  echo "* Enabling additional Apache modules.."
  sudo a2enmod headers
  sudo a2enmod dir
  sudo a2enmod env
  sudo a2enmod mime
  echo "* Apache Modules succesfully enabled!"
}

# restart apache
restart_apache() {
  echo "* Restarting apache.."
  sudo systemctl restart apache2
  echo "* apache succesfully restarted!"
}

# install mariadb
install_mariadb() {
  echo "* Installing MariaDB.."
  sudo apt install -y mariadb-server mariadb-client
  echo "* MariaDB Succesfully installed!"
}

# securing mariadb
securing_mariadb() {
  echo "* Securing MariaDB.."
  echo "* MariaDB secure installation. The following are safe defaults."
  echo "* Set root password? [Y/n] Y"
  echo "* Remove anonymous users? [Y/n] Y"
  echo "* Disallow root login remotely? [Y/n] Y"
  echo "* Remove test database and access to it? [Y/n] Y"
  echo "* Reload privilege tables now? [Y/n] Y"
  echo "*"
  systemctl start mariadb
  mysql_secure_installation
  echo "* MariaDB Succesfully Secured!"
}

# Creating database
securing_mariadb() {

  echo "* Creating Database."
  sudo mysql -u root -p
  create database $MYSQL_DB;
  create user $MYSQL_USER@localhost identified by 'nextcloud_pass';
  grant all privileges on $MYSQL_DB.* to $MYSQL_USER@localhost identified by 'nextcloud_pass';  
  flush privileges;
  exit;
  echo "* MariaDB Succesfully Secured!"
}

# Download Nextcloud files
nc_dl() {
  echo "* Downloading and extracting nextcloud files .. "
  sudo apt install unzip -y

  sudo apt install wget -y

  wget $NEXTCLOUD_DL_URL

  sudo unzip nextcloud-20.0.6.zip -d /var/www/html

  sudo chown www-data:www-data /var/www/html/nextcloud/ -R

  sudo chmod 775 -R /var/www/html/nextcloud

  sudo systemctl restart apache2

  echo "* Done installing nextcloud"
}

  # confirm installation
  echo -e -n "\n* Initial configuration completed. Continue with installation? (y/N): "
  read -r CONFIRM
  if [[ "$CONFIRM" =~ [Yy] ]]; then
    perform_install
  else
    # run welcome script again
    print_error "Installation aborted."
    exit 1
  fi
}

goodbye() {
  print_brake 62
  echo "* nextcloud installation completed"
  echo "* Acces the server by typing <ip>/nextcloud in your browser"
  echo "* Because the scipt is in beta there might've been a few flaws"
  echo "* Because of this the database user Password was setted back to default (nextcloud_pass)"
  echo "* Database credentials are:"
  echo "* Database name: $MYSQL_DB"
  echo "* Database user: $MYSQL_USER"
  echo "* Database user password: nextcloud_pass"
  
  print_brake 62
}

# run script
main
goodbye