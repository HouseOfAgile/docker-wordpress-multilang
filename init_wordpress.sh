#!/bin/bash

# Copy ssh keys if there are presents
if [ -d "/root/ssh-keys" -a "$(ls /root/ssh-keys)" ]; then
  mkdir -p /root/.ssh
  cp /root/ssh-keys/* /root/.ssh
  rm -rf /root/ssh-keys
fi

mkdir /root/wordpress

source /root/utils_wordpress.sh

install_wordpress

for wp_project in `find /root/projects/ -not -path '*/\.*' -type f -printf "%f\n"`
do
  source /root/projects/$wp_project
  deploy_wordpress $wp_project ${WP_LANG:-"ES_es"} ${WP_HOST:-"localhost"}
done
