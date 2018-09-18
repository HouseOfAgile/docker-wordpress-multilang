FROM houseofagile/docker-nginx-php-fpm:php5


MAINTAINER Meillaud Jean-Christophe (jc@houseofagile.com)

RUN apt-get install -y pwgen \
  mysql-client

# get a default nginx file
COPY config/nginx/restrictions.conf /etc/nginx/
COPY config/nginx/default-wordpress-nginx.conf /root/

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf && \
  rm /etc/nginx/sites-enabled/default && \
  sed -i -e "s/^upload_max_filesize\s*=\s*2M/upload_max_filesize = 20M/" /etc/php5/fpm/php.ini && \
  sed -i -e "s/^post_max_size\s*=\s*8M/post_max_size = 20M/" /etc/php5/fpm/php.ini && \
  sed -i 's#%%php_fpm_sock_file%%#/var/run/php/php5-fpm.sock#g' /root/default-wordpress-nginx.conf

ADD init_wordpress.sh /etc/my_init.d/init_wordpress.sh
ADD utils_wordpress.sh /root/utils_wordpress.sh

ADD ./config/projects /root/projects
ADD ./config/ssh-keys /root/ssh-keys
EXPOSE 80

CMD ["/sbin/my_init"]
