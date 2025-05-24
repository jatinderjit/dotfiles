#/usr/bin/env zsh

SERVER_NAME=

# space separated usernames to add ssh keys
GITHUB_USERNAMES=(jatinderjit)

INSTALL_OH_MY_ZSH=true  # Mandatory
INSTALL_OH_MY_ZSH_PLUGINS=true

INSTALL_PYENV=true  # Installs at /opt/pyenv
INSTALL_POETRY=true  # Installs at /opt/poetry

INSTALL_GO=true  # Installs at /opt/go
GO_VERSION=1.23.3

INSTALL_RUST=false

INSTALL_POSTGRES=false
DISABLE_POSTGRES=true

INSTALL_REDIS=false
DISABLE_REDIS=true

INSTALL_NGINX=true
INSTALL_CERTBOT=false

BIN_PATH='/usr/local/bin'
NEW_USERNAME=

# END: Configuration ##########################################################

set -e

if [ -z "$SERVER_NAME" ]; then
    echo "SERVER_NAME is not set"
    exit 1
fi

rm -rf /tmp/server-setup
mkdir /tmp/server-setup
cd /tmp/server-setup

ARCHITECTURE=$(uname -m)

choose_by_arch() {
    # First argument is for x86_64, second for aarch64.
    # Usage: choose_by_arch x86_64 aarch64
    if [[ $ARCHITECTURE == "x86_64" ]]; then
        echo $1
    elif [[ $ARCHITECTURE == "aarch64" ]]; then
        echo $2
    else
        echo "Unknown architecture: $ARCHITECTURE"
        exit 1
    fi
}

echo "$(choose_by_arch 'x86_64' 'aarch64') architecture detected"


sudo apt update
sudo apt upgrade

sudo apt install -y zsh git cmake gettext zip unzip
sudo apt install -y build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev curl \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# lnav
sudo apt install -y libcurl4-openssl-dev libpcre2-dev

ZSH_PLUGINS=''
add_zsh_plugin () {
    ZSH_PLUGINS="$ZSH_PLUGINS\n  $1"
}
add_zsh_plugin git
add_zsh_plugin pip

# Add SSH Keys ################################################################
mkdir -p ~/.ssh
for username in $GITHUB_USERNAMES; do
    echo "\n# $username" >> ~/.ssh/authorized_keys
    curl "https://github.com/$username.keys" >> ~/.ssh/authorized_keys
done

# oh-my-zsh ###################################################################
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

cat > ~/.oh-my-zsh/custom/themes/robbyrussell-custom.zsh-theme <<- EOM
local server_info="%{\$fg_bold[red]%}%{\$bg[white]%} \$USER @ SERVER_NAME %{\$reset_color%}"
PROMPT="${server_info} %(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%c%{$reset_color%}"
PROMPT+=' $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
EOM

sed -i "s/SERVER_NAME/$SERVER_NAME/" ~/.oh-my-zsh/custom/themes/robbyrussell-custom.zsh-theme
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="robbyrussell-custom"/' ~/.zshrc

mkdir -p $ZSH/custom/completions

# Utilities ###################################################################

install_if_required() {
    should_install=$1
    name=$2
    bin_name=$3
    installer=$4
    if $should_install; then
        if command -v "$bin_name" &> /dev/null; then
            echo "Already installed: $name"
        else
            $installer
            echo "Installed: $name"
        fi
    fi
}

latest_release_version() {
    # Prints the latest_release_version for the GitHub repository
    # Usage: latest_release_version repo_url [trim_leading_v]
    version=$(curl -I "$1/releases/latest" | grep --ignore-case '^location: ' | choose -f '/' -1 | tr -d '\r\n')
    if [[ "$2" = "true" ]]; then
        version=$(echo $version | cut -c 2-)
    fi
    echo $version
}

