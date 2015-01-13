FROM centos:centos6
MAINTAINER pepechoko

RUN yum update -y
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm

RUN yum install -y --enablerepo=epel \
   re2c \
   libmcrypt \
   libmcrypt-devel

RUN yum install -y \
  ksh \
  bison \
  bison-devel \
  bzip2-devel \
  curl-devel \
  enchant-devel \
  freetype-devel \
  gcc \
  git \
  gmp-devel \
  httpd \
  httpd-devel \
  libXpm \
  libXpm-devel \
  libc-client-devel \
  libcurl-devel \
  libicu-devel \
  libjpeg-turbo-devel \
  libpng-devel \
  libtidy-devel \
  libtool-ltdl-devel \
  libxml2 \
  libxml2-devel \
  libxslt-devel \
  net-snmp \
  net-snmp-devel \
  oniguruma-devel \
  openssl-devel \
  readline-devel \
  t1lib \
  t1lib-devel \
  which \
  wget

## add phpenv group
RUN groupadd phpenv

# Install PHPenv
RUN \
  cd /usr/local && \
  git clone git://github.com/phpenv/phpenv.git && \
  chgrp -R phpenv /usr/local/phpenv && \
  chmod -R g+rwxXs /usr/local/phpenv && \
  cd /usr/local/phpenv && \
  git reset --hard origin/master && \
  exec $SHELL && \
  /usr/local/phpenv/bin/phpenv rehash

# install PHP-build
RUN \
  mkdir /usr/local/phpenv/plugins && \
  cd /usr/local/phpenv/plugins && \
  git clone https://github.com/CHH/php-build.git && \
  chgrp -R phpenv /usr/local/phpenv/plugins/php-build && \
  chmod -R g+rwxXs /usr/local/phpenv/plugins/php-build

## 
# Complete ENV
ENV PHPENV_ROOT /usr/local/phpenv
ENV PATH /usr/local/phpenv/bin:/usr/local/phpenv/shims:$PATH
ADD phpenv.sh /etc/profile.d/phpenv.sh
RUN chmod +x /etc/profile.d/phpenv.sh
RUN eval "(phpenv init -)"

RUN chgrp -R phpenv /usr/local/phpenv
RUN chmod -R g+rwxXs /usr/local/phpenv

# Install multiple versions of php
RUN perl -i -pe 's/--enable-fpm\n//g' /usr/local/phpenv/plugins/php-build/share/php-build/default_configure_options
RUN sed -i -e '$s/$/\n--with-apxs2=\/usr\/sbin\/apxs/' /usr/local/phpenv/plugins/php-build/share/php-build/default_configure_options

ADD versions.txt /usr/local/phpenv/versions.txt
# RUN xargs -L 1 -i ksh -c 'phpenv install php-{}; mv /usr/lib/httpd/modules/libphp5.so /usr/local/phpenv/versions/{}/' < /usr/local/phpenv/versions.txt
RUN xargs -L 1 -i ksh -c 'phpenv install php-{}' < /usr/local/phpenv/versions.txt

# settgin global use PHP
RUN \
  phpenv global 5.6.4 && \
  phpenv rehash

# install phpenv-apache-version
RUN \
  cd /usr/local/phpenv/plugins && \
  git clone https://github.com/garamon/phpenv-apache-version && \
  chgrp -R phpenv /usr/local/phpenv/plugins/phpenv-apache-version && \
  chmod -R g+rwxXs /usr/local/phpenv/plugins/phpenv-apache-version

# php-build-plugin-phpunit
RUN \
  cd /user/local/phpenv/plugins/php-build/share/php-build/after-install.d \
  curl -o phpunit https://raw.github.com/CHH/php-build-plugin-phpunit/master/share/php-build/after-install.d/phpunit && \
  chgrp -R phpenv phpunit && \
  chmod -R g+rwxXs phpunit
