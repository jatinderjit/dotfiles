#/usr/bin/zsh

SERVER_NAME=
GITHUB_USERNAMES=(jatinderjit) # space separated usernames to add ssh keys
INSTALL_OH_MY_ZSH=true  # Mandatory
INSTALL_OH_MY_ZSH_PLUGINS=true
INSTALL_PYENV=true  # Installs at /opt/pyenv
INSTALL_POETRY=true  # Installs at /opt/poetry
INSTALL_GO=true  # Installs at /opt/go
GO_VERSION=1.22.0
INSTALL_RUST=false
INSTALL_POSTGRES=false
INSTALL_REDIS=false
INSTALL_NGINX=true
INSTALL_CERTBOT=true
BIN_PATH='/usr/local/bin'

# END: Configuration ##########################################################

set -e

cd /tmp

sudo apt update
sudo apt upgrade

sudo apt install -y zsh git gettext zip unzip
sudo apt install -y build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev curl \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

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

wget https://github.com/theryangeary/choose/releases/latest/download/choose-x86_64-unknown-linux-gnu
install_bin choose choose-x86_64-unknown-linux-gnu

if [ $(which nvim) ]; then
    echo "Already installed: nvim"
else
    download_extract https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    sudo mv nvim-linux64 /opt/nvim
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
download_install rg "$repo/releases/latest/download/ripgrep-${version}-x86_64-unknown-linux-musl.tar.gz"
add_zsh_plugin ripgrep

download_install eza https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-musl.tar.gz
add_zsh_plugin eza

# fd ##########################################################################
repo="https://github.com/sharkdp/fd"
version=$(latest_release_version $repo true)
download_install "$repo/releases/latest/download/fd-musl_${version}_amd64.deb"

# bat #########################################################################
repo="https://github.com/sharkdp/bat"
version=$(latest_release_version $repo true)
download_install x "$repo/releases/latest/download/bat-musl_${version}_amd64.deb"

# sd ##########################################################################
download_install sd https://github.com/chmln/sd/releases/download/v1.0.0/sd-v1.0.0-x86_64-unknown-linux-musl.tar.gz

# dust ########################################################################
repo="https://github.com/bootandy/dust"
version=$(latest_release_version $repo true)
download_install x "$repo/releases/latest/download/du-dust_${version}-1_amd64.deb"

# jq ##########################################################################
download_install jq https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64

# lnav ########################################################################
repo="https://github.com/tstack/lnav"
version=$(latest_release_version $repo true)
download_extract "$repo/releases/latest/download/lnav-${version}-linux-musl-x86_64.zip"
install_bin lnav "lnav-$version/lnav"
install_manpage "lnav-$version/lnav.1"
rm -r "lnav-$version"

# just ########################################################################
repo="https://github.com/casey/just"
version=$(latest_release_version $repo)
download_extract "$repo/releases/latest/download/just-${version}-x86_64-unknown-linux-musl.tar.gz"
install_bin just
install_manpage 'just.1'
mkdir -p $ZSH/custom/plugins/just
just --completions zsh >> $ZSH/custom/plugins/just/_just
add_zsh_plugin just

# Vim #########################################################################
sudo wget https://gist.githubusercontent.com/jatinderjit/f51b7cb01ec7bca4297b0f9f782e4eb1/raw/ba46fae8241a7a43c54672037fc07bb4f7b0427e/vimrc -O /etc/vim/vimrc.local
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

# read -p "Enter new User name: " NEW_USERNAME
# adduser $NEW_USERNAME
# usermod -aG sudo $NEW_USERNAME
# chsh -s `which zsh` $NEW_USERNAME
# rsync --archive --chown=$NEW_USERNAME:$NEW_USERNAME ~/.ssh /home/$NEW_USERNAME
# rsync --archive --chown=$NEW_USERNAME:$NEW_USERNAME ~/.oh-my-zsh /home/$NEW_USERNAME
# rsync --archive --chown=$NEW_USERNAME:$NEW_USERNAME ~/.zshrc /home/$NEW_USERNAME


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
    wget "https://go.dev/dl/go{$GO_VERSION}.linux-amd64.tar.gz"
    tar -xf "go{$GO_VERSION}.linux-amd64.tar.gz"
    sudo mv go "/opt/go-{$GO_VERSION}"
    sudo ln -s "/opt/go-{$GO_VERSION}" /opt/go
    echo 'export PATH=/opt/go/bin:$PATH' >> ~/.zshrc
}
install_if_required $INSTALL_GO Go go install_go

# Redis #######################################################################
sudo apt install redis-server
sudo systemctl stop redis
sudo systemctl disable redis
install_if_required $INSTALL_REDIS Redis redis-server install_redis

# Postgres ####################################################################
install_postgres() {
    sudo apt install postgresql postgis libpq-dev
    sudo systemctl stop postgresql
    sudo systemctl disable postgresql
}
install_if_required $INSTALL_POSTGRES Postgres psql install_postgres

# oh-my-zsh ###################################################################
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

cat > ~/.oh-my-zsh/custom/themes/custom.zsh-theme <<- EOM
local ret_status="%{\$fg_bold[red]%}%{\$bg[white]%} \$USER @ SERVER_NAME %{\$reset_color%} %(?:%{\$fg_bold[green]%}➜ :%{\$fg_bold[red]%}➜ )"

PROMPT='\${ret_status} %{\$fg[cyan]%}%c%{\$reset_color%} \$(git_prompt_info)'  # %{\$bg[red]%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{\$fg_bold[blue]%}git:(%{\$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{\$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{\$fg[blue]%}) %{\$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{\$fg[blue]%})"
EOM

sed -i "s/SERVER_NAME/$SERVER_NAME/" ~/.oh-my-zsh/custom/themes/custom.zsh-theme
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="custom"/' ~/.zshrc

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

git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
add_zsh_plugin zsh-history-substring-search

sd 'plugins=\(git\)' "plugins=($(echo $ZSH_PLUGINS)\n)" ~/.zshrc