download_extract() {
    url=$1
    wget --no-verbose $url
    compressed_fn=$(echo $url | choose -f '/' -1)
    if [[ $url == *.tar.gz ]]; then
        tar -xf $compressed_fn
    elif [[ $url == *.zip ]]; then
        unzip $compressed_fn
    else
        echo "Unknown format $compressed_fn"
    fi
    rm $compressed_fn
}

install_bin() {
    # install_bin name <current_path>
    local target_bin_name=$1
    local curr_path=$target_bin_name
    if [ $# -eq 2 ]; then
        curr_path=$2
    fi
    sudo chmod +x $curr_path
    sudo cp $curr_path "$BIN_PATH/$target_bin_name"
    rm $curr_path
}

download_install() {
    # download_install bin_name url [downloaded_bin_name]
    local bin_name=$1
    local bin_url=$2
    wget $bin_url
    local fn=$(echo $bin_url | choose -f '/' -1)
    if [[ $fn == *.tar.gz ]]; then
        local dir_name=$(echo $fn | choose -f '.tar.gz' -1)
        tar -xf $fn
        if [ -d $dir_name ]; then
            install_bin $bin_name "$dir_name/$bin_name"
        else
            install_bin $bin_name
        fi
        rm -r $dir_name $fn
    elif [[ $fn == *.deb ]]; then
       sudo dpkg -i $fn
       rm $fn
    else
        install_bin $bin_name "$fn"
    fi
}


sudo mkdir -p /usr/local/share/man/man1
install_manpage() {
    sudo cp "$1" /usr/local/share/man/man1/
    rm "$1"
    sudo mandb
}

CHOOSE_BIN=$(choose_by_arch 'choose-x86_64-unknown-linux-gnu' 'choose-aarch64-unknown-linux-gnu')
wget "https://github.com/theryangeary/choose/releases/latest/download/$CHOOSE_BIN"
install_bin choose "$CHOOSE_BIN"

if [ $(which nvim) ]; then
    echo "Already installed: nvim"
else
    NVIM_TAR=$(choose_by_arch 'nvim-linux-x86_64' 'nvim-linux-arm64')
    download_extract "https://github.com/neovim/neovim/releases/latest/download/${NVIM_TAR}.tar.gz"
    sudo mv $NVIM_TAR /opt/nvim
    echo >> ~/.zshrc
    echo 'export PATH="/opt/nvim/bin:$PATH"' >> ~/.zshrc
    echo "Installed: nvim"
fi

install_rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}
install_if_required $INSTALL_RUST Rust cargo install_rust

# ripgrep #####################################################################
repo="https://github.com/BurntSushi/ripgrep"
version=$(latest_release_version $repo)
RG_BIN=$(choose_by_arch "ripgrep-${version}-x86_64-unknown-linux-musl.tar.gz" "ripgrep-${version}-aarch64-unknown-linux-gnu.tar.gz")
download_install rg "$repo/releases/latest/download/$RG_BIN"
rg --generate complete-zsh > "$ZSH/custom/completions/_rg"

# eza #########################################################################

EZA_BIN=$(choose_by_arch 'eza_x86_64-unknown-linux-musl.tar.gz' 'eza_aarch64-unknown-linux-gnu.tar.gz')
download_install eza "https://github.com/eza-community/eza/releases/latest/download/$EZA_BIN"
add_zsh_plugin eza

# fd ##########################################################################
repo="https://github.com/sharkdp/fd"
version=$(latest_release_version $repo true)
FD_BIN="fd-musl_${version}_$(choose_by_arch amd64 arm64).deb"
download_install fd "$repo/releases/latest/download/$FD_BIN"

# bat #########################################################################
repo="https://github.com/sharkdp/bat"
version=$(latest_release_version $repo true)
BAT_BIN=$(choose_by_arch "bat-v${version}-x86_64-unknown-linux-gnu.tar.gz" "bat-v${version}-aarch64-unknown-linux-gnu.tar.gz")
download_install bat "$repo/releases/latest/download/$BAT_BIN"

