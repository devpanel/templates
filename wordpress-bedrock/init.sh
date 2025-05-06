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

#== Init bedrock
cd $BEDROCK_ROOT

# Create-project bedrock
rm -fR /tmp/bedrock && php -d memory_limit=-1 $(which composer) create-project roots/bedrock /tmp/bedrock
cp -r /tmp/bedrock/. $APP_ROOT

# Copy .env and Generate salt
cp $APP_ROOT/.devpanel/dot.env.example $BEDROCK_ROOT/.env
curl -s https://api.wordpress.org/secret-key/1.1/salt | sed "s/^define('\(.*\)',\ *'\(.*\)');$/\1='\2'/g" >> $BEDROCK_ROOT/.env

#==  Install blank wordpress
# Website info
WP_HOME=https://$DEVPANEL_HOSTNAME
WP_USER=devpanel
WP_PASSWORD=devpanel
WP_EMAIL=service@devpanel.com

# Install
cd $APP_ROOT

if ! $( wp core is-installed --allow-root ); then

	# Install wordpress
	wp core install \
    --title='WordPress on DevPanel' \
		--url=$WP_HOME \
		--admin_user=$WP_USER \
		--admin_password=$WP_PASSWORD \
		--admin_email=$WP_EMAIL \
		--skip-email \
		--allow-root \

fi

# refresh permalinks
wp rewrite structure '/%postname%/' --hard --allow-root

#== Config permission
cd $BEDROCK_ROOT
sudo chown -R www:www-data $APP_ROOT/