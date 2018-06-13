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

clear
echo 'Welcome to codius installer!'
echo
echo "I need to ask you a few questions before starting the setup."
echo "You can leave the default options and just press enter if you are ok with them."
echo


# Server Ip Address
echo "[+] First, provide the IPv4 address of the network interface"
# Autodetect IP address and pre-fill for the user
IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
read -p "IP address: " -e -i $IP IP
# If $IP is a private IP address, the server must be behind NAT
if echo "$IP" | grep -qE '^(10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.|192\.168)'; then
    echo
    echo "This server is behind NAT. What is the public IPv4 address?"
    read -p "Public IP address: " -e PUBLICIP
fi

# Hostname
echo "[+] What is your Validator hostname?"
read -p "Hostname: " -e -i validator.example.com HOSTNAME
if [[ -z "$HOSTNAME" ]]; then
   printf '%s\n' "No Hostname entered , exiting ..."
   exit 1
fi

# Set hostname 
hostnamectl set-hostname $HOSTNAME

# Email for certbot
echo "[+] What is your Email address ?"
read -p "Email: " -e EMAIL

if [[ -z "$EMAIL" ]]; then
    printf '%s\n' "No Email entered, exiting..."
    exit 1
fi

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



# Nginx ==============================================

coloredEcho "\n[!] Installing Nginx ...\n" green
# Nginx
sudo yum install -y nginx

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
  server_name $HOSTNAME;
  ssl_certificate /etc/letsencrypt/live/$HOSTNAME/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$HOSTNAME/privkey.pem;
  ssl_protocols TLSv1.2;

  }
}" > /etc/nginx/conf.d/validator.conf


if pgrep systemd-journal; then
    systemctl restart nginx
else
    /etc/init.d/nginx restart
fi

# ============================================== Nginx
#Key Signing=====================

docker exec rippledvalidator /keystore/finish_signing

#============================================Key Signing


coloredEcho "\n[!]Congratulations , it's look like Rippled Validator installed successfuly!" green

coloredEcho "\n[!]Now for Verification!" green





