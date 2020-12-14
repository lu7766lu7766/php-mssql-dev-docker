FROM php:7.3-apache

MAINTAINER Jac (lu7766lu7766@gmail.com)

# update package list
# RUN apt-get update -y

ENV ACCEPT_EULA=Y

# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

# Install selected extensions and other stuff
RUN apt-get update 
RUN apt-get install -y build-essential libssl-dev zlib1g-dev 
RUN apt-get install -y unixodbc-dev unixodbc 
RUN apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev libmcrypt-dev 
RUN apt-get -y --no-install-recommends install apt-utils libxml2-dev gnupg apt-transport-https 
RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install git
RUN apt-get update 
RUN apt-get -y install git 
RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install MS ODBC Driver for SQL Server
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - 
RUN curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list 
RUN apt-get update 
RUN apt-get -y --no-install-recommends install msodbcsql17 unixodbc-dev 
RUN pecl install sqlsrv 
RUN pecl install pdo_sqlsrv 
RUN echo "extension=pdo_sqlsrv.so" >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini 
RUN echo "extension=sqlsrv.so" >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-sqlsrv.ini 
RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN apt-get update -yqq 
RUN apt-get install -y --no-install-recommends openssl 
RUN sed -i 's,^\(MinProtocol[ ]*=\).*,\1'TLSv1.0',g' /etc/ssl/openssl.cnf 
RUN sed -i 's,^\(CipherString[ ]*=\).*,\1'DEFAULT@SECLEVEL=1',g' /etc/ssl/openssl.cnf
RUN rm -rf /var/lib/apt/lists/*

# gd
RUN docker-php-source extract
RUN cp /usr/src/php/ext/openssl/config0.m4 /usr/src/php/ext/openssl/config.m4

RUN docker-php-ext-configure gd --with-png-dir=/usr/include --with-jpeg-dir=/usr/include --with-freetype-dir=/usr/include/freetype2 
RUN docker-php-ext-install iconv 
RUN docker-php-ext-install gd 
# RUN docker-php-ext-install mbstring 

# xdebug
RUN pecl install  xdebug 
RUN docker-php-ext-enable xdebug

＃COPY apache2.conf /etc/apache2/
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN a2enmod rewrite

# /Users/lu7766/Documents/htdocs/Work/SuKuan
