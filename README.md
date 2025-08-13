docker build -t radigo-dl .

docker run --rm --hostname mycontainer -v "$HOME/.config/secrets/radiko-nordvpn.txt:/run/secrets/nordvpn.txt:ro" --mount type=bind,source=$HOME/audios,target=/root/audios --cap-add=NET_ADMIN --sysctl net.ipv6.conf.all.disable_ipv6=0  mynordvpn /usr/local/bin/radigo-dl.sh "" Japan Tokyo TBS 20250812010000
