
#scripts
```

register.sh # Register new servers
dnf-update-server.sh # Generic update script
dnf-update-mysql.sh # Update script for servers with mysql and mariadb
dnf-update-qemu.sh # Update script for servers with qemu
dnf-update.sh # update wrapper script for custom dates like the second sunday or second wednesday.
update-vmware.sh Update script for servers with vmware tools -- compiles vmware tools. ** Requires a vmware tools git repo. 
```
# register.sh Usage
 ```
 Use the register.sh for new server builds this script helps you register to your forman or satellite server.
 The switches can use - or the full --switch use register.sh 
 For example -h can use --hostname and -d can use --domain 
 For the full sintax if you want to use the -- switches
 Script definition:

 .--script file name
 |          .--Hostname switch
 |          |   .--Hostname value
 |          |   |       .--Domain name switch
 |          |   |       |    .--Domain name value
 |          |   |       |   |      .--Recreate ssh keys switch
 |          |   |       |   |     |   .--join/rejoin to forman or satellite switch
 |          |   |       |   |     |  |   .--help switch
 |          |   |       |   |     |  |  |
 register.sh -h hostname -d domain -k -j -h
```
