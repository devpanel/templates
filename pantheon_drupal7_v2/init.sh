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

#== Composer install.
if [[ -f "$APP_ROOT/composer.json" ]]; then
  cd $APP_ROOT && composer install;
fi
if [[ -f "$WEB_ROOT/composer.json" ]]; then
  cd $WEB_ROOT && composer install;
fi

# #Securing file permissions and ownership
# #https://www.drupal.org/docs/security-in-drupal/securing-file-permissions-and-ownership
[[ ! -d "$WEB_ROOT/sites/default/files" ]] && sudo mkdir --mode 775 "$WEB_ROOT/sites/default/files"
sudo chown -R www:www-data $APP_ROOT;
sudo chown -R www-data:www-data $WEB_ROOT/sites/default/files;

sudo cp $APP_ROOT/.devpanel/drupal-settings.php $SETTINGS_FILES_PATH
#== Drush Site Install
if [[ $(mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME -e "show tables;") == '' ]]; then
  echo "Site installing ..."
  cd $APP_ROOT
  drush si --account-name=devpanel --account-pass=devpanel --site-name="Drupal 7" --db-url=mysql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME -y
  drush cc all
fi

# # Setup settings.php file
SETTINGS_FILES_PATH="$WEB_ROOT/sites/default/settings.php"
sudo cp $APP_ROOT/.devpanel/drupal-settings.php $SETTINGS_FILES_PATH
sudo chown www:www-data $SETTINGS_FILES_PATH
sudo chmod 664 $SETTINGS_FILES_PATH
