#! /bin/bash
#    ____           __        ____   _____           _       __
#    /  _/___  _____/ /_____ _/ / /  / ___/__________(_)___  / /_
#    / // __ \/ ___/ __/ __ `/ / /   \__ \/ ___/ ___/ / __ \/ __/
#  _/ // / / (__  ) /_/ /_/ / / /   ___/ / /__/ /  / / /_/ / /_
# /___/_/ /_/____/\__/\__,_/_/_/   /____/\___/_/  /_/ .___/\__/
#                                                  /_/
clear

repo="$HOME/i3kali"
cfgPath="$repo/.config"

install_packages() {
  local packages=("python-pip" "libreoffice" "rust-all" "polybar" "rofi" "autotiling" "rust-analyzer" "nodejs" "npm" "zsh" "unrar" "qbittorrent" "golang" "tree" "ntfs-3g" "ufw" "gamemode" "bat" "openjdk-21-jdk" "docker" "ripgrep" "fd" "wine" "openssh" "thunar" "tumbler" "pam-u2f" "libfido2" "texlive-full" "nala" "jq" "btop" "bzip2")
  for pkg in "${packages[@]}"; do
    sudo apt install -y "$pkg"
  done

  cargo install starship
  cargo install eza
  cargo install zoxide

  # install nodejs and npm
  curl -o- https://fnm.vercel.app/install | bash

  # install_lazygit
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit -D -t /usr/local/bin/
  rm ./lazygit.tar.gz

  # fastfetch-cli
  local fetch_version
  fetch_version=$(curl -s "https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest" | jq .tag_name | grep -Po --color=never "\d.\d+.\d")
  wget -O fetch.deb "https://github.com/fastfetch-cli/fastfetch/releases/download/${fetch_version}/fastfetch-linux-amd64.deb"
  sudo apt install ./fetch.deb
  rm ./fetch.deb

  # install rust-analyzer
  sudo cp "$repo/bin/rust-analyzer" /usr/bin

  # install fzf
  local fzf_version
  fzf_version=$(curl -s "https://api.github.com/repos/junegunn/fzf/releases/latest" | jq .tag_name | grep -Po --color=never "\d.\d+.\d")
  wget -O fzf.tar.gz "https://github.com/junegunn/fzf/releases/download/v${fzf_version}/fzf-${fzf_version}-linux_amd64.tar.gz"
  sudo tar xvzf ./fzf.tar.gz -C /usr/bin/
  rm ./fzf.tar.gz

  local nvim_version
  nvim_version=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" | jq .tag_name | grep -Po --color=never "\d.\d+.\d")
  wget -O nvim "https://github.com/neovim/neovim/releases/download/v${nvim_version}/nvim-linux-x86_64.appimage"
  chmod +x ./nvim
  sudo mv ./nvim /usr/bin/

  printf ">>> Do you want to install ani-cli (y/n)?\n"
  read -r ani
  if [[ "$ani" =~ [yY] ]]; then
    printf ">>> Installing dependencies..."
    sudo apt install -y "mpv-mpris" "playerctl" "mpv"
    git clone "https://github.com/pystardust/ani-cli.git" "$HOME/ani-cli"
    sudo cp "$HOME/ani-cli/ani-cli" /usr/bin
    rm -rf "$HOME/ani-cli"
  fi

  curl https://sh.rustup.rs -sSf | sh
}

install_deepcool_driver() {
  printf ">>> Do you want to install DeepCool CPU-Fan driver (y/n)\n"
  read -r deepcool
  if [[ "$deepcool" =~ [yY] ]]; then
    sudo cp "$repo/DeepCool/deepcool-digital-linux" "/usr/sbin"
    sudo cp "$repo/DeepCool/deepcool-digital.service" "/etc/systemd/system/"
    sudo systemctl enable deepcool-digital
  fi
}

get_wallpaper() {
  printf ">>> Do you want to download cool wallpaper (y/n?\n"
  read -r ans
  if [[ "$ans" =~ [yY] ]]; then
    git clone "https://github.com/lixdroid-sys/WallFlex.git" "$HOME/WallFlex"
    cp -r "$HOME/WallFlex/wallpaper/" "$HOME/Pictures/Wallpaper/"
    rm -rf "$HOME/WallFlex/"
  fi
}

configure_git() {
  printf ">>> Do you want to setup git (y/n)?\n"
  read -r answer
  if [[ "$answer" =~ [yY] ]]; then
    read -r -p ">>> What is your username?: " username
    git config --global user.name "$username"
    read -r -p ">>> What is your email?: " useremail
    git config --global user.email "$useremail"
    git config --global pull.rebase true
  fi

  printf ">>> Do you want to create a ssh-key (y/n)?\n"
  read -r ssh
  if [[ "$ssh" =~ [yY] ]]; then
    ssh-keygen -t ed25519 -C "$useremail"
  fi
}

detect_nvidia() {
  gpu=$(lspci | grep -i '.* vga .* nvidia .*')

  shopt -s nocasematch

  if [[ $gpu == *' nvidia '* ]]; then
    echo ">>> Nvidia GPU is present"
    echo ">>> Installaling nvidia drivers now..."
    sleep 2
    sudo apt install linux-headers-$(uname -r) -y
    sudo apt install -y linux-headers-amd64
    sudo apt install -y nvidia-driver nvidia-cuda-toolkit
  else
    echo ">>> It seems you are not using a Nvidia GPU"
    echo ">>> If you have a Nvidia GPU then install the drivers yourself please :)"
    sleep 2
  fi
}

