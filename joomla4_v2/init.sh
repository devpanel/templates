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
INSTALL_DIR="$WEB_ROOT/installation";
CACHE_DIR="$WEB_ROOT/administrator/cache";
STATIC_FILES_PATH="$WEB_ROOT/images";
SETTINGS_FILES_PATH="$WEB_ROOT/configuration.php";



#Create static directory
if [ ! -d "$STATIC_FILES_PATH" ]; then
  echo "Create static directory ..."
  mkdir -p $STATIC_FILES_PATH;
fi;

if [ ! -d "$INSTALL_DIR" ]; then
  # Download source code
  wget -O /tmp/joomla.zip https://downloads.joomla.org/cms/joomla4/4-4-10/Joomla_4-4-10-Stable-Full_Package.zip?format=zip
  unzip -o /tmp/joomla.zip -d $APP_ROOT
fi
USER_ADMIN="devpanel";
USER_PASSWORD="Devpanel@12345";
if [[ $(mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME -e "show tables;") == '' ]]; then
  echo "Initial site ...";
  rm -rf configuration.php
  php installation/joomla.php install --site-name="Joomla 4.4.1" \
  --admin-user=$USER_ADMIN \
  --admin-email="bot@devpanel.com" \
  --admin-username=$USER_ADMIN \
  --admin-password=$USER_PASSWORD \
  --db-type=mysql \
  --db-host=$DB_HOST:$DB_PORT \
  --db-user=$DB_USER \
  --db-pass=$DB_PASSWORD \
  --db-name=$DB_NAME \
  --db-prefix="joomla_" \
  --db-encryption=0

  echo 'Create config file ....'
  sudo cp $APP_ROOT/.devpanel/configuration.php $SETTINGS_FILES_PATH

  cat > .readme.txt << EOF
# The temporary username and password for administrator. Please update as soon as possible for secure.
admin: $USER_ADMIN
password: $USER_PASSWORD
EOF
fi

#== Update gitignore
cp .devpanel/gitignore .gitignore

#== Update permission
echo "Update permission ...."
mkdir -p "$STATIC_FILES_PATH"
sudo chown -R $APACHE_RUN_USER:$APACHE_RUN_GROUP $STATIC_FILES_PATH
mkdir -p "$WEB_ROOT/tmp"
sudo chown -R $APACHE_RUN_USER:$APACHE_RUN_GROUP "$WEB_ROOT/tmp"
mkdir -p "$WEB_ROOT/administrator/cache"
sudo chown -R $APACHE_RUN_USER:$APACHE_RUN_GROUP "$WEB_ROOT/administrator/cache"


