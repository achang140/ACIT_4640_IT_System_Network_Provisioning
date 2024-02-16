#!/usr/bin/env bash

##-#-#-#-#-#-#-#-#-#-#-#-#-##
#  ACIT 4640 Assignment 1  # 
# Amanda Chang - A01294905 #
##-#-#-#-#-#-#-#-#-#-#-#-#-##

# set -u or -o nounset - Prevent script from running if it tries to use undefined variables 
set nounset 

# Package installations do not prompt for user input 
export DEBIAN_FRONTEND=noninteractive
# Used by needrestart utility to check which daemons need to be restarted after library upgrades 
export NEEDRESTART_MODE=a

# Packages required for the application 
# -r = Read-only, -a = Array 
declare -ra APP_PACKAGES=("git" "nginx" "pkg-config")
# Root directory for the web server 
declare -r WEB_ROOT="/var/www/html" # NGINX Default Page located


function package_setup() {
  # Update package list and upgrade packages
  apt-get update -y
  apt-get upgrade -y

  # Install packages
  apt-get install -y "${APP_PACKAGES[@]}"
}


function web_setup() {

  # Create a basic index.html file
  tee "${WEB_ROOT}/index.html" <<EOF >/dev/null
<html>
  <head>
    <title>ACIT 4640 Assignment 1</title>
  </head>
  <body>
    <h1>ACIT 4640 Assignment 1</h1>
    <p>Hello!</p>
    <p>Amanda Chang (A01294905)</p>
  </body>
</html>
EOF

  systemctl restart nginx
  systemctl enable nginx

}

package_setup
web_setup
