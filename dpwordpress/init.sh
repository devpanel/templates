#!/bin/bash

#== If webRoot has not been difined, we will set appRoot to webRoot
if [[ ! -n "$WEB_ROOT" ]]; then
  export WEB_ROOT=$APP_ROOT
fi

#== Create wp-config files
cp $APP_ROOT/.devpanel/wp-config.php $WEB_ROOT/wp-config.php

#== Config permission
cd $WEB_ROOT;
find wp-content -type f -exec chmod g+w {} +;
find wp-content -type d -exec chmod g+ws {} +;

chown -R 1000:82 $APP_ROOT/;