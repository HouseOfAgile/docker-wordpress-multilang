#!/bin/bash

function update_wordpress() {
  curl -SsL http://wordpress.org/latest.tar.gz -o /root/wordpress/latest.tar.gz
}


function deploy_wordpress() {
  wp_name=$1
  wp_lang=${2:-"EN_en"}
  wp_host=${3:-"localhost"}
  if [ ! -d /usr/share/nginx/$wp_name ]; then
    mkdir /usr/share/nginx/$wp_name
    tar --strip-components=1 -xzf /root/wordpress/latest.tar.gz -C /usr/share/nginx/$wp_name
  fi
  if [ ! -f /usr/share/nginx/$wp_name/wp-config.php ]; then
    # mysql username should be shorter than 15 characters
    short_name=`echo $wp_name |cut -c1-11`
    WORDPRESS_DB_NAME="wordpress_$short_name"
    WORDPRESS_DB_USER="wp_$short_name"
    WORDPRESS_DB_PASSWORD=`pwgen -c -n -1 12`

    sed -e "s/database_name_here/$WORDPRESS_DB_NAME/
    s/username_here/$WORDPRESS_DB_USER/
    s/password_here/$WORDPRESS_DB_PASSWORD/
    s/localhost/$MYSQL_HOST/
    s/define('WPLANG', '');/define('WPLANG', '$wp_lang');/
    /'AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
    /'SECURE_AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
    /'LOGGED_IN_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
    /'NONCE_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
    /'AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
    /'SECURE_AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
    /'LOGGED_IN_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
    /'NONCE_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
    /Happy blogging/s/$/\nif (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) \&\& \$_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https')\n  \$_SERVER['HTTPS'] = 'on';\n/" /usr/share/nginx/$wp_name/wp-config-sample.php > /usr/share/nginx/$wp_name/wp-config.php
    
    # Download nginx helper plugin
    #curl -O `curl -i -s http://wordpress.org/plugins/nginx-helper/ | egrep -o "http://downloads.wordpress.org/plugin/[^']+"`
    #unzip -o nginx-helper.*.zip -d /usr/share/nginx/$wp_name/wp-content/plugins
    #chown -R www-data:www-data /usr/share/nginx/$wp_name/wp-content/plugins/nginx-helper

    # Activate nginx plugin and set up pretty permalink structure once logged in
    cat << ENDL >> /usr/share/nginx/$wp_name/wp-config.php
\$plugins = get_option( 'active_plugins' );
if ( count( \$plugins ) === 0 ) {
  require_once(ABSPATH .'/wp-admin/includes/plugin.php');
  \$wp_rewrite->set_permalink_structure( '/%postname%/' );
  \$pluginsToActivate = array( 'nginx-helper/nginx-helper.php' );
  foreach ( \$pluginsToActivate as \$plugin ) {
  if ( !in_array( \$plugin, \$plugins ) ) {
    activate_plugin( '/usr/share/nginx/www/wp-content/plugins/' . \$plugin );
  }
  }
}
ENDL
    cat /root/default-wordpress-nginx.conf | sed "s/__project_name__/$wp_name/g;s#__project_path__#/usr/share/nginx/$wp_name#g;s/__project_hosts__/$wp_host/g"  > /etc/nginx/sites-available/project_$wp_name.conf
    ln -s /etc/nginx/sites-available/project_$wp_name.conf /etc/nginx/sites-enabled/project_$wp_name.conf
    service nginx reload

    chown -R www-data:www-data /usr/share/nginx/$wp_name

    MYSQL_PASSWORD=${MYSQL_SERVER_ENV_MYSQL_ROOT_PASSWORD:-$MYSQL_PASSWORD}
    MYSQL_USER=${MYSQL_USER:-"root"}
    MYSQL_HOST=${MYSQL_SERVER_PORT_3306_TCP_ADDR=:-$MYSQL_HOST}
    [ $MYSQL_PASSWORD"x" == "x" || $MYSQL_USER"x" == "x" || $MYSQL_HOST"x" == "x" ] && echo "Can't find Mysql env variables"&& exit
    
    echo "Create Database"
    mysql -h$MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME;CREATE DATABASE $WORDPRESS_DB_NAME;"
    echo "Add user $WORDPRESS_DB_USER"
    mysql -h$MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO '$WORDPRESS_DB_USER'@'%' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'; FLUSH PRIVILEGES;"
  fi
  
  #This is so the passwords show up in logs. 
  echo "Wordpress installed for $wp_name"
  echo "- Wordpress User created: $WORDPRESS_DB_USER"
  echo "- Mysql Database created: $WORDPRESS_DB_NAME"
  echo "- Wordpress User password: $WORDPRESS_DB_PASSWORD"
}
