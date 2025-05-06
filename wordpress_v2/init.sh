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

#== If webRoot has not been difined, we will set appRoot to webRoot
if [[ ! -n "$WEB_ROOT" ]]; then
  export WEB_ROOT=$APP_ROOT
fi

STATIC_FILES_PATH="$WEB_ROOT/wp-content/uploads";
SETTINGS_FILES_PATH="$WEB_ROOT/wp-config.php";

#Create static directory
if [ ! -d "$STATIC_FILES_PATH" ]; then
  echo "Create static directory ..."
  mkdir -p $STATIC_FILES_PATH;
fi;

#== Create wp-config files
if [[ ! -f "$SETTINGS_FILES_PATH" ]]; then
  echo 'Create wp-config file ....'
  sudo cp $APP_ROOT/.devpanel/wp-config.php $SETTINGS_FILES_PATH
fi

USER_ADMIN="admin";
USER_PASSWORD=$(openssl rand -hex 5);
if [[ $(mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME -e "show tables;") == '' ]]; then
  echo "Initial site ...";
  wp core install --url=$DP_HOSTNAME --title="Wordpress" --admin_user=$USER_ADMIN --admin_password=$USER_PASSWORD --admin_email=example@devpanel.com;
  echo "Show credential ...";
  wp post update 1 --url=$DP_HOSTNAME --post_title='Devpanel Initial Site' --post_content="Login admin --> username: $USER_ADMIN , password: $USER_PASSWORD"
fi
