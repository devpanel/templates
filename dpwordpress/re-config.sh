#!/bin/bash

#== If webRoot has not been difined, we will set appRoot to webRoot
if [[ ! -n "$WEB_ROOT" ]]; then
  export WEB_ROOT=$APP_ROOT
fi

STATIC_FILES_PATH="$WEB_ROOT/wp-content/";

#Create static directory
if [ ! -d "$STATIC_FILES_PATH" ]; then
  mkdir -p $STATIC_FILES_PATH;
fi;

echo "Extract static files..."
if [[ -f "$APP_ROOT/.devpanel/dumps/files.tgz" ]]; then
  tar xzf "$APP_ROOT/.devpanel/dumps/files.tgz" -C $STATIC_FILES_PATH;
fi

echo "Import mysql files..."
if [[ -f "$APP_ROOT/.devpanel/dumps/db.sql.tgz" ]]; then
  SQLFILE=$(tar tzf $APP_ROOT/.devpanel/dumps/db.sql.tgz)
  tar xzf "$APP_ROOT/.devpanel/dumps/db.sql.tgz" -C /tmp/
  mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME < /tmp/$SQLFILE
  rm /tmp/$SQLFILE
fi

#== Create wp-config files
cp $APP_ROOT/.devpanel/wp-config.php $WEB_ROOT/wp-config.php

#== Config permission
cd $WEB_ROOT;
chmod -R 755 wp-content;

chown -R 1000:82 $APP_ROOT/;