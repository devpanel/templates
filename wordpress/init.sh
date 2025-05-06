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

#== Create wp-config files
cp $APP_ROOT/.devpanel/wp-config.php $WEB_ROOT/wp-config.php

#== Config permission
cd $WEB_ROOT;
find wp-content -type f -exec chmod g+w {} +;
find wp-content -type d -exec chmod g+ws {} +;

chown -R www:www-data $APP_ROOT/;
chmod -R 777 $WEB_ROOT/wp-content;