config_ufw() {
  echo ">>> Firewall will be configured with default values..."
  sleep 2
  sudo ufw enable
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw status verbose
}

copy_config() {
  printf ">>> Do you want to use my awesome configurations (y/n)?\n"
  read -r ans
  if [[ "$ans" =~ [yY] ]]; then
    if [[ ! -d "$HOME/Pictures/Screenshots/" ]]; then
      mkdir -p "$HOME/Pictures/Screenshots/"
    fi

    cp -r "$cfgPath" "$HOME"
    cp "$repo/.zshrc" "$HOME"

    sudo cp -r "$repo/fonts/" "/usr/share"
    sudo cp -r "$repo/Cursor/Bibata-Modern-Ice" "/usr/share/icons"
    sudo cp -r "$repo/icons" "/usr/share/"
    cp "$repo/.xinitrc" "$HOME"
    cp "$repo/.Xresources" "$HOME"
  fi
}

install_discord() {
  printf ">>> Do you want to install Discord (y/n)?\n"
  read -r discord
  if [[ "$discord" =~ [yY] ]]; then
    flatpak install discord
  fi
}

install_ghcli() {
  printf ">>> Do you want to install GitHub CLI (y/n)?\n"
  read -r ghcli
  if [[ "$ghcli" =~ [yY] ]]; then
    (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) &&
      sudo mkdir -p -m 755 /etc/apt/keyrings &&
      out=$(mktemp) && wget -nv -O "$out" "https://cli.github.com/packages/githubcli-archive-keyring.gpg" &&
      cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
      sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
      sudo mkdir -p -m 755 /etc/apt/sources.list.d &&
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
      sudo apt update &&
      sudo apt install gh -y
  fi
}

install_protonvpn() {
  printf ">>> Do you want to install Proton VPN (y/n)?\n"
  read -r vpn
  if [[ "$vpn" =~ [yY] ]]; then
    wget "https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb"
    sudo dpkg -i ./protonvpn-stable-release_1.0.8_all.deb && sudo apt update
    sudo apt install proton-vpn-gnome-desktop
  fi
}

install_vencord() {
  printf ">>> Do you want to install Vencord (y/n)?\n"
  read -r ven
  if [[ "$ven" =~ [yY] ]]; then
    bash "$repo/Vencord/VencordInstaller.sh"
    cp -r "$repo/Vencord/themes" "$HOME/.config/Vencord"
  fi
}

install_proton_mail() {
  printf ">>> Do you want to install proton mail (y/n)?\n"
  read -r ans
  if [[ "$ans" =~ [yY] ]]; then
    wget -O mail.deb "https://proton.me/download/mail/linux/1.10.8/ProtonMail-desktop-beta.deb"
    sudo apt install -y ./mail.deb
  fi
}

install_steam() {
  printf ">>> Do you want to install steam (y/n)?\n"
  read -r ans
  if [[ "$ans" =~ [yY] ]]; then
    wget "https://cdn.fastly.steamstatic.com/client/installer/steam.deb"
    sudo apt install -y ./steam.deb
  fi
}

MAGENTA='\033[0;35m'
NONE='\033[0m'

# Header
echo -e "${MAGENTA}"
cat <<"EOF"
   ____         __       ____
  /  _/__  ___ / /____ _/ / /__ ____
 _/ // _ \(_-</ __/ _ `/ / / -_) __/
/___/_//_/___/\__/\_,_/_/_/\__/_/

EOF

echo "Kali Setup"
echo -e "${NONE}"
while true; do
  read -r -p ">>> Do you want to start the installation now? (Yy/Nn): " yn
  case $yn in
  [Yy]*)
    echo ">>> Installation started."
    echo
    break
    ;;
  [Nn]*)
    echo ">>> Installation canceled."
    exit
    ;;
  *)
    echo ">>> Please answer yes or no."
    ;;
  esac
done

sudo apt update -y
sudo apt upgrade

# Install required packages
echo ">>> Installing required packages..."
sleep 2
install_packages
get_wallpaper
detect_nvidia
install_discord
install_deepcool_driver
install_ghcli
install_vencord
install_protonvpn
install_proton_mail
install_steam

echo ">>> Starting setup now..."
sleep 2
copy_config

configure_git
config_ufw

echo -e "${MAGENTA}"
cat <<"EOF"
    ____       __                __  _                _   __             
   / __ \___  / /_  ____  ____  / /_(_)___  ____ _   / | / /___ _      __
  / /_/ / _ \/ __ \/ __ \/ __ \/ __/ / __ \/ __ `/  /  |/ / __ \ | /| / /
 / _, _/  __/ /_/ / /_/ / /_/ / /_/ / / / / /_/ /  / /|  / /_/ / |/ |/ / 
/_/ |_|\___/_.___/\____/\____/\__/_/_/ /_/\__, /  /_/ |_/\____/|__/|__/  
                                         /____/                          
EOF
echo "and thank you for choosing my config :)"
echo "Remember after the reboot to run 'fnm install 25'"
echo -e "${NONE}"
sleep 2
sudo systemctl reboot
