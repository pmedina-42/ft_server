# Se descarga la imagen
From debian:buster

# Se actualiza e instala todo lo necesario
RUN apt-get update && apt-get upgrade -y && apt-get -y install wget \
																nginx \
																mariadb-server \
																php7.3 \
																php-mysql \
																php-fpm \
																php-pdo \
																php-gd \
																php-cli \
																php-mbstring \
																openssl

# Se copia y borra todo lo requerido para la configuración de nginx
COPY ./srcs/localhost /etc/nginx/sites-available/
RUN rm -f /etc/nginx/sites-available/default && \
	rm -f /etc/nginx/sites-enabled/default && \
	ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/

# Se tomará como dirección de trabajo la siguiente. A partir de aquí todo lo copiado irá directo a esa dirección y se tomará como la raíz .
WORKDIR /var/www/html/

# Los .tar de phpMyAdmin y Wordpress se descargan, descomprimen, se renombra el directorio de php y se borran los .tar
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-english.tar.gz && \
	wget https://wordpress.org/latest.tar.gz && \
	tar -xf phpMyAdmin-5.0.1-english.tar.gz && \
	tar -xvzf latest.tar.gz && \
	mv phpMyAdmin-5.0.1-english phpmyadmin && \
	rm -rf phpMyAdmin-5.0.1-english.tar.gz && \
	rm -rf latest.tar.gz

# Los archivos de la carpeta srcs se copian a la raíz (en este caso /var/www/html)
COPY srcs/index.html .
COPY srcs/style.css .
COPY srcs/isaac.jpg .
COPY srcs/config.inc.php phpmyadmin
COPY srcs/wp-config.php .
COPY srcs/wordpress.sql wordpress/
COPY ./srcs/init.sh .

# Se genera el certificado ssl y se dan todos los permisos
RUN openssl req -x509 -sha256 -nodes -newkey rsa:4096 -keyout /etc/ssl/nginx-selfsigned.key -out /etc/ssl/nginx-selfsigned.crt -days 365 -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=Learner/CN=localhost" && \
	chown -R www-data:www-data * && \
	chmod -R 755 /var/www/*

# Se ejecuta el script de init.sh
CMD bash init.sh
