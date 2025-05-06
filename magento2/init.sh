#/bin/bash
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

#== grant executed mode for magento 
chmod u+x $WEB_ROOT/bin/magento;

#== Config permission
cd $WEB_ROOT;
find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +;
find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +;

#== Setup Installed Application
cd $WEB_ROOT;
php bin/magento setup:install \
  --admin-user="$MAGENTO_ADMIN" \
  --admin-password="$MAGENTO_ADMINPWD" \
  --backend-frontname="$MAGENTO_BE_FRONTNAME" \
  --base-url="http://$MAGENTO_BASEURL" \
  --base-url-secure="https://$MAGENTO_BASEURL" \
  --admin-firstname="Magento" \
  --admin-lastname="User" \
  --admin-email="user@example.com" \
  --db-host="$DB_HOST" \
  --db-name="$DB_NAME" \
  --db-password="$DB_PASSWORD" \
  --db-user="$DB_USER" \
  --language="en_US" \
  --currency="USD" \
  --use-secure-admin="1" \
  --use-rewrites="1" \
  --timezone="America/Chicago";

php bin/magento --version;
php bin/magento deploy:mode:set developer;
php -d memory_limit=-1 bin/magento indexer:reindex;
php -d memory_limit=-1 bin/magento cache:flush;

chown -R www:www-data $APP_ROOT/;