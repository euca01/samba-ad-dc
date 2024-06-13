#!/bin/bash

set -e

SAMBA_DOMAIN=${SAMBA_DOMAIN:-SAMDOM}
SAMBA_REALM=${SAMBA_REALM:-SAMDOM.EXAMPLE.COM}
LDAP_ALLOW_INSECURE=${LDAP_ALLOW_INSECURE:-false}
SETUP_LOCK_FILE="/var/lib/samba/private/.setup.lock.do.not.remove"

if [[ $SAMBA_HOST_IP ]]; then
    SAMBA_HOST_IP="--host-ip=${SAMBA_HOST_IP}"
fi

appSetup () {
    echo "Initializing samba database..."

    SAMBA_ADMIN_PASSWORD=${SAMBA_ADMIN_PASSWORD:-ChangePassword$5}
    export KERBEROS_PASSWORD=${KERBEROS_PASSWORD:-ChangePassword$5}
    echo Samba administrator password: $SAMBA_ADMIN_PASSWORD
    echo Kerberos KDC database master key: $KERBEROS_PASSWORD

    # Provision Samba
    rm -f /etc/samba/smb.conf
    rm -rf /var/lib/samba/*
    mkdir -p /var/lib/samba/private
    samba-tool domain provision \
      --use-rfc2307 \
      --domain=$SAMBA_DOMAIN \
      --realm=$SAMBA_REALM \
      --server-role=dc\
      --dns-backend=SAMBA_INTERNAL \
      --adminpass=$SAMBA_ADMIN_PASSWORD \
      $SAMBA_HOST_IP
    cat /var/lib/samba/private/krb5.conf > /etc/krb5.conf
    if [ "${LDAP_ALLOW_INSECURE,,}" == "true" ]; then
	     sed -i '/\[global\]/a # enable unencrypted passwords \
         ldap server require strong auth = no' /etc/samba/smb.conf
	fi

	sed -i '/\[global\]/a # limit port range \
rpc server dynamic port range = 50000-55000' /etc/samba/smb.conf

    sed -i '/\[global\]/a # disable null session \
restrict anonymous = 2' /etc/samba/smb.conf

    sed -i '/\[global\]/a # disable NetBIOS \
disable netbios = yes \
smb ports = 445' /etc/samba/smb.conf

    sed -i '/\[global\]/a # disable printer \
printcap name = /dev/null \
load printers = no \
disable spoolss = yes \
printing = bsd' /etc/samba/smb.conf

	sed -i '/\[global\]/a # disable NTLMv1 \
ntlm auth = mschapv2-and-ntlmv2-only' /etc/samba/smb.conf

    # Create Kerberos database
    #kstash --random-key
    
    touch "${SETUP_LOCK_FILE}"
}

appStart () {
    if [ ! -f "${SETUP_LOCK_FILE}" ]; then
      appSetup
    fi
    /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
}

appHelp () {
	echo "Available options:"
	echo " app:start          - Starts all services needed for Samba AD DC"
	echo " app:setup          - First time setup."
	echo " app:setup_start    - First time setup and start."
	echo " app:help           - Displays the help"
	echo " [command]          - Execute the specified linux command eg. /bin/bash."
}

case "$1" in
	app:start)
		appStart
		;;
	app:setup)
		appSetup
		;;
	app:setup_start)
		appSetup
		appStart
		;;
	app:help)
		appHelp
		;;
	*)
		if [ -x $1 ]; then
			$1
		else
			prog=$(which $1)
			if [ -n "${prog}" ] ; then
				shift 1
				$prog $@
			else
				appHelp
			fi
		fi
		;;
esac

exit 0
