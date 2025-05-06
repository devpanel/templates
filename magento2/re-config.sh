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

STATIC_FILES_PATH=$WEB_ROOT;

#Create static directory
if [ ! -d "$STATIC_FILES_PATH" ]; then
  mkdir -p $STATIC_FILES_PATH;
fi;

#== Extract static files
if [[ -f "$APP_ROOT/.devpanel/dumps/files.tgz" ]]; then
  tar xzf "$APP_ROOT/.devpanel/dumps/files.tgz" -C $STATIC_FILES_PATH;
fi
#== Import mysql files
if [[ -f "$APP_ROOT/.devpanel/dumps/db.sql.tgz" ]]; then
  SQLFILE=$(tar tzf $APP_ROOT/.devpanel/dumps/db.sql.tgz)
  tar xzf "$APP_ROOT/.devpanel/dumps/db.sql.tgz" -C /tmp/
  mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME < /tmp/$SQLFILE
  rm /tmp/$SQLFILE
fi

#== Composer install.
cd $APP_ROOT;
composer install;

#== grant executed mode for magento 
chmod u+x bin/magento;

#== Config permission
cd $WEB_ROOT;
find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +;
find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +;

#== Re-config magento configuration
cd $WEB_ROOT;
php bin/magento setup:config:set \
  --backend-frontname="$MAGENTO_BE_FRONTNAME" \
  --db-host="$DB_HOST" \
  --db-name="$DB_NAME" \
  --db-password="$DB_PASSWORD" \
  --db-user="$DB_USER" \
  --no-interaction;

MAGENTO_SECRET_KEY=$(php -r "\$arrENV = include('$(pwd)/app/etc/env.php'); echo \$arrENV['crypt']['key'];");

mysql --host="$DB_HOST" \
  --user="$DB_USER" \
  --password="$DB_PASSWORD" \
  --database="$DB_NAME" \
  --execute="UPDATE admin_user SET password = CONCAT(SHA2('${MAGENTO_SECRET_KEY}$MAGENTO_ADMINPWD', 256), ':$MAGENTO_SECRET_KEY:1') WHERE username='$MAGENTO_ADMINPWD';";

php bin/magento module:enable --all --clear-static-content;
php bin/magento setup:upgrade;
php bin/magento setup:di:compile;
php bin/magento setup:static-content:deploy -f;
php bin/magento cache:flush;

chown -R www:www-data $APP_ROOT/;