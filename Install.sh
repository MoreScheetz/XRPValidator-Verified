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


# CertBOt ==============================================

coloredEcho "\n[+] Generating certificate for ${HOSTNAME}\n" green
# certbot stuff
[ -d certbot ] && rm -rf certbot
git clone https://github.com/certbot/certbot
cd certbot
git checkout v0.23.0
./certbot-auto --noninteractive --os-packages-only
./tools/venv.sh > /dev/null
sudo ln -sf `pwd`/venv/bin/certbot /usr/local/bin/certbot
certbot certonly --manual -d "${HOSTNAME}" -d "*.${HOSTNAME}" --agree-tos --email "${EMAIL}" --preferred-challenges dns-01  --server https://acme-v02.api.letsencrypt.org/directory

# ============================================== CertBOt

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

echo 'return 301 https://$host$request_uri;' | sudo tee /etc/nginx/default.d/ssl-redirect.conf
sudo openssl dhparam -out /etc/nginx/dhparam.pem 2048


if [[ ! -e /etc/nginx/conf.d ]]; then
	mkdir /etc/nginx/conf.d
fi

echo "server {
  listen 443 ssl;
  ssl_certificate /etc/letsencrypt/live/$HOSTNAME/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$HOSTNAME/privkey.pem;
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
location / {
    proxy_pass http://127.0.0.1:51235;
    proxy_set_header Host $$host;
    proxy_set_header X-Forwarded-For $$remote_addr;
  }
}"


if pgrep systemd-journal; then
    systemctl restart nginx
else
    /etc/init.d/nginx restart
fi

# ============================================== Nginx
