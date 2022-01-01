FROM php:fpm-buster

MAINTAINER "Helov"

# options extension
# /usr/local/etc/php
# ******************
# bcmath bz2 calendar ctype(✓) curl(✓) dba dom(✓) enchant exif ffi fileinfo(✓) zend_test
# filter(✓) ftp(✓) gd gettext gmp hash(✓) iconv(✓) imap intl json(✓) ldap mbstring(✓) zip
# mysqli oci8(✗) odbc(✗) opcache pcntl pdo(✓) pdo_dblib(✗) pdo_firebird(✗) pdo_mysql xsl
# pdo_oci(✗) pdo_odbc(✗) pdo_pgsql(✗) pdo_sqlite(✓) pgsql(✗) phar(✓) posix(✓) pspell(✗) readline(✓)
# reflection(✓) session(✓) shmop simplexml(✓) snmp(✗) soap sockets sodium(✓) spl(✓) standard(✓)
# sysvmsg sysvsem sysvshm tidy(✗) tokenizer(✓) xml(✓) xmlreader(✓) xmlrpc(✗) xmlwriter(✓)
# ******************

# add aliyun mirror
RUN set -eux; \
printf 'deb http://mirrors.cloud.aliyuncs.com/debian/ buster main non-free contrib\n\
deb http://mirrors.cloud.aliyuncs.com/debian-security buster/updates main\n\
deb http://mirrors.cloud.aliyuncs.com/debian/ buster-updates main non-free contrib\n\
deb http://mirrors.cloud.aliyuncs.com/debian/ buster-backports main non-free contrib\n\
deb http://mirrors.aliyun.com/debian/ buster main non-free contrib\n\
deb http://mirrors.aliyun.com/debian-security buster/updates main\n\
deb http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib\n\
deb http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib' >> /etc/apt/sources.list; \
apt-get update

# add base ext
RUN set -eux; \
apt-get install -y --no-install-recommends libxml2-dev libzip-dev libxslt1-dev libbz2-dev libldap2-dev \
libenchant-dev libpng-dev libgmp3-dev; \
docker-php-ext-install -j$(nproc) bcmath bz2 calendar dba enchant exif ffi zend_test gettext gmp intl \
ldap zip mysqli opcache pcntl pdo_mysql xsl shmop soap sockets sysvmsg sysvsem sysvshm

# add gd ext
RUN set -eux; \
apt-get install -y --no-install-recommends libfreetype6-dev libjpeg62-turbo-dev libpng-dev; \
docker-php-ext-configure gd --with-freetype --with-jpeg; \
docker-php-ext-install -j$(nproc) gd

# add imap ext
RUN set -eux; \
apt-get install -y libc-client-dev libkrb5-dev; \
docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
docker-php-ext-install -j$(nproc) imap

# add redis ext
RUN set -eux; \
pecl install redis-5.3.5; \
docker-php-ext-enable redis

# add memcached ext
RUN set -eux; \
apt-get install -y --no-install-recommends libmemcached-dev zlib1g-dev; \
pecl install memcached-3.1.5; \
docker-php-ext-enable memcached

# add mcrypt ext
RUN set -eux; \
#apt-get install -y --no-install-recommends libmcrypt-dev; \
#pecl install mcrypt-1.0.4; \
#docker-php-ext-enable mcrypt
curl -fsSLOJ https://pecl.php.net/get/mcrypt/stable; \
tar -xf mcrypt-*.tgz; \
cd mcrypt-*; \
phpize; \
./configure; \
make; \
curl -fsSLOJ https://github.com/php/pecl-encryption-mcrypt/commit/5b16bf1c97c1bbab400fc877285bf0919ae73256.diff; \
git apply 5b16bf1c97c1bbab400fc877285bf0919ae73256.diff; \
make test; \
cp modules/*.so $(pecl config-get ext_dir); \
cd ..; \
rm -rf mcrypt-*; \
RUN echo extension="mcrypt.so" > /usr/local/etc/php/conf.d/php-ext-mcrypt.ini

# add xdebug ext
RUN set -eux; \
pecl install xdebug-3.1.2; \
docker-php-ext-enable xdebug

# add imagick ext
RUN set -eux; \
apt-get install -y --no-install-recommends libmagickwand-dev; \
pecl install imagick-3.6.0; \
docker-php-ext-enable imagick

# clean apt cache
RUN set -eux; \
rm -rf /var/lib/apt/lists/*

# add php.ini
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
