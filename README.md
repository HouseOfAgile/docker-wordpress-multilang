## docker-wordpress-multilang

Deploy wordpress latest version in various language within docker, nginx and php-fpm.

## usage
Create a file for each wordpress you want to deploy with the following content:

```
# default name
wp_name=dummy_wp

# Default language
wp_lang=EN_en

# default host for the installation within the container
wp_host=wp_dummy.localhost

# root user
MYSQL_ROOT_USER=root

# mysql root password
MYSQL_ROOT_PASSWORD=password

# mysql host (should be within the same docker network)
MYSQL_HOST=172.17.0.3

```

Then build your image and run it:
    docker build -f Dockerfile.php7 -t "houseofagile/docker-wordpress-multilang:php7" .
    docker run -d --name dev-wordpress -P houseofagile/docker-wordpress-multilang:php7

If you are missing a mysql server : ```docker run --name dev-mysql -e MYSQL_ROOT_PASSWORD=password -d mysql:5.7```

## Raw usage with php5 or php7 versions

Use the php version you want
- [`Dockerfile for php 5.6`](TBD)
- [`Dockerfile for php 7.2`](TBD)

## Next steps
* Add support for wp cli ?
