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
STATIC_FILES_PATH="$WEB_ROOT/images";
SETTINGS_FILES_PATH="$WEB_ROOT/configuration.php";

#Create static directory
if [ ! -d "$STATIC_FILES_PATH" ]; then
  mkdir -p $STATIC_FILES_PATH;
fi;


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

#== Create configuration files
if [[ ! -f "$SETTINGS_FILES_PATH" ]]; then
  echo 'Create configuration file ....'
  sudo cp $APP_ROOT/.devpanel/configuration.php $SETTINGS_FILES_PATH
fi

#== Update permission
echo "Update permission ...."
mkdir -p "$STATIC_FILES_PATH"
sudo chown -R $APACHE_RUN_USER:$APACHE_RUN_GROUP $STATIC_FILES_PATH
mkdir -p "$WEB_ROOT/tmp"
sudo chown -R $APACHE_RUN_USER:$APACHE_RUN_GROUP "$WEB_ROOT/tmp"
mkdir -p "$WEB_ROOT/administrator/cache"
sudo chown -R $APACHE_RUN_USER:$APACHE_RUN_GROUP "$WEB_ROOT/administrator/cache"


