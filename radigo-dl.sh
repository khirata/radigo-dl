#!/bin/bash

nordvpn login --token $(< /run/secrets/nordvpn.txt) || exit 1

# Connect to local VPN server in the station area
nordvpn c $1 $2
while
    ! $(radigo area | grep -q $3)
do
    nordvpn d
    nordvpn c $1 $2
done

# Record the program and copy to the host
radigo rec -id=$3 -s=$4
chown 1000:1000 output/*.aac
cp output/*.aac /root/audios
