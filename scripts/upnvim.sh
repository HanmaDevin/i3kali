#! /bin/bash
nvim_version=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" | jq .tag_name | grep -Po --color=never "\d.\d+.\d")
wget -O nvim "https://github.com/neovim/neovim/releases/download/v${nvim_version}/nvim-linux-x86_64.appimage"
chmod +x ./nvim
sudo mv ./nvim /usr/bin/
