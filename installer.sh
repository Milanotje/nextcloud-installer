echo "* Checking for updates.."
sudo apt update -y && sudo apt upgrade -y


echo "* Installing net-tools.."
sudo apt install net-tools -y
echo "* net-tools installed!"




echo "* Installing Apache web server.."
sudo apt install -y apache2 libapache2-mod-php bzip2
echo "* Apache Web server installed!"



echo "* Installing PHP Modules for nextcloud.."
sudo apt install -y php-gd php-json php-mysql php-curl php-mbstring php-intl php-imagick php-xml php-zip php-sqlite3
echo "* PHP modules succesfully installed!"


echo "* Enabling mod_rewrite for nextcloud to function properly.."
sudo a2enmod rewrite
echo "* mod_rewrite succesfully enabled!"

echo "* Enabling additional Apache modules.."
sudo a2enmod headers
sudo a2enmod dir
sudo a2enmod env
sudo a2enmod mime
echo "* Apache Modules succesfully enabled!"


echo "* Restarting apache.."
sudo systemctl restart apache2
echo "* apache succesfully restarted!"



echo "* Installing MariaDB.."
sudo apt install -y mariadb-server mariadb-client
echo "* MariaDB Succesfully installed!"


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

echo "* Creating Database."
sudo mysql -u root -p "create database nextcloud_db;"
sudo mysql -u root -p "create user nextcloud_user@localhost identified by 'nextcloud_pass';"
sudo mysql -u root -p "grant all privileges on nextcloud_db.* to nextcloud_user@localhost identified by 'nextcloud_pass';  "
sudo mysql -u root -p "flush privileges;"
echo "* MariaDB Succesfully Secured!"


echo "* Downloading and extracting nextcloud files .. "
 
sudo apt install unzip -y

sudo apt install wget -y
wget https://download.nextcloud.com/server/releases/nextcloud-20.0.6.zip

sudo unzip nextcloud-20.0.6.zip -d /var/www/html

sudo chown www-data:www-data /var/www/html/nextcloud/ -R

sudo chmod 775 -R /var/www/html/nextcloud
sudo systemctl restart apache2

echo "* Done installing nextcloud"

echo "* nextcloud installation completed"
echo "* Acces the server by typing <ip>/nextcloud in your browser"
echo "* Because the scipt is in beta there might've been a few flaws"
echo "* Because of this the database user Password was setted back to default (nextcloud_pass)"
echo "* Database credentials are:"
echo "* Database name: nextcloud_db"
echo "* Database user: nextcloud_user"
echo "* Database user password: nextcloud_pass"