# sd ##########################################################################
SD_ARCHIVE=$(choose_by_arch 'sd-v1.0.0-x86_64-unknown-linux-musl.tar.gz' 'sd-v1.0.0-aarch64-unknown-linux-musl.tar.gz')
download_install sd "https://github.com/chmln/sd/releases/download/v1.0.0/$SD_ARCHIVE"

# dust ########################################################################
repo="https://github.com/bootandy/dust"
version=$(latest_release_version $repo true)
DUST_BIN=$(choose_by_arch "du-dust_${version}-1_amd64.deb" "dust-v${version}-aarch64-unknown-linux-gnu.tar.gz")
download_install dust "$repo/releases/latest/download/$DUST_BIN"

# jq ##########################################################################
JQ_BIN=$(choose_by_arch 'jq-linux-amd64' 'jq-linux-arm64')
download_install jq "https://github.com/jqlang/jq/releases/latest/download/$JQ_BIN"

# lnav ########################################################################

repo="https://github.com/tstack/lnav"
version=$(latest_release_version $repo true)
LNAV_BIN=$(choose_by_arch "lnav-${version}-linux-musl-x86_64.zip" "lnav-${version}-linux-musl-arm64.zip")
download_extract "$repo/releases/latest/download/$LNAV_BIN"

# just ########################################################################
repo="https://github.com/casey/just"
version=$(latest_release_version $repo)
JUST_BIN="just-${version}-$(choose_by_arch x86_64 aarch64)-unknown-linux-musl.tar.gz"
download_extract "$repo/releases/latest/download/$JUST_BIN"
install_bin just
install_manpage 'just.1'
just --completions zsh >> $ZSH/custom/completions/_just

# Vim #########################################################################
sudo wget https://gist.githubusercontent.com/jatinderjit/f51b7cb01ec7bca4297b0f9f782e4eb1/raw/fc70f8d6be693fb5ac5b1c09a6f8413c2a1159d7/vimrc -O /etc/vim/vimrc.local
mkdir -p ~/.config/nvim
echo 'source /etc/vim/vimrc.local' > ~/.config/nvim/init.vim

# Nginx #######################################################################

if $INSTALL_NGINX; then
    sudo apt install -y nginx
fi

# Certbot #####################################################################
install_certbot() {
    sudo apt-get install -y snapd
    sudo snap install core
    sudo snap refresh core
    sudo snap install --classic certbot
    sudo ln -s /snap/bin/certbot /usr/bin/certbot
}
install_if_required $INSTALL_CERTBOT Certbot certbot install_certbot

# Create User #################################################################

if [ -z "$NEW_USERNAME" ]; then
    echo "Not creating new user"
else
    sudo adduser $NEW_USERNAME
    sudo usermod -aG sudo $NEW_USERNAME
    sudo chsh -s `which zsh` $NEW_USERNAME
    sudo rsync --archive --chown=$NEW_USERNAME:$NEW_USERNAME ~/.ssh /home/$NEW_USERNAME
    sudo rsync --archive --chown=$NEW_USERNAME:$NEW_USERNAME ~/.oh-my-zsh /home/$NEW_USERNAME
    sudo rsync --archive --chown=$NEW_USERNAME:$NEW_USERNAME ~/.zshrc /home/$NEW_USERNAME
    sudo rsync --archive --chown=$NEW_USERNAME:$NEW_USERNAME ~/.config /home/$NEW_USERNAME
fi

# Disable SSH Password Access  ################################################
sudo cp /etc/ssh/sshd_config /tmp
sudo sd 'PasswordAuthentication yes' 'PasswordAuthentication no' /etc/ssh/sshd_config
sudo systemctl restart ssh

# Python ######################################################################

# Pyenv #################

