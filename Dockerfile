FROM php:8-fpm

MAINTAINER "hello hello@vvaii.com"

# options extension
# /usr/local/etc/php
# ******************
# bcmath bz2 calendar ctype curl dba dom enchant exif ffi fileinfo zend_test
# filter ftp gd gettext gmp hash iconv imap intl json ldap mbstring zip
# mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql xsl
# pdo_oci pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell readline
# reflection session shmop simplexml snmp soap sockets sodium spl standard
# sysvmsg sysvsem sysvshm tidy tokenizer xml xmlreader xmlrpc xmlwriter
# ******************

# replace aliyun mirror
RUN set -eux; \
printf 'deb http://mirrors.cloud.aliyuncs.com/debian/ buster main non-free contrib\n\
deb http://mirrors.cloud.aliyuncs.com/debian-security buster/updates main\n\
deb http://mirrors.cloud.aliyuncs.com/debian/ buster-updates main non-free contrib\n\
deb http://mirrors.cloud.aliyuncs.com/debian/ buster-backports main non-free contrib\n\
deb http://mirrors.aliyun.com/debian/ buster main non-free contrib\n\
deb http://mirrors.aliyun.com/debian-security buster/updates main\n\
deb http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib\n\
deb http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib' > /etc/apt/sources.list; \
apt-get update

# init
RUN set -eux; \
apt-get install -y --no-install-recommends libxml2-dev libzip-dev libxslt1-dev libbz2-dev libldap2-dev; \
docker-php-ext-install -j$(nproc) opcache xml bcmath exif \
soap pcntl sockets intl zip gettext xsl xmlrpc iconv sysvsem \
shmop pdo_mysql mysqli bz2 ldap

# redis
RUN set -eux; \
pecl install redis-5.1.1; \
docker-php-ext-enable redis

# memcached
RUN set -eux; \
apt-get install -y --no-install-recommends libmemcached-dev zlib1g-dev; \
pecl install memcached-3.1.5; \
docker-php-ext-enable memcached

# mcrypt
RUN set -eux; \
apt-get install -y --no-install-recommends libmcrypt-dev; \
pecl install mcrypt-1.0.3; \
docker-php-ext-enable mcrypt

# imagick
RUN set -eux; \
apt-get install -y --no-install-recommends libmagickwand-dev; \
pecl install imagick-3.4.4; \
docker-php-ext-enable imagick

# gd
RUN set -eux; \
apt-get install -y --no-install-recommends libfreetype6-dev libjpeg62-turbo-dev libpng-dev; \
docker-php-ext-configure gd --with-freetype --with-jpeg; \
docker-php-ext-install -j$(nproc) gd

# xdebug
RUN set -eux; \
pecl install xdebug-3.0.0; \
docker-php-ext-enable xdebug

# clean apt cache
RUN set -eux; \
rm -rf /var/lib/apt/lists/*

# php.ini
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
