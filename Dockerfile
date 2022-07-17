# Using base ubuntu image
FROM ubuntu:20.04

LABEL Maintainer="Wutthisak <wutthisak.ip@gmail.com>" \
      Description="Nginx + PHP7.4-FPM Based on Ubuntu 20.04."

ARG TIMEZONE="Asia/Bangkok"
ENV TZ=Asia/Bangkok

# Setup document root
RUN mkdir -p /var/www/html

# Base install
RUN apt-get update --fix-missing
RUN DEBIAN_FRONTEND=noninteractive
RUN apt install nano curl gnupg2 apt-transport-https ca-certificates lsb-release libicu-dev supervisor nginx -y

# Install php7.4-fpm
# Since the repo is supported on ubuntu 20
# Packages installation
RUN  apt-get -y --fix-missing install php7.4 \
      php7.4-cli \
      php-fpm \
      php7.4-gd \
      php7.4-json \
      php7.4-mbstring \
      php7.4-xml \
      php7.4-xsl \
      php7.4-zip \
      php7.4-soap \
      php7.4-mysql \
      php7.4-pgsql \
      php7.4-curl \
      php7.4-dev \
      php7.4-common \
      php7.4-opcache \
      php7.4-ldap \
      php7.4-intl \
      php7.4-bz2 \
      php-imagick \
      php-simplexml \
      php-fileinfo \
      php-pear \
      php-memcached \
      zlib1g \
      php7.4-curl 
RUN apt-get upgrade -y

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"
# Check if installation successfull
RUN composer --help

COPY ./entrypoint.sh ./entrypoint.sh

# Create socker
RUN mkdir -p /run/php


# Nginx site conf
ADD nginx/nginx-site.conf /etc/nginx/sites-available/default
ADD nginx/nginx.conf /etc/nginx/nginx.conf


ADD php/php.ini /etc/php/7.4/fpm/php.ini
ADD supervisor/config.conf /etc/supervisor/conf.d/supervisord.conf

# Starter file
ADD var/www/html/index.php /var/www/html/index.php
RUN cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

EXPOSE 80 443

# Let supervisord start nginx & php-fpm
#CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# # Prevent exit
ENTRYPOINT ["sh", "./entrypoint.sh"]

