#!/bin/bash
fzf_version=$(curl -s "https://api.github.com/repos/junegunn/fzf/releases/latest" | jq .tag_name | grep -Po --color=never "\d.\d+.\d")
wget -O fzf.tar.gz "https://github.com/junegunn/fzf/releases/download/v${fzf_version}/fzf-${fzf_version}-linux_amd64.tar.gz"
sudo tar xvzf ./fzf.tar.gz -C /usr/bin/
rm ./fzf.tar.gz
