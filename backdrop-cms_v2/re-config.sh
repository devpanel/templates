#!/bin/bash
# ---------------------------------------------------------------------
# Copyright (C) 2021 DevPanel
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation version 3 of the
# License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# For GNU Affero General Public License see <https://www.gnu.org/licenses/>.
# ----------------------------------------------------------------------

if [[ ! -n "$APACHE_RUN_USER" ]]; then
  export APACHE_RUN_USER=www-data  
fi
if [[ ! -n "$APACHE_RUN_GROUP" ]]; then
  export APACHE_RUN_GROUP=www-data
fi

#== If webRoot has not been difined, we will set appRoot to webRoot
if [[ ! -n "$WEB_ROOT" ]]; then
  export WEB_ROOT=$APP_ROOT
fi

STATIC_FILES_PATH="$WEB_ROOT/files"
SETTINGS_FILES_PATH="$WEB_ROOT/settings.local.php"

#== Extract static files
if [[ $(mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME -e "show tables;") == '' ]]; then
  if [[ -f "$APP_ROOT/.devpanel/dumps/files.tgz" ]]; then
    echo  'Extract static files ...'
    sudo mkdir -p $STATIC_FILES_PATH
    sudo tar xzf "$APP_ROOT/.devpanel/dumps/files.tgz" -C $STATIC_FILES_PATH
  fi

  #== Import mysql files
  if [[ -f "$APP_ROOT/.devpanel/dumps/db.sql.tgz" ]]; then
    echo  'Extract mysql files ...'
    SQLFILE=$(tar tzf $APP_ROOT/.devpanel/dumps/db.sql.tgz)
    tar xzf "$APP_ROOT/.devpanel/dumps/db.sql.tgz" -C /tmp/
    mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME < /tmp/$SQLFILE
    rm /tmp/$SQLFILE
  fi
fi

#== Create settings file
if [[ ! -f "$SETTINGS_FILES_PATH" ]]; then
  echo "Create settings file ..."
  sudo cp $APP_ROOT/.devpanel/backdrop-cms-settings.local.php $SETTINGS_FILES_PATH
fi


#== Point config directory
echo "Point config directory ..."
if [[ -d $(find $STATIC_FILES_PATH -maxdepth 1 -type d -name  'config_*' |  head -n 1) ]];  then
  CONFIG_DIR=$(find $STATIC_FILES_PATH -maxdepth 1 -type d -name  'config_*'| head -n 1 | sed 's/\//\\\//g')
fi

if [[ -d $(find $APP_ROOT -maxdepth 1 -type d -name  'config_*' |  head -n 1) ]];  then
  CONFIG_DIR=$(find $APP_ROOT -maxdepth 1 -type d -name  'config_*'| head -n 1 | sed 's/\//\\\//g')
fi

if [[ $CONFIG_DIR != '' ]]; then
  echo 'Create config settings ...';
  sed -i -e "s/^\$config_directories\['active'\].*/\$config_directories\['active'\] = '$CONFIG_DIR\/active';/g" $SETTINGS_FILES_PATH
  sed -i -e "s/^\$config_directories\['staging'\].*/\$config_directories\['staging'\] = '$CONFIG_DIR\/staging';/g" $SETTINGS_FILES_PATH
fi

echo "Update permission ..."
sudo chown -R $APACHE_RUN_USER:$APACHE_RUN_GROUP $STATIC_FILES_PATH
sudo chown www:www $SETTINGS_FILES_PATH
sudo chmod 664 $SETTINGS_FILES_PATH
bee cron
drush cc all

#== Change permissions for UI downloads
cd $APP_ROOT
# Change all directory permissions to 775 "rwxrwxr-x"
sudo find * -type d -exec chmod ug=rwx,o=rx '{}' \;
# Change all file permissions to 664 "rw-rw-r--"
sudo find * -type f -exec chmod ug=rw,o=r '{}' \;
# Change all .txt except robots .txt to 600 "rw-------"
sudo find * -type f -iname "*.txt" -exec chmod u=rw,go= '{}' \;
sudo chmod u=rw,go=r 'robots.txt' ;
# Change all .md file permissions to 600 "rw-------"
sudo find * -type f -iname "README.md" -exec chmod u=rw,go= '{}' \;
# Change all .patch and *.orig files to 600 "rw-------"
sudo find * -type f -iname "*.patch" -exec chmod u=rw,go= '{}' \;
sudo find * -type f -iname "*.orig" -exec chmod u=rw,go= '{}' \;
