# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.17

MAINTAINER Zander Baldwin <hello@zanderbaldwin.com>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
EXPOSE 80

# Upgrade the Operating System.
RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

# Install Nginx
RUN apt-get install -y nginx

# Setup the Nginx daemon.
RUN mkdir -p /etc/service/nginx
ADD service/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

# Add Nginx Configuration
ADD config/nginx.conf /etc/nginx/nginx.conf
ADD config/default-site /etc/nginx/sites-available/default

# Install PHP
RUN apt-get install -y \
    php5-cli \
    php5-curl \
    php5-dbg \
    php5-dev \
    php5-fpm \
    php5-gd \
    php5-gmp \
    php5-gnupg \
    php5-imagick \
    php5-intl \
    php5-json \
    php5-mcrypt \
    php5-msgpack \
    php5-mysqlnd \
    php5-pgsql \
    php5-ps \
    php5-redis \
    php5-sqlite \
    php5-xdebug \
    php5-xsl

# Setup the PHP-FPM daemon.
RUN mkdir -p /etc/service/php5-fpm
ADD service/php5-fpm.sh /etc/service/php5-fpm/run
RUN chmod +x /etc/service/php5-fpm/run

# Add PHP Configuration
ADD config/pool-www.conf /etc/php5/fpm/pool.d/www.conf
ADD config/php.ini /etc/php5/fpm/php.ini
ADD config/php.ini /etc/php5/cli/php.ini
RUN ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/cli/conf.d/15-mcrypt.ini
RUN ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/fpm/conf.d/15-mcrypt.ini
RUN ln -s /etc/php5/mods-available/ps.ini /etc/php5/cli/conf.d/20-ps.ini
RUN ln -s /etc/php5/mods-available/ps.ini /etc/php5/fpm/conf.d/20-ps.ini

# Install just the MySQL client, since we'll link to the MySQL server container.
RUN apt-get install -y mysql-client

RUN mkdir -p /var/www && chown -R root:root /var/www

# Install Composer
RUN apt-get install -y wget
RUN wget -O /usr/local/bin/composer https://getcomposer.org/composer.phar && chmod +x /usr/local/bin/composer

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
