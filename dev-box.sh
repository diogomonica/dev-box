#!/usr/bin/env bash
set -e
set -x

if ! command -v sudo; then
  apt-get -q=2 update
  apt-get install sudo -y
fi

if ! command -v lsb_release; then
  sudo apt-get -q=2 update
  sudo apt-get install lsb-release -y
fi

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo bash -c 'echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu disco stable" > /etc/apt/sources.list.d/docker-ce.list'
sudo apt-get -q=2 update

# Install cron-apt to install updates weekly with anacron
# https://help.ubuntu.com/community/AutoWeeklyUpdateHowTo#Installing_Cron-apt
sudo apt-get install -y cron-apt
if [ ! -e /etc/cron.weekly/cron-apt ]; then
  sudo ln -s /usr/sbin/cron-apt /etc/cron.weekly/
fi

# Install standard development tools
sudo apt-get install -y unzip mosh python3-dev cmake zsh git silversearcher-ag build-essential htop psmisc time man-db wget curl virtualenv direnv tmux expect ripgrep docker-ce libreadline-dev libssl-dev libbz2-dev libsqlite3-dev
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl

# install x11 libs necessary for supporting gl
# https://github.com/yarnpkg/yarn/issues/1987
sudo apt-get install -y libx11-dev libxext-dev libxi-dev pkg-config libgl1-mesa-dev

sudo apt-get install -y libjemalloc2 libmsgpackc2 libtermkey1 libunibilium4 libvterm0 neovim-runtime python3-pip libluajit-5.1-dev libncurses5-dev

sudo pip3 install neovim

# Install cutting edge software
DIR="$(mktemp -d)"
(
cd "$DIR"

if [ ! -e /usr/bin/nvim ] || [ "$(nvim --version | awk 'NR==1{print $2}')" != "v0.4.3" ]; then
  curl -sLO https://github.com/neovim/neovim/releases/download/v0.4.3/nvim-linux64.tar.gz
  tar -zxvf nvim-linux64.tar.gz
  sudo cp nvim-linux64/bin/nvim /usr/bin/nvim
  sudo cp -r nvim-linux64/share/. /usr/share
fi

# Install NVM for managing node versions
if [ ! -e "${HOME}/.nvm/install.sh" ]; then
  curl -sLo nvm-install.sh https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh

  if [ ! -d "${HOME}/.nvm" ]; then
    mkdir "${HOME}/.nvm"
  fi
  bash nvm-install.sh
fi

DEFAULT_NODE_VERSION="10.19.0"
if  ! command -v nvm; then
  source "${HOME}/.nvm/nvm.sh"
  if [ "$(nvm current)" != "v${DEFAULT_NODE_VERSION}" ]; then
    nvm install "${DEFAULT_NODE_VERSION}"
    nvm alias default "${DEFAULT_NODE_VERSION}"
  fi
fi

FPP_VERSION="0.9.2"
if [ ! -e /usr/local/bin/fpp ]; then
  curl -sLO https://github.com/facebook/PathPicker/archive/${FPP_VERSION}.tar.gz
  tar -xzvf $FPP_VERSION.tar.gz
  if [ ! -e /usr/local/share/fpp ]; then
    sudo mv PathPicker-$FPP_VERSION/ /usr/local/share/fpp
  fi
  sudo ln -s /usr/local/share/fpp/fpp /usr/local/bin/
fi

)

vimplug_file=~/.local/share/nvim/site/autoload/plug.vim
if [ ! -e "$vimplug_file" ]; then
  echo "Installing vim-plug to $vimplug_file"
  curl -fLo "$vimplug_file" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Temporary fix to the expired google gpg key
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

sh development.sh
sh git.sh

nvim --headless +'PlugInstall --sync' +qa
nvim --headless +'GoInstallBinaries' +qa

# install prezto

sudo apt-get install -y tree mariadb-client


mkdir -p ${HOME}/projects
mkdir -p ${HOME}/go/src/github.com/diogo.monica

export PATH="$PATH:$HOME/.go/bin"
export GOPATH="$HOME/go"
export GOROOT="$HOME/.go"

echo 'Popular tools...'
go get golang.org/x/tools/cmd/goimports
go get github.com/go-delve/delve/cmd/dlv
GO111MODULE=on go get golang.org/x/tools/gopls@latest

# Add idle check to the GCP machine. This will
# automatically turn the machine off when inactive.
sudo cp idlecheck.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/idlecheck.sh
# Check for inactivity every hour on the hour
sudo tee >/dev/null /etc/cron.d/idlecheck <<EOF
0 * * * * root /usr/local/bin/idlecheck.sh
EOF

git config --global user.name "Diogo Monica"
git config --global user.email "diogo.monica@gmail.com"

cp .bash_profile ~/

sudo snap install microk8s --classic --channel=1.18/stable

curl -Lo skaffold https://storage.googleapis.com/skaffold/builds/latest/skaffold-linux-amd64
chmod +x skaffold
sudo mv skaffold /usr/local/bin


sudo usermod -aG docker diogo.monica

curl https://pyenv.run | bash

cp bash_profile $HOME/.bash_profile
cp bashrc $HOME/.bashrc
exec "$SHELL"

pyenv install 3.8.2

cd code-server; sudo docker build -t code-server . ; sudo docker run -d -it --rm --name code-server --security-opt=seccomp:unconfined -p 127.0.0.1:8080:8080 -v $(pwd)/project:/home/diogo.monica/project code-server
