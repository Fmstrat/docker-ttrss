FROM php:apache

ENV DEBIAN_FRONTEND noninteractive

# Install packages
RUN apt-get update
RUN apt-get install -y pkg-config
RUN apt-get install -y \
	libfreetype6-dev \
	libjpeg62-turbo-dev \
	libpng-dev \
	libpq-dev \
	libicu-dev \
	libldap2-dev \
	supervisor
RUN apt-get clean -y
RUN apt-get purge -y
RUN docker-php-ext-install -j$(nproc) gd mysqli pdo_mysql pgsql pdo_pgsql opcache pcntl iconv mysqli intl ldap

# Secure PHP
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Install TT-RSS
RUN curl -o /tmp/ttrss.tar.gz -L https://gitlab.com/gothfox/tt-rss/-/archive/master/tt-rss-master.tar.gz
RUN tar xf /tmp/ttrss.tar.gz -C /var/www/html --strip-components=1
RUN rm /tmp/ttrss.tar.gz

# Link PHP for hard-coded path in tt-rss
RUN ln -sf /usr/local/bin/php /usr/bin/php

# Make the data directory
RUN \
	mkdir /dist; \
	mkdir /data; \
	chown www-data:www-data /data; \
	mv /var/www/html/plugins.local /dist; \
	mv /var/www/html/themes.local /dist; \
	mv /var/www/html/cache /dist; \
	mv /var/www/html/lock /dist; \
	mv /var/www/html/feed-icons /dist; \
	ln -s /data/plugins.local /var/www/html/plugins.local; \
	ln -s /data/themes.local /var/www/html/themes.local; \
	ln -s /data/cache /var/www/html/cache; \
	ln -s /data/lock /var/www/html/lock; \
	ln -s /data/feed-icons /var/www/html/feed-icons;

# Allow config.php to be in data directory
RUN \
	ln -s /data/config.php /var/www/html/config.php; \
	sed -i 's|\.\./config\.php"|/data/config\.php"|g' /var/www/html/install/index.php; \
	sed -i 's|"config\.php"|"/data/config\.php"|g' /var/www/html/index.php; \
	sed -i 's|"config\.php"|"/data/config\.php"|g' /var/www/html/include/sanity_check.php;

# Create supervisord config
ADD ttrss-supervisord.conf /etc/supervisor/conf.d/ttrss-supervisord.conf

# Expose ports and volumes
EXPOSE 80 443
VOLUME /data

# Add scripts
ADD init.sh /init.sh
RUN chmod 755 /init.sh
ADD update.sh /update.sh
RUN chmod 755 /update.sh

CMD /init.sh
