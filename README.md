# Use the register.sh for new server builds this script helps you register to your forman or satellite server.
# Usage
# The switches can use - or the full --switch use register.sh 
# For example -h can use --hostname and -d can use --domain 
# For the full sintax if you want to use the -- switches
# Script definition:
# .--script file name
# |          .--Hostname switch
# |          |   .--Hostname value
# |          |   |       .--Domain name switch
# |          |   |       |    .--Domain name value
# |          |   |       |   |      .--Recreate ssh keys switch
# |          |   |       |   |     |   .--join/rejoin to forman or satellite switch
# |          |   |       |   |     |  |   .--help switch
# |          |   |       |   |     |  |  |
register.sh -h hostname -d domain -k -j -h 
