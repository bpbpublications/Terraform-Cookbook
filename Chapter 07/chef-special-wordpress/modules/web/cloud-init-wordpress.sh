#!/bin/bash
# Use the Bash shell to interpret this script

apt-get update -y
# Update the package list to the latest versions (-y to auto-confirm)

apt-get install -y apache2 php php-mysql
# Install Apache web server, PHP, and the PHP MySQL extension

cat <<EOF > /var/www/html/index.php
# Create (or overwrite) the PHP info page in the web root
<?php phpinfo(); ?>
# PHP function to display detailed PHP configuration and environment info
EOF

systemctl enable apache2
# Configure Apache to start automatically on boot

systemctl start apache2
# Start the Apache web server immediately
