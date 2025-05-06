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

BEDROCK_ROOT=$(dirname $WEB_ROOT)

#Create static directory
if [ ! -d "$STATIC_FILES_PATH" ]; then
  mkdir -p $STATIC_FILES_PATH
fi

echo "Extract static files..."
if [[ -f "$APP_ROOT/.devpanel/dumps/files.tgz" ]]; then
  tar xzf "$APP_ROOT/.devpanel/dumps/files.tgz" -C $STATIC_FILES_PATH
fi

echo "Import mysql files..."
if [[ -f "$APP_ROOT/.devpanel/dumps/db.sql.tgz" ]]; then
  SQLFILE=$(tar tzf $APP_ROOT/.devpanel/dumps/db.sql.tgz)
  tar xzf "$APP_ROOT/.devpanel/dumps/db.sql.tgz" -C /tmp/
  mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME </tmp/$SQLFILE
  rm /tmp/$SQLFILE
fi

# Backup .env file
mv $BEDROCK_ROOT/.env $BEDROCK_ROOT/.env.old

# Copy .env and Generate salt
cp $APP_ROOT/.devpanel/dot.env.example $BEDROCK_ROOT/.env
curl -s https://api.wordpress.org/secret-key/1.1/salt | sed "s/^define('\(.*\)',\ *'\(.*\)');$/\1='\2'/g" >> $BEDROCK_ROOT/.env

#== Config permission
cd $BEDROCK_ROOT
chown -R www:www-data $APP_ROOT/
