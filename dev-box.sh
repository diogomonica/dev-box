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

RELEASE="$(lsb_release -sc)"

echo "deb http://ftp.debian.org/debian ${RELEASE}-backports main" | sudo tee /etc/apt/sources.list.d/backports.list
echo "deb http://ftp.us.debian.org/debian ${RELEASE} main" | sudo tee /etc/apt/sources.list.d/usmirror.list

# if we are on buster and in crostini, make sure all stretch packages are made to be buster
# and we still have stretch deps, upgrade
if [ "$RELEASE" = "buster" ] && [ "$(uname -n)" = "penguin" ] && [ "$( grep -c "stretch" /etc/apt/sources.list)" != "0" ]; then
  echo "Updating repos from stretch to buster"
  for list in  $(ls /etc/apt/sources.list.d/*.list); do
    sudo sed -i 's/stretch/buster/g' "$list";
  done
  # return the one without comments
  cros_version="$(perl -lane '/^[^#].+cros-packages\/(\d+)/ && print $1' /etc/apt/sources.list.d/cros.list | head -n1)"
  echo "deb https://storage.googleapis.com/cros-packages/$cros_version buster main" | sudo tee /etc/apt/sources.list.d/cros.list
fi

sudo apt-get -q=2 update

# Install cron-apt to install updates weekly with anacron
# https://help.ubuntu.com/community/AutoWeeklyUpdateHowTo#Installing_Cron-apt
sudo apt-get install -y cron-apt
if [ ! -e /etc/cron.weekly/cron-apt ]; then
  sudo ln -s /usr/sbin/cron-apt /etc/cron.weekly/
fi

# Install standard development tools
sudo apt-get install -y unzip mosh python3-dev cmake zsh git silversearcher-ag build-essential htop psmisc time man-db wget curl virtualenv direnv



## Crostini specific tools to install
if [ "$(uname -n)" = "penguin" ]; then
  if [ "$RELEASE" = "stretch" ]; then
    # crostini specific packages
    sudo apt-get install -y libglvnd-dev=1.1.0-1~bpo9+1 libegl1=1.1.0-1~bpo9+1 libegl-mesa0 libwayland-client0=1.16.0-1~bpo9+1 libgbm1=19.2.0~cros1-3 libwayland-server0=1.16.0-1~bpo9+1

  elif [ "$RELEASE" = "buster" ]; then
    sudo apt-get install -y libglvnd-dev=1.1.0-1 libegl1=1.1.0-1 libegl-mesa0 libwayland-client0=1.16.0-1 libgbm1=19.2.0~cros1-4 libwayland-server0=1.16.0-1
  else
    echo "Unknown $RELEASE, cowardly refusing to continue"
    exit 1
  fi
fi

# install x11 libs necessary for supporting gl
# https://github.com/yarnpkg/yarn/issues/1987
sudo apt-get install -y libx11-dev libxext-dev libxi-dev pkg-config libgl1-mesa-dev

if [ "$RELEASE" = "buster" ]; then
  sudo apt-get install -y libjemalloc2 libmsgpackc2 libtermkey1 libunibilium4 libvterm0 neovim-runtime python3-pip libluajit-5.1-dev libncurses5-dev
  sudo apt-get install -y tmux=2.8-3
  # Installed to get the unbuffered tool for passing through colored outputs
  sudo apt-get install -y expect=5.45.4-2
else
  sudo apt-get install -y libjemalloc1 libmsgpackc2 libtermkey1 libunibilium0 libvterm0 neovim-runtime python3-pip libluajit-5.1-dev libncurses5-dev
  sudo apt-get -t stretch-backports install -y tmux=2.8-3~bpo9+1
  # Installed to get the unbuffered tool for passing through colored outputs
  sudo apt-get install -y expect=5.45-7+deb9u1
fi

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

# TODO: remove this after everyone has upgraded
# remove the old source for fish
sudo rm -f /etc/apt/sources.list.d/shells:fish:release:3.list
sudo apt-get remove fish=3.1.0-1 || true

if ! fish --version | grep "3.0.2"; then
  if [ "$RELEASE" = "buster" ]; then
    sudo apt-get install -y fish=3.0.2-2
  else
     sudo apt-get install -y --allow-downgrades fish=3.0.2-2~bpo9+1 fish-common=3.0.2-2~bpo9+1
  fi
fi

# alternative to ls
EXA_VERSION=0.9.0
if [ ! -e /usr/bin/exa ] || [ "$(exa -v | awk 'NR==1{print $2}')" != "v$EXA_VERSION" ]; then
  curl -sLO https://github.com/ogham/exa/releases/download/v0.9.0/exa-linux-x86_64-$EXA_VERSION.zip
  unzip exa-linux-x86_64-$EXA_VERSION.zip
  sudo mv exa-linux-x86_64 /usr/local/bin/exa
fi

# replace grep with ripgrep
if [ "$RELEASE" = "buster" ]; then
  sudo apt-get install -y ripgrep
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

CODE_SERVER_TAG="3.0.1"
CODE_SERVER_VERSION="${CODE_SERVER_TAG}"
if [ "$(code-server --version | awk 'NR==1 { print $2 }')" != "$CODE_SERVER_VERSION" ]; then
  curl -LO https://github.com/cdr/code-server/releases/download/$CODE_SERVER_TAG/code-server-${CODE_SERVER_VERSION}-linux-x86_64.tar.gz
  tar -zxvf code-server-${CODE_SERVER_VERSION}-linux-x86_64.tar.gz
  sudo mv code-server-${CODE_SERVER_VERSION}-linux-x86_64/code-server /usr/bin/code-server
fi

)

vimplug_file=~/.local/share/nvim/site/autoload/plug.vim
if [ ! -e "$vimplug_file" ]; then
  echo "Installing vim-plug to $vimplug_file"
  curl -fLo "$vimplug_file" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

if [ ! -e ~/.ssh/id_ed25519 ]; then
  ssh-keygen -N '' -o -t ed25519 -f ~/.ssh/id_ed25519
  echo 'Add your ssh key at https://github.com/settings/keys'
  cat ~/.ssh/id_ed25519
fi

# Temporary fix to the expired google gpg key
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

sh development.sh
sh git.sh

nvim --headless +'PlugInstall --sync' +qa
nvim --headless +'GoInstallBinaries' +qa

# install prezto

if [ ! -e "$HOME/.zprezto" ]; then
  git clone --recursive https://github.com/easyaspi314/prezto.git "$HOME/.zprezto"
fi


#zsh ./scripts/link-prezto.zsh


sudo apt-get install -y tree mariadb-client
sudo pip3 install qrcode-terminal

# tig is a useful git repo explorer in curses
# exuberant-ctags is required for tagbar
sudo apt-get install -y tig exuberant-ctags


if [ "$CI_CONTAINER" != "true" ]; then

  # run code-server under systemd

  mkdir -p ${HOME}/projects
  mkdir -p ${HOME}/go/src/github.com/diogo
  # By default, listen on port 8443
  CODE_SERVER_PORT=8443
  if [ "$(uname -n)" = "penguin" ]; then
    # When running locally on crostini, use a port that doesn't conflict
    CODE_SERVER_PORT=9443
  fi
  code_server_service_file=/etc/systemd/system/code-server.service
  tmp_code_server_service_file=$(mktemp)
    sudo tee >/dev/null "$tmp_code_server_service_file" <<EOF
[Unit]
Description=DM VS Code Server
After=network.target
AssertPathExists=/home/$USER/go/src/github.com/diogo
AssertPathExists=/home/$USER/projects
[Service]
Type=simple
Environment=GOPATH=/home/$USER/go
Environment=PATH=/home/$USER/.go/bin:/home/$USER/bin:/usr/local/bin:/usr/bin:/bin:/home/$USER/go/bin
Environment=GOROOT=/home/$USER/.go
Environment=GO111MODULE=off
WorkingDirectory=/home/$USER/projects
ExecStart=/usr/bin/code-server . --allow-http --auth none --port ${CODE_SERVER_PORT}
User=$USER
Restart=always
RestartSec=1
[Install]
WantedBy=multi-user.target
EOF

  changed=false
  if [ ! -e "$code_server_service_file" ]; then
    sudo mv "$tmp_code_server_service_file" "$code_server_service_file"
    changed=true
  else
    # if the configs have changed replace with the new one
    diff "$code_server_service_file" "$tmp_code_server_service_file" || {
      sudo mv -f "$tmp_code_server_service_file" "$code_server_service_file"
    }
    changed=true
  fi


  if [ "$changed" = "true" ]; then
    sudo systemctl daemon-reload
    sudo systemctl stop code-server.service
    sudo systemctl enable code-server.service
    sudo systemctl start code-server.service
  fi

  export PATH="$PATH:$HOME/.go/bin"
  export GOPATH="$HOME/go"
  export GOROOT="$HOME/.go"

  echo 'Popular tools...'
  go get golang.org/x/tools/cmd/goimports
  go get github.com/go-delve/delve/cmd/dlv
  # Handles the error
  # go: cannot use path@version syntax in GOPATH mode
  # based on instructions here: https://github.com/golang/tools/blob/master/gopls/doc/user.md#installation
  GO111MODULE=on go get golang.org/x/tools/gopls@latest
fi

# TODO: add idle check back
# Add idle check to the GCP machine. This will
# automatically turn the machine off when inactive.
sudo cp idlecheck.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/idlecheck.sh
# Check for inactivity every hour on the hour
sudo tee >/dev/null /etc/cron.d/idlecheck <<EOF
0 * * * * root /usr/local/bin/idlecheck.sh
EOF

curl https://pyenv.run | bash

exec "$SHELL"

cat <<EOF >> ~/.bashrc
export PATH="\$HOME/.pyenv/bin:\$PATH"
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"
EOF

pyenv install 3.8.2
git config --global user.name "Diogo Monica"
git config --global user.email "diogo.monica@gmail.com"

cp .bash_profile ~/

cd code-server; docker build -t code-server . ; docker run -it --rm --name code-server --security-opt=seccomp:unconfined -p 127.0.0.1:8080:8080 -v $(pwd)/project:/home/diogo/project code-server
