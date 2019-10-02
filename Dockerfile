FROM phusion/baseimage:0.11

LABEL maintainer="charescape@outlook.com"

ENV PHP_VERSION           7.3.10
ENV LIBSODIUM_VERSION     1.0.18
ENV COMPOSER_VERSION      1.9.0

COPY ./startserv.sh                   /etc/my_init.d/
COPY ./conf/php.ini                   /usr/local/src/
COPY ./conf/php-fpm.conf              /usr/local/src/
COPY ./conf/www.conf                  /usr/local/src/
COPY ./src/php-7.3.10.tar.gz          /usr/local/src/
COPY ./src/libsodium-1.0.18.tar.gz    /usr/local/src/
COPY ./src/composer                   /usr/local/bin/

# see http://www.ruanyifeng.com/blog/2017/11/bash-set.html
RUN set -eux \
&& export DEBIAN_FRONTEND=noninteractive \
&& sed -i 's/http:\/\/archive.ubuntu.com/https:\/\/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
&& sed -i 's/http:\/\/security.ubuntu.com/https:\/\/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
&& sed -i 's/https:\/\/archive.ubuntu.com/https:\/\/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
&& sed -i 's/https:\/\/security.ubuntu.com/https:\/\/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
&& apt-get -y update            \
&& apt-get -y upgrade           \
&& apt-get -y install build-essential \
git                             \
curl                            \
re2c                            \
bison                           \
zip                             \
libtool                         \
libssl-dev                      \
zlib1g-dev                      \
libpcre3-dev                    \
libedit-dev                     \
libeditline-dev                 \
libgd-dev                       \
libwebp-dev                     \
libfreetype6-dev                \
libpng-dev                      \
libjpeg-dev                     \
libxml2-dev                     \
libbz2-dev                      \
libcurl4-openssl-dev            \
libgmp-dev                      \
libreadline-dev                 \
libicu-dev                      \
libzip-dev                      \
libtidy-dev                     \
libevent-dev                    \
chromium-browser                \
fonts-droid-fallback            \
ttf-wqy-zenhei                  \
ttf-wqy-microhei                \
fonts-arphic-ukai               \
fonts-arphic-uming              \
\
&& CPU_NUM=`cat /proc/cpuinfo | grep processor | wc -l` \
\
&& groupadd group7 \
&& useradd -g group7 -M -d /usr/local/php user7 -s /sbin/nologin \
\
&& chmod +x /etc/my_init.d/startserv.sh \
&& chmod +x /usr/local/bin/composer \
\
&& cd /usr/local/src \
\
&& tar -zxf php-${PHP_VERSION}.tar.gz \
&& tar -zxf libsodium-${LIBSODIUM_VERSION}.tar.gz \
\
&& cd /usr/local/src/libsodium-${LIBSODIUM_VERSION} \
&& ./configure \
&& make -j${CPU_NUM} \
&& make install \
\
&& cd /usr/local/src/php-${PHP_VERSION} \
&& ./configure --prefix=/usr/local/php \
--enable-fpm \
--with-fpm-user=user7 \
--with-fpm-group=group7 \
--disable-short-tags \
--with-libxml-dir \
--with-openssl \
--with-openssl-dir \
--with-pcre-regex \
--with-pcre-dir \
--with-pcre-jit \
--with-zlib \
--with-zlib-dir \
--enable-bcmath \
--with-bz2 \
--enable-calendar \
--with-curl \
--enable-exif \
--with-gd \
--with-webp-dir \
--with-jpeg-dir \
--with-png-dir \
--with-xpm-dir \
--with-freetype-dir \
--enable-gd-jis-conv \
--with-gettext \
--with-gmp \
--with-mhash \
--enable-intl \
--with-icu-dir=/usr \
--enable-mbstring \
--enable-mysqlnd \
--enable-pdo \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--enable-pcntl \
--with-readline \
--enable-soap \
--enable-sockets \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
--enable-shmop \
--with-xsl \
--with-tidy \
--with-xmlrpc \
--enable-zip \
--with-libzip \
--with-iconv-dir \
--with-pear \
--with-ldap \
--with-ldap-sasl \
--with-sodium \
\
&& make -j${CPU_NUM} \
&& make install \
\
&& cd /usr/local/src \
&& yes | cp ./php-fpm.conf /usr/local/php/etc/php-fpm.conf \
&& yes | cp ./www.conf     /usr/local/php/etc/php-fpm.d/www.conf \
&& yes | cp ./php.ini      /usr/local/php/lib/php.ini \
\
&& chown -R user7:group7  /usr/local/php \
&& /usr/local/php/sbin/php-fpm \
&& sleep  3s \
&& kill -INT `cat /usr/local/php/var/run/php-fpm.pid` \
\
&& echo '' >> ~/.bashrc \
&& echo 'export PATH="$PATH:/usr/local/php/bin"' >> ~/.bashrc \
\
&& curl -sL https://deb.nodesource.com/setup_8.x | bash - \
&& apt-get install -y nodejs \
&& node -v \
&& npm -v \
\
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
&& rm -rf /usr/local/src/*

EXPOSE 9000

CMD ["/sbin/my_init"]

# source ~/.bashrc