#
#
#
#
#
#
#

set -o nounset
set -o errexit
set -eu

# Installer Docker Validator ==================================================================

docker run -dit --name rippledvalidator -p 51235:51235 -v /keystore/:/keystore/ xrptipbot/rippledvalidator

#============================================================================Docker Validator

# Functions ==============================================

function coloredEcho(){
    local exp=$1;
    local color=$2;
    if ! [[ $color =~ '^[0-9]$' ]] ; then
       case $(echo $color | tr '[:upper:]' '[:lower:]') in
        black) color=0 ;;
        red) color=1 ;;
        green) color=2 ;;
        yellow) color=3 ;;
        blue) color=4 ;;
        magenta) color=5 ;;
        cyan) color=6 ;;
        white|*) color=7 ;; # white or invalid color
       esac
    fi
    tput setaf $color;
    echo -e $exp;
    tput sgr0;
}

# ============================================== Functions

# Install Docker Verification==============================

ufw insert 1 allow in on eth0 to any port 80 proto tcp

docker run --rm -it -v /keystore/:/keystore/ -p 80:80 xrptipbot/verify-rippledvalidator

#================================================Install Docker Verification
sudo apt-get update
#Nginx ==============================================

coloredEcho "\n[!] Installing Nginx ...\n" green
# Nginx
sudo apt-get install nginx

if pgrep systemd-journal; then
    systemctl enable nginx
else
    /etc/init.d/nginx enable
fi

if [[ ! -e /etc/nginx/default.d ]]; then
	mkdir /etc/nginx/default.d
fi

if [[ ! -e /etc/nginx/conf.d ]]; then
	mkdir /etc/nginx/conf.d
fi

echo "server {
  listen 443 ssl;
  ssl_certificate /keystore/$HOSTNAME-fullchain.pem;
  ssl_certificate_key /keystore/$HOSTNAME-privkey.pem;
  ssl_protocols TLSv1.2;
  ssl_prefer_server_ciphers on;
  ssl_dhparam /etc/nginx/dhparam.pem;
  ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;
  ssl_ecdh_curve secp384r1;
  ssl_session_timeout 10m;
  ssl_session_cache shared:SSL:10m;
  ssl_session_tickets off;
  ssl_stapling on;
  ssl_stapling_verify on;
  resolver 1.1.1.1 1.0.0.1 valid=300s;
  resolver_timeout 5s;
  add_header Strict-Transport-Security 'max-age=63072000; includeSubDomains; preload';
  add_header X-Frame-Options DENY;
  add_header X-Content-Type-Options nosniff;
  add_header X-XSS-Protection '1; mode=block';
}" > /etc/nginx/conf.d/validator.conf


if pgrep systemd-journal; then
    systemctl restart nginx
else
    /etc/init.d/nginx restart
fi

# ============================================== Nginx


coloredEcho "\n[!]Congratulations , it's look like Rippled Validator installed successfuly!" green

coloredEcho "\n[!]Now for Verification!" green





