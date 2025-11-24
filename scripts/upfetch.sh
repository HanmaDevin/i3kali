#!/bin/bash
fetch_version=$(curl -s "https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest" | jq .tag_name | grep -Po --color=never "\d.\d+.\d")
wget -O fetch.deb "https://github.com/fastfetch-cli/fastfetch/releases/download/${fetch_version}/fastfetch-linux-amd64.deb"
sudo apt install ./fetch.deb
rm ./fetch.deb
