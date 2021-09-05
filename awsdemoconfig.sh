#!/bin/sh

#######################################
# Basic bash script to create repeatable install of webserver
# Based on using AWS Linux 2 AMI
# Written by vincent verbon
#######################################

echo "Updating System.."
sudo yum update -y

## Get latest versions of the LAMP MAriaDB and PHP packages for Amazon Linux 2
echo "Installing Amazon Linux Extras Repositories"
echo "If this step fails stating sudo: amazon-linux-extras: command not found then your instance was not launched with Amazon Linux 2 AMI, but maybe with Amazon Linux AMI instead"
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2 -y

## Installing Apache, MariaDB, PHP
echo "Installing Apache, MariaDB-Server"
sudo yum install -y httpd mariadb-server

# Configure Permissions
echo "Permissions for /var/www"
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
sudo find /var/www -type f -exec sudo chmod 0664 {} \;
echo "Permissions have been set"

# Create Hello AWS ! page
cat > /var/www/html/index.html <<'EOF'
  <html>
  <head>
    <title>Hello AWS !</title>
  </head>
  <body>
    <h1>Hello AWS !</h1>
  </body>
EOF

# Configuring TLS (self-signed)
sudo yum install -y mod_ssl
cd /etc/pki/tls/certs
sudo ./make-dummy-cert localhost.crt
# Commenting out the existing key entry in ssl.conf
sudo sed -e '/SSLCertificateKeyFile/s/^/#/g' -i  /etc/httpd/conf.d/ssl.conf


# Start Apache
echo "Starting Apache"
sudo systemctl start httpd

# Making sure Apache is started at boot
echo "Set Apache enabled at boot"
sudo systemctl enable httpd
sudo systemctl is-enabled httpd
