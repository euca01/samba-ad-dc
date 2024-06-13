# Samba AD-DC - Active Directory Domain Controller - Docker Compose - Alpine

This repository provides a Docker Compose configuration to deploy a Samba Active Directory Domain Controller (AD DC) out of the box.

## Prerequisites

- Fresh Linux Install with static IP (tested on Debian 12)
- Docker
- Docker Compose

## Getting Started

1. Execute the autoconfig script
    ```sh
    bash <(curl -s https://raw.githubusercontent.com/euca01/samba-ad-dc/main/autoconfig.sh)
    ```

2. Make sure DNS are resolved localy

3. Download the docker compose file.

4. Customise the env file
    ```sh
    mkdir /opt/krb-conf
    mkdir /opt/krb-data
    mkdir /opt/smb-conf
    mkdir /opt/smb-data
    touch /opt/krb-conf/krb5.conf
    docker compose up -d
    ```

5. Execute 
    ```sh
    mkdir /opt/krb-conf
    mkdir /opt/krb-data
    mkdir /opt/smb-conf
    mkdir /opt/smb-data
    touch /opt/krb-conf/krb5.conf
    docker compose up -d
    ```

## Configuration

The primary configuration file for Samba is `smb.conf`. You can customize this file to fit your needs. The default configuration is designed to get you up and running quickly.

## Environment Variables

- `SAMBA_DOMAIN`: The domain name for the AD DC.
- `SAMBA_REALM`: The Kerberos realm name.
- `SAMBA_ADMIN_PASSWORD`: The password for the AD DC administrator.

## Volumes

- `/etc/samba`: Configuration files.
- `/var/lib/samba`: State files.
- `/var/log/samba`: Log files.

## Ports

- `53`: DNS
- `88`: Kerberos authentication
- `135`: DCE/RPC Locator service
- `137-138`: NetBIOS name service
- `139`: SMB over NetBIOS
- `389`: LDAP
- `445`: SMB over TCP
- `464`: Kerberos password change
- `636`: LDAPS
- `3268`: Global Catalog
- `3269`: Global Catalog over SSL

## License

This project is licensed under the MIT License.