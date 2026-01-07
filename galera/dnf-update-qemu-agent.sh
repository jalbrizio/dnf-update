#!/bin/bash
# This script updates the server Via Yum
# Then emails the Admins the status of the updates
# Then reboots the server in that order

# Script written by Jeremi Albrizio on Feb 5th.

# This is where we make sure it only runs on the second sunday 
# since cron can only be scheduled to run every sunday.
#
#!/bin/bash



# This is where we call yum to update the server
#
dnf -y update --nogpg --skip-broken > /var/log/dnf-update.log

# now we Give it 30 seconds just in case 
# before emailing everyone the update status.
#
sleep 30

# Email everyone ## email are seperated by comas with no spaces##
#
cat /var/log/dnf-update.log | mail -s "dnf update log for `date`" exampleemail@yourserver.com,exampleemail@yourserver.com,exampleemail@yourserver.com,exampleemail@yourserver.com

# Make sure iptables is running and will start at boot then reboot the server 
# Yes, I chose reboot instead of shutdown -r 0
# 

systemctl enable firewalld
systemctl restart firewalld

systemctl restart qemu-guest-agent


reboot
