# Installwp

Install Wordpress site in localhost with WP-CLI

# Usage

Usage:
  installwp.sh [-n|--name <name>] [-u|--url <url>] [-h|--help] [-V|--version] [-vv|--verbose] [--debug]

Example:
  installwp.sh -n prova -u http://example.local

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

