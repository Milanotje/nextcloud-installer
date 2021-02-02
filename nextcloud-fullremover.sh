echo "* Checking for updates.."
sudo apt update -y && sudo apt upgrade -y

echo "* Removing Nextcloud files.."
sudo rm -r /var/www/html/nextcloud
echo "* Done removing Nextcloud files"

echo "* Removing PHP Modules for nextcloud.."
sudo apt remove -y php-gd php-json php-mysql php-curl php-mbstring php-intl php-imagick php-xml php-zip php-sqlite3
echo "* PHP modules succesfully installed!"

echo "* Removing Apache web server.."
sudo apt remove -y apache2 libapache2-mod-php bzip2
echo "* Apache Web server removed!"

echo "* Done removing nextcloud"
