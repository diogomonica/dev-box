#!/usr/bin/env bash
set -e
set -x

if ! command -v sudo; then
	apt-get -q=2 update
	apt-get install sudo -y
fi

sudo=''
if [ "$EUID" != "0" ]; then
    sudo='sudo'
fi

# Somewhat smarter connection alive keeper
if ! command -v autossh; then
  $sudo apt-get -q=2 update
  $sudo apt-get install autossh -y
fi

# Curses based git ui tool
$sudo apt-get install -y tig

# fzf tool for easy searching, and filtering
$sudo apt-get install -y fzf

$sudo apt-get install -y bash-completion

# tool for visualizing changes in linux software packages, tarballs, etc
$sudo apt-get install -y pkgdiff

DIR="$(mktemp -d)"
(
cd "$DIR"
    # install go at $GO_VERSION
    GO_VERSION="go1.14.1"
    if [ ! -e ~/.go ] || [ "$(go version)" != "go version $GO_VERSION linux/amd64" ]; then
      mkdir -p $GO_VERSION
      (
      cd $GO_VERSION
      curl -LO https://dl.google.com/go/$GO_VERSION.linux-amd64.tar.gz
      echo "2f49eb17ce8b48c680cdb166ffd7389702c0dec6effa090c324804a5cac8a7f8  $GO_VERSION.linux-amd64.tar.gz" |sha256sum -c
      tar -xvf $GO_VERSION.linux-amd64.tar.gz
      rm -rf ~/.go
      mv go ~/.go
      )
    fi
    GH_CLI_VERSION="0.6.1"
    if [ ! -e /usr/local/bin/gh ] || [ "$(gh --version | awk 'NR == 1 { print $3 }')" != "$GH_CLI_VERSION" ]; then
      curl -fsSLO "https://github.com/cli/cli/releases/download/v${GH_CLI_VERSION}/gh_${GH_CLI_VERSION}_linux_amd64.deb"
      echo "999f98f9cb949c4b5cfad370477b67c2983d4642991a8df12611cf94e7dabf95  gh_${GH_CLI_VERSION}_linux_amd64.deb" |sha256sum -c
      $sudo dpkg -i "gh_${GH_CLI_VERSION}_linux_amd64.deb"
    fi
    CONTAINER_DIFF_VERSION="v0.15.0"
    if ! command -v container-diff || [ "$(container-diff version)" != "$CONTAINER_DIFF_VERSION" ]; then 
      curl -fsSLO "https://storage.googleapis.com/container-diff/${CONTAINER_DIFF_VERSION}/container-diff-linux-amd64"
      echo "65b10a92ca1eb575037c012c6ab24ae6fe4a913ed86b38048781b17d7cf8021b  container-diff-linux-amd64" | sha256sum -c
      chmod +x container-diff-linux-amd64
      $sudo mv container-diff-linux-amd64 /usr/local/bin/container-diff
    fi
)
rm -r "$DIR"
