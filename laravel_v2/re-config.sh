#!/bin/bash
# ---------------------------------------------------------------------
# Copyright (C) 2021 DevPanel
#
# This program is free software: you can redistribute it and/or modify it
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, version 3 of the
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

#== If webRoot has not been defined, we will set appRoot to webRoot
if [[ ! -n "$WEB_ROOT" ]]; then
  export WEB_ROOT=$APP_ROOT
fi

cd $APP_ROOT
composer install
chmod +x /var/www/html/artisan
sudo chown -R www:www /var/www/html
sudo chmod -R 775 /var/www/html/storage
sudo chmod -R 775 /var/www/html/bootstrap/cache
sudo chown -R www:www /var/www/html/storage /var/www/html/bootstrap/cache
sudo chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache
php artisan config:clear
php artisan migrate --force
