#!/bin/bash

set -e

# Prompt for Samba Domain
read -p "Enter the Samba Domain (ex. Samdom ): " SAMBA_DOMAIN

# Prompt for Samba Realm
read -p "Enter the Samba Realm (ex Samdom.com ): " SAMBA_REALM

# Prompt for Samba Admin password
read -sp "Enter the Samba Admin password: " SAMBA_ADMIN_PASSWORD
echo 

# Prompt for Kerberos Password
read -sp "Enter the Kerberos Password: " KERBEROS_PASSWORD
echo 

# Prompt for IP of the host
read -p "Enter the IP of the AD DC host: " SAMBA_HOST_IP

# Prompt for IP of the host
read -p "Enter the IP of the DNS host (1.1.1.1 if empty): " DNS_HOST_IP
if [[ $DNS_HOST_IP ]]; then
    DNS_HOST_IP="1.1.1.1"
fi

# Prompt for IP of the host
read -p "Enter the IP of the NTP serveur (1.1.1.1 if empty): " NTP_SERVERS

# Prompt for TimeZonr of the host
read -p "What is your time zone : " TZ



# Cheking if compose is present
if [ ! -f "./docker-compose.yaml" ]; then
   echo "Adding docker-compose.yaml file"
   curl -fsSL https://raw.githubusercontent.com/euca01/samba-ad-dc/main/docker-compose.yaml -o ./docker-compose.yaml
fi



#Update config of /etc/hosts
HOSTS_STRING="${SAMBA_HOST_IP}  $(cat /etc/hostname).${SAMBA_REALM} $(cat /etc/hostname)"

echo "Replacing /etc/hosts config"

# Check if the string is in the file
if ! grep -qF "$HOSTS_STRING" /etc/hosts; then
    echo "$HOSTS_STRING" >> /etc/hosts
    echo "$HOSTS_STRING appended to the file."
fi

echo "Replacing /etc/resolv.conf config"

#Overwrite /etc/resolv.conf
cat <<EOF > /etc/resolv.conf
search ${SAMBA_REALM}
nameserver 127.0.0.1
nameserver ${DNS_HOST_IP}
EOF

echo "Replacing ./samba.env config file"

# Create a env file file using the provided variables
cat <<EOF > ./samba.env
SAMBA_DOMAIN=${SAMBA_DOMAIN}
SAMBA_REALM=${SAMBA_REALM}
SAMBA_ADMIN_PASSWORD=${SAMBA_ADMIN_PASSWORD}
KERBEROS_PASSWORD=${KERBEROS_PASSWORD}
SAMBA_HOST_IP=${SAMBA_HOST_IP}
NTP_SERVERS=${NTP_SERVERS}
TZ=${TZ}
EOF

echo "Mouting and starting container"

# Run docker-compose up
docker compose up -d

echo "End"

exit 0