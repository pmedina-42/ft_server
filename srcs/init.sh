echo "Elige on u off para autoindex"
read autoindex
if [ "$autoindex" == "on" ]; then
sed -i 's/autoindex off;/autoindex on;/g' /etc/nginx/sites-available/localhost
elif [ "$autoindex" == "off" ]; then
sed -i 's/autoindex on;/autoindex off;/g' /etc/nginx/sites-available/localhost
else
echo "No has metido valor válido" && exit
fi


service nginx start
service mysql start
service php7.3-fpm start

# Configure a wordpress database
echo "CREATE DATABASE wordpress;"| mysql -u root --skip-password
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost' WITH GRANT OPTION;"| mysql -u root --skip-password
echo "FLUSH PRIVILEGES;"| mysql -u root --skip-password
echo "update mysql.user set plugin='' where user='root';"| mysql -u root --skip-password

mysql wordpress -u root --password= < /var/www/html/wordpress/wordpress.sql

bash