install_pyenv() {
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    sudo mv ~/.pyenv /opt/pyenv
    echo '' >> ~/.zshrc
    echo 'export PYENV_ROOT="/opt/pyenv"' >> ~/.zshrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc
    export PYENV_ROOT=/opt/pyenv
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"

    git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc
    eval "$(pyenv virtualenv-init -)"
}
install_if_required $INSTALL_PYENV Pyenv pyenv install_pyenv

# Poetry ################
install_poetry() {
    curl -sSL https://install.python-poetry.org | sudo POETRY_HOME=/opt/poetry python3 -
    sudo chown -R $(whoami):$(whoami) /opt/poetry
    echo 'export PATH=/opt/poetry/bin:$PATH' >> ~/.zshrc
}
install_if_required $INSTALL_POETRY Poetry poetry install_poetry

# Go ##########################################################################
install_go() {
    local ARCHIVE="go${GO_VERSION}.linux-$(choose_by_arch amd64 arm64).tar.gz"
    wget "https://go.dev/dl/$ARCHIVE"
    tar -xf "$ARCHIVE"
    sudo mv go "/opt/go-${GO_VERSION}"
    sudo ln -s "/opt/go-${GO_VERSION}" /opt/go
    echo 'export PATH=/opt/go/bin:$PATH' >> ~/.zshrc
}
install_if_required $INSTALL_GO Go go install_go

# Redis #######################################################################
install_redis() {
    sudo apt install -y redis-server
    sudo systemctl stop redis
    if $DISABLE_REDIS; then
        sudo systemctl disable redis
    fi
}
install_if_required $INSTALL_REDIS Redis redis-server install_redis

# Postgres ####################################################################
install_postgres() {
    sudo apt install -y postgresql postgis libpq-dev
    sudo systemctl stop postgresql
    if $DISABLE_POSTGRES; then
        sudo systemctl disable postgresql
    fi
}
install_if_required $INSTALL_POSTGRES Postgres psql install_postgres

# zshrc #######################################################################

echo 'export LANG=en_US.UTF-8' >> ~/.zshrc
echo 'export EDITOR=nvim' >> ~/.zshrc
echo >> ~/.zshrc

echo "alias gl='git log'" >> ~/.zshrc
echo "alias glp='git log --patch'" >> ~/.zshrc
echo "alias gap='git add --patch'" >> ~/.zshrc
echo "alias gdc='git diff --cached'" >> ~/.zshrc
echo "unalias gco" >> ~/.zshrc
echo >> ~/.zshrc

echo "alias vim=nvim" >> ~/.zshrc
echo "alias v=vim" >> ~/.zshrc
echo "alias vd="vim -d"" >> ~/.zshrc
echo >> ~/.zshrc

echo "alias rgi='rg -i'" >> ~/.zshrc
echo "alias rgn='rg --no-ignore'" >> ~/.zshrc
echo "alias rgf='rg --files-with-matches'" >> ~/.zshrc
echo "alias -g G='| rg'  # global alias" >> ~/.zshrc
echo "alias -g Gi='| rg -i'" >> ~/.zshrc
echo "alias fdi='fd -i'" >> ~/.zshrc
echo "alias fdn='fd --no-ignore'" >> ~/.zshrc
echo "alias -s git='git clone'" >> ~/.zshrc
echo "alias ls='eza --icons'" >> ~/.zshrc
echo "alias cat='bat --theme=1337'" >> ~/.zshrc
echo "export MANPAGER=\"sh -c 'col -bx | bat --theme=Dracula -l man -p'\"" >> ~/.zshrc
echo "alias py=python" >> ~/.zshrc
echo "alias j=just" >> ~/.zshrc

# oh my zsh plugins ###########################################################
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
add_zsh_plugin zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
add_zsh_plugin zsh-syntax-highlighting

# git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
# add_zsh_plugin zsh-history-substring-search
add_zsh_plugin history-substring-search

sd 'plugins=\(git\)' "plugins=($(echo $ZSH_PLUGINS)\n)" ~/.zshrc
