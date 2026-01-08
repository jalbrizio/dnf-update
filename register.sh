#/bin/bash
# register.sh file to register to rh satellite
# usage register.sh -h <hostname> -d <domain> -k -j

#change these to match your system These will probably be depricated soon
yourformanserver=yourserver.com
yourformanserver2=yourserver2.com
youroldsateliteserver=youroldserver.com
VER=1.0
REL=1
HELP_FLAG=0

usage() {
    echo "Usage: $0 [-d <domain>|--domain <domain>] [-h <hostname>|--hostname <hostname>] [-k|--sshkeys] [-j|--joinsat] [-h|--help]"
    echo "Example: $0 -h myservername -d domain.com -k -j"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -d | --domain)
            if [ -n "$2" ] && [ "$2" != "--"* ] && [ "$2" != "-"* ]; then
                DOMAIN1="$2"
                NEWDN=Y
                shift 2 # Shift past the option and its argument
            else
                echo "Error: Option $1 requires an argument."
                usage
            fi
            ;;
        -n | --hostname)
            if [ -n "$2" ] && [ "$2" != "--"* ] && [ "$2" != "-"* ]; then
                HOSTNAME1="$2"
                NEWHN=Y
                shift 2 # Shift past the option and its argument
            else
                echo "Error: Option $1 requires an argument."
                usage
            fi
            ;;
        -k | --sshkeys)
            NEWSSH=Y
            shift
            ;;
        -j | --joinsat)
            NEWSAT=Y
            shift
            ;;
         -h | --help)
            HELP_FLAG=1
            shift
            ;;
        *)
            echo "Error: Unknown option $1"
            usage
            ;;
    esac
done

if [ "$HELP_FLAG" -eq 1 ]; then
    usage
fi

NEWHN=$(echo "$NEWHN" | tr '[:upper:]' '[:lower:]')
NEWDN=$(echo "$NEWDN" | tr '[:upper:]' '[:lower:]')
if [[ "$HN" == "yes" && "$DN" == "yes" ]] || [[ "$NEWHN" == "y" && "$NEWDN" == "y" ]]; then
#HOSTNAME
echo "Setting the hostname to $HOSTNAME1.$DOMAIN1"
hostnamectl set-hostname $HOSTNAME1.$DOMAIN1
else
echo "You chose NOT to set the hostname."
fi

#SSHKEYS
NEWSSH=$(echo "$NEWSSH" | tr '[:upper:]' '[:lower:]')
if [[ "$NEWSSH" == "yes" ]] || [[ "$NEWSSH" == "y" ]]; then
echo "You chose to regenerate the servers ssh keys"
# remove the /etc/ssh/ssh_host_* files and restart the sshd server. This generated new sshd keys for the host so it doesn't use the keys from the image.
echo "Generating new ssh host keys."
alias rm=rm
rm /etc/ssh/ssh_host_*
systemctl restart sshd
else
echo "You chose NOT to regenerate the servers ssh keys"
fi

#
# register a RHEL5 or 6 client to the RHN Satellite server in the traditional manner
#
# this will overwrite the existing /etc/sysconfig/rhn/up2date, so...
#cp -p /etc/sysconfig/rhn/up2date /etc/sysconfig/rhn/up2date-last$$

#
# Install the satellite SSL certs and the remove katello directly from the Satellite server... sattelite is depricated for forman which used katello, satellite uses subscribtion manager pick the one you use
#rpm -ivh http://$yourspacewalkserver/pub/spacewalk-client-repo-2.2-1.el6.noarch.rpm # depricated
#rpm -ivh http://$yourspacewalkserver2/pub/rhn-org-trusted-ssl-cert-$VER-$REL.noarch.rpm # depricated

rpm -ivh http://$yourformanserver/pub/rhn-org-trusted-ssl-cert-$VER-$REL.noarch.rpm
## rpm -ivh http://$yourformanserver/pub/katello-ca-consumer-latest.noarch.rpm
## dnf -y remove katello-ca-consumer*
rpm -e rhn-org-trusted-ssl-cert

## chose the keys that you will use and update them on your satellite or forman server then update the below to match
wget http://yourformanserver2/pub/RPM-GPG-KEY-MariaDB -O /etc/pki/rpm-gpg/RPM-GPG-KEY-MariaDB
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-MariaDB
rpm --import http://$yourformanserver/pub/RPM-GPG-KEY-MariaDB
rpm --import http://$yourformanserver/pub/RPM-GPG-KEY-EPEL-6
rpm --import http://$yourformanserver/pub/RPM-GPG-KEY-mccdrpm
rpm --import http://$yourformanserver/pub/RPM-GPG-KEY-percona


# up2date and rhn_register are depricated those sections are commented out.
#sed -i 's/https:\/\/xmlrpc.rhn.redhat.com/https:\/\/$youroldsateliteserver/' /etc/sysconfig/rhn/up2date
#sed -i 's/https:\/\/$youroldsateliteserver/https:\/\/$yourformanserver2/' /etc/sysconfig/rhn/up2date
#sed -i 's/RHNS-CA-CERT/RHN-ORG-TRUSTED-SSL-CERT/' /etc/sysconfig/rhn/up2date

#REJOINTSAT

NEWSAT=$(echo "$NEWSAT" | tr '[:upper:]' '[:lower:]')
if [[ "$NEWSAT" == "yes" ]] || [[ "$NEWSAT" == "y" ]]; then
echo "You chose to rejoin to the satellite server"
# Generate a new UUID
echo "Updating the IUUID for satellite."
NEWUUID=`uuidgen`
# Use the new UUID with subscription-manager
echo '\{\"dmi.system.uuid\": $NEWUUID}' > /etc/rhsm/facts/uuid_override.facts
# Validate that the new UUIS is being used
subscription-manager facts | grep dmi.system.uuid
echo "Joining to the satellite server with the new UUID."
# Re-Connect to the Satellite server

# First unregister with the Satellite server
subscription-manager clean

#
# Enable the network 
#
# Register with the Satellite server
#Use this key if you created a key to register. -- set -o pipefail && curl -sS  YOUR-SATELLITE-KEY | bash
subscription-manager register --auto-attach 
else
echo "You chose NOT to rejoin to the satellite server"
fi


# clean any existing yum configuration information...
dnf clean all

# register the client using rhn_register and a userid and passwd... This is depticated 
#rhn_register

# all done - run  dnf update  whenever ready...
