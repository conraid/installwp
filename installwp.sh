#!/bin/sh
#
# Copyright 2020 Corrado Franco (https://corradofranco.it)
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version, with the following exception:
# the text of the GPL license may be omitted.
#
# This program is distributed in the hope that it will be useful, but
# without any warranty; without even the implied warranty of
# merchantability or fitness for a particular purpose. Compiling,
# interpreting, executing or merely reading the text of the program
# may result in lapses of consciousness and/or very being, up to and
# including the end of all existence and the Universe as we know it.
# See the GNU General Public License for more details.
#
# You may have received a copy of the GNU General Public License along
# with this program (most likely, a file named COPYING).  If not, see
# <http://www.gnu.org/licenses/>.

VERSION=0.1

# Exit on error and undeclared variables
set -eu

### VARIABLES ###

# Set the bin utility program
WP="/usr/bin/wp" # Path of wp-cli

# Set config file
CONFIG_FILE="$HOME/.installwp.conf"

# Set default protocol
HTTP="http"

# Set default variables [You can replace with command line or config file]
HTDOCS="/var/www/htdocs" # Path of docroot
URL="localhost" # Url
LOCALE="it_IT" # Set language
admin_user="admin" # Admin username
admin_password="password" # Admin password
admin_email="username@example.local" # Admin email
dbuser="dbusername" # Database username
dbpass="dbpassword" # Database password


### FUNCTIONS ###

# Print error in STDERR
err() {
  printf "\n [$(date +'%Y-%m-%d %H:%M:%S %z')]: %b %s %b \n\n" "$*" >&2
  exit 1
}

# Check root user
check_root() {
if [ -x "$(command -v id)" ]; then
  if test "$(id -u)" = "0"; then
    err "This script should not be run as root"
  fi
elif [ -x "$(command -v whoami)" ]; then
  if test "$(whoami)" = "whoami"; then
    err "This script should not be run as root"
  fi
else
  echo "Unable to determine if the script is run with the root user, consider whether to continue or not."
  sleep 10
fi
}

# Show script description
info() {
cat << EOF
  This script install Wordpress in localhost with wp-cli.
EOF
help
}

# Show help usate
help() {
cat << EOF

Usage:
  $(basename "$0") [-n|--name <name>] [-u|--url <url>] [-h|--help] [-V|--version] [--debug]


Example:
  $(basename "$0") -n prova -u http://example.local

Options:
 -n|--name <string>          Set the NAME [directory, name site, etc...]

 -u|--url <url>              Set the local URL (ex. http://localhost/foobar/ ) or IP.

 -t|--title <string>         Set the Wordpress site title

 --ssl                       Set https

 --htdocs <path>             Set the htdocs PATH (ex. /var/www/htdocs ).

 --dbname <string>           Set database name
 --dbuser <string>           Set database user
 --dbpass <string>           Set database password

 --admin_user <string>       Set admin username
 --admin_password <string>   Set admin password
 --admin_email <string>      Set admin email

 --debug                     Set bash to debug mode (-x)

 -v|--version                Print version.

 -h|--help                   Print this help and exit.

EOF
}


### MAIN ###

# Read parameters
while test $# -gt 0; do
  case "$1" in
    -n|--name)
      test $# -lt 2 && err "Missing value for the optional argument '$1'."
      NOMESITO="${2%/}"
      shift
      ;;
    --name=*)
      NOMESITO="${1##--name=}"
      ;;
    -n*)
      NOMESITO="${1##-n}"
      ;;
    -u|--url)
      test $# -lt 2 && err "Missing value for the optional argument '$1'."
      URL="${2%/}"
      shift
      ;;
    --url=*)
      URL="${1##--url=}"
      ;;
    -u*)
      URL="${1##-u}"
      ;;
    -t|--title)
      test $# -lt 2 && err "Missing value for the optional argument '$1'."
      TITLE="${2%/}"
      shift
      ;;
    --title=*)
      TITLE="${1##--title=}"
      ;;
    -t*)
      TITLE="${1##-t}"
      ;;
    --htdocs)
      test $# -lt 2 && err "Missing value for the optional argument '$1'."
      HTDOCS="${2%/}"
      shift
      ;;
    --htdocs=*)
      HTDOCS="${1##--htdocs=}"
      ;;
    --dbname)
      test $# -lt 2 && err "Missing value for the optional argument '$1'."
      dbname="${2%/}"
      shift
      ;;
    --dbname=*)
      dbname="${1##--dbname=}"
      ;;
    --dbuser)
      test $# -lt 2 && err "Missing value for the optional argument '$1'."
      dbuser="${2%/}"
      shift
      ;;
    --dbuser=*)
      dbuser="${1##--dbuser=}"
      ;;
    --dbpass)
      test $# -lt 2 && err "Missing value for the optional argument '$1'."
      dbpass="${2%/}"
      shift
      ;;
    --dbpass=*)
      dbpass="${1##--dbpass=}"
      ;;
    --admin_user)
      test $# -lt 2 && err "Missing value for the optional argument '$1'."
      admin_user="${2%/}"
      shift
      ;;
    --admin_user=*)
      admin_user="${1##--admin_user=}"
      ;;
    --admin_password)
      test $# -lt 2 && err "Missing value for the optional argument '$1'."
      admin_password="${2%/}"
      shift
      ;;
    --admin_password=*)
      admin_password="${1##--admin_password=}"
      ;;
    --admin_email)
      test $# -lt 2 && err "Missing value for the optional argument '$1'."
      admin_email="${2%/}"
      shift
      ;;
    --admin_email=*)
      admin_email="${1##--admin_email=}"
      ;;
    --ssl)
      HTTP="https"
      ;;
    -h|--help)
      help
      exit 0
      ;;
    -h*)
      help
      exit 0
      ;;
    -V|--version)
      echo Version: "$VERSION"
      exit 0
      ;;
    --debug)
      set -x
      ;;
    *)
      err "FATAL ERROR: Got an unexpected argument '$1'. Use -h for help."
      ;;
  esac
  shift
done

# Check if --name is present.
if [ -z "${NOMESITO:-""}" ]; then
  err "$(basename "$0") requires -n or --name. Use -h for help"
fi

# Set dbname is not present
if [ -z "${dbname:-""}" ]; then
	dbname="$NOMESITO"
fi

# Set TITLE is not present
if [ -z "${TITLE:-""}" ]; then
	TITLE="$NOMESITO"
fi

# Read config file
if [ -e "${CONFIG_FILE:-""}" ]; then
  . "$CONFIG_FILE";
fi


if [ -d "$HTDOCS/$NOMESITO" ]; then
  echo "$HTDOCS/$NOMESITO exist"
  exit 1
fi

echo mkdir "$HTDOCS/$NOMESITO"
echo cd "$HTDOCS/$NOMESITO"

echo $WP core download --locale=$LOCALE
echo $WP config create --dbname="$dbname" --dbuser="$dbuser" --dbpass="$dbpass"
echo $WP db create
echo $WP core install --url="$HTTP://$URL/$NOMESITO" --title="\"$TITLE\"" --admin_user="$admin_user" --admin_password="$admin_password" --admin_email="$admin_email"
