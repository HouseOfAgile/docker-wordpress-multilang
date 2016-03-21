#!/bin/bash


# Copy ssh keys if there are presents
if [ -d "/root/ssh-keys" -a "$(ls /root/ssh-keys)" ]; then
  mkdir -p /root/.ssh
  cp /root/ssh-keys/* /root/.ssh
  rm -rf /root/ssh-keys
fi

mkdir /root/wordpress

source /root/utils_wordpress.sh

update_wordpress

for wp-project in `find /root/projects/ -type f -printf "%f\n"`
do
  source /root/projects/$wp-project
  deploy_wordpress $wp-project ${wp_lang:-"ES_es"}
done
