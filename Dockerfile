From debian:buster

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

COPY ./srcs/localhost /etc/nginx/sites-available/
RUN rm -f /etc/nginx/sites-available/default && \
	rm -f /etc/nginx/sites-enabled/default && \
	ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/

WORKDIR /var/www/html/
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-english.tar.gz
RUN tar -xf phpMyAdmin-5.0.1-english.tar.gz && rm -rf phpMyAdmin-5.0.1-english.tar.gz
RUN mv phpMyAdmin-5.0.1-english phpmyadmin

COPY srcs/index.html .
COPY ./srcs/config.inc.php phpmyadmin

RUN mkdir ./hts


COPY ./srcs/hola.html ./hts/hola.html
COPY ./srcs/adios.html ./hts/adios.html
COPY ./srcs/pablo.html ./hts/pablo.html


COPY ./srcs/wordpress.sql ./wordpress/wordpress.sql


RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xvzf latest.tar.gz && rm -rf latest.tar.gz
COPY ./srcs/wp-config.php /var/www/html


RUN openssl req -x509 -sha256 -nodes -newkey rsa:4096 -keyout /etc/ssl/nginx-selfsigned.key -out /etc/ssl/nginx-selfsigned.crt -days 365 -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=Learner/CN=localhost"
RUN chown -R www-data:www-data *
RUN chmod -R 755 /var/www/*

COPY ./srcs/init.sh ./
CMD bash init.sh
