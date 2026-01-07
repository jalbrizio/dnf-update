#/bin/bash
# register.sh file to register to rh satellite


#HOSTNAME
if [[ -z "$1" ]]; then
read -p "Enter the hostname: " HOSTNAME1
else 
HOSTNAME1=$1
echo "The hostname is $HOSTNAME1 ."
fi
#DOMAIN
if [[ -z "$2" ]]; then 
read -p "Enter the doamin: " DOMAIN1
else 
DOMAIN1=$2
echo "the domain is $DOMAIN1 ."
fi
#HOSTNAME
echo "Setting the hostname to $HOSTNAME1.$DOMAIN1"
hostnamectl set-hostname $HOSTNAME1.$DOMAIN1

#SSHKEYS
if [[ -z "$3" ]]; then 
read -p "do you want to update the ssh keys? Y/N: " NEWSSH
else 
NEWSSH=$3
fi
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
#REJOINTSAT
if [[ -z "$4" ]]; then 
read -p "do you want to rejoin to sattelite? Y/N: " NEWSAT
else 
NEWSAT=$4
fi
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
#Use this if the key stops working. -- subscription-manager register --auto-attach 
set -o pipefail && curl -sS  yourSATKEYURL | bash
else
echo "You chose NOT to rejoin to the satellite server"
fi


#
# register a RHEL5 or 6 client to the RHN Satellite server in the traditional manner
#
# this will overwrite the existing /etc/sysconfig/rhn/up2date, so...
cp -p /etc/sysconfig/rhn/up2date /etc/sysconfig/rhn/up2date-last$$
yourspacewalkserver=yourserver.com
yourspacewalkserver2=yourserver2.com
youroldsateliteserver=youroldserver.com
#
# REQUIRED: install the satellite SSL cert directly from the Satellite server...
rpm -ivh http://$yourspacewalkserver/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm
rpm -ivh http://$yourspacewalkserver/pub/spacewalk-client-repo-2.2-1.el6.noarch.rpm
rpm -e rhn-org-trusted-ssl-cert
rpm -ivh http://$yourspacewalkserver2/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm
#wget http://ncc-1701-sw/pub/RPM-GPG-KEY-MariaDB -O /etc/pki/rpm-gpg/RPM-GPG-KEY-MariaDB
#rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-MariaDB
rpm --import http://$yourspacewalkserver/pub/RPM-GPG-KEY-MariaDB
rpm --import http://$yourspacewalkserver/pub/RPM-GPG-KEY-EPEL-6
rpm --import http://$yourspacewalkserver/pub/RPM-GPG-KEY-mccdrpm
rpm --import http://$yourspacewalkserver/pub/RPM-GPG-KEY-percona

# edit the Red Hat target in /etc/sysconfig/rhn/up2date to point to
# the Satellite URL, then run  rhn_register  as usual.
sed -i 's/https:\/\/xmlrpc.rhn.redhat.com/https:\/\/$youroldsateliteserver/' /etc/sysconfig/rhn/up2date
sed -i 's/https:\/\/$youroldsateliteserver/https:\/\/$yourspacewalkserver2/' /etc/sysconfig/rhn/up2date
sed -i 's/RHNS-CA-CERT/RHN-ORG-TRUSTED-SSL-CERT/' /etc/sysconfig/rhn/up2date

# clean any existing yum configuration information...
yum clean all

# register the client using rhn_register and a userid and passwd...
rhn_register

# all done - run  yum update  whenever ready...
