#/usr/bin/zsh

set -e

SERVER_NAME=
# read -p "Enter server name: " SERVER_NAME
# read -p "SSH keys: enter github usernames: " GITHUB_USERNAMES

ZSH_PLUGINS=''
add_zsh_plugin () {
    ZSH_PLUGINS="$ZSH_PLUGINS\n  $1"
}
add_zsh_plugin git
add_zsh_plugin pip

# Add SSH Keys
GITHUB_USERNAMES=(jatinderjit) # space separated usernames
for username in $GITHUB_USERNAMES; do
    echo "\n# $username" >> ~/.ssh/authorized_keys
    curl "https://github.com/$username.keys" >> ~/.ssh/authorized_keys
done

sudo apt update
sudo apt upgrade

sudo apt install -y zsh git gettext zip unzip
sudo apt install -y build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev curl \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev


# ZSH #########################################################################
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

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

echo 'export LANG=en_US.UTF-8' >> ~/.zshrc
echo 'export EDITOR=nvim' >> ~/.zshrc
echo '' >> ~/.zshrc

echo "alias gl='git log'" >> ~/.zshrc
echo "alias glp='git log --patch'" >> ~/.zshrc
echo "alias gap='git add --patch'" >> ~/.zshrc
echo "alias gdc='git diff --cached'" >> ~/.zshrc
echo "unalias gco" >> ~/.zshrc
echo '' >> ~/.zshrc

echo "alias vim=nvim" >> ~/.zshrc
echo "alias v=vim" >> ~/.zshrc
echo "alias vd="vim -d"" >> ~/.zshrc
echo '' >> ~/.zshrc

echo "alias rgi='rg -i'" >> ~/.zshrc
echo "alias rgn='rg --no-ignore'" >> ~/.zshrc
echo "alias rgf='rg --files-with-matches'" >> ~/.zshrc
echo "alias -g G='| rg'" >> ~/.zshrc  # global alias (substitute anywhere in a command)
echo "alias -g Gi='| rg -i'" >> ~/.zshrc  # global alias (substitute anywhere in a command)
echo "alias fdi='fd -i'" >> ~/.zshrc
echo "alias fdn='fd --no-ignore'" >> ~/.zshrc
echo "alias -s git='git clone'" >> ~/.zshrc
echo "alias ls='eza --icons'" >> ~/.zshrc
echo "alias cat='bat --theme=1337'" >> ~/.zshrc
echo "export MANPAGER=\"sh -c 'col -bx | bat --theme=Dracula -l man -p'\"" >> ~/.zshrc
echo "alias fd=fdfind" >> ~/.zshrc
echo "alias py=python" >> ~/.zshrc
echo "alias j=just" >> ~/.zshrc


# Utilities ###################################################################

download_extract() {
    url=$1
    pushd /tmp
    wget $url
    fn=$(echo $url | choose -f '/' 1)
    dir_name=$(echo $fn | choose -f '.tar.gz' -1)
    popd
}

# install bat, dust, sd, jq, choose, just
download_install() {
    # download_install name url
    bin_name=$1
    bin_url=$2
    pushd /tmp
    wget $bin_url
    if [[ $bin_url == *.tar.gz ]]; then
        fn=$(echo $bin_url | choose -f '/' -1)
        dir_name=$(echo $fn | choose -f '.tar.gz' -1)
        tar -xf $fn
        mv "$dir_name/$bin_name" .
        rm -r $dir_name $fn
    elif [[ $bin_url == *choose* ]]; then
        mv choose-x86_64-unknown-linux-gnu choose
    else
        mv "$(echo $bin_url | choose -f '/' -1)" $1
    fi
    sudo chmod +x $bin_name
    sudo mv $bin_name /usr/local/bin/
    popd
}

download_install choose https://github.com/theryangeary/choose/releases/latest/download/choose-x86_64-unknown-linux-gnu

if [ $(which nvim) ]; then
    echo "Already installed: nvim"
else
    download_extract https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    sudo mv nvim-linux64 /opt/nvim
    rm nvim-linux64.tar.gz
    echo '' >> ~/.zshrc
    echo 'export PATH="/opt/nvim/bin:$PATH"' >> ~/.zshrc
    echo "Installed: nvim"
fi

if [ $(which cargo) ]; then
    echo "Already installed: rust"
else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source ~/.zshrc
    echo "Installed: rust"
fi

if [ $(which rg) ]; then
    echo "Already installed: ripgrep"
else
    cargo install ripgrep
    echo "Installed: ripgrep"
fi
add_zsh_plugin ripgrep  # Always add

if [ $(which eza) ]; then
    echo "Already installed: eza"
else
    cargo install eza
    echo "Installed: eza"
fi
add_zsh_plugin eza

if [ $(which fd) ]; then
    echo "Already installed: fd"
else
    cargo install fd-find
    echo "Installed: fd"
fi
add_zsh_plugin fd

if [ $(which bat) ]; then
    echo "Already installed: bat"
else
    cargo install bat
    echo "Installed: bat"
fi

if [ $(which sd) ]; then
    echo "Already installed: sd"
else
    cargo install sd
    echo "Installed: sd"
fi

if [ $(which dust) ]; then
    echo "Already installed: dust"
else
    cargo install du-dust
    echo "Installed: dust"
fi


if [ $(which jq) ]; then
    echo "Already installed: jq"
else
    download_install jq https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64
    echo "Installed: jq"
fi

wget https://github.com/casey/just/releases/download/1.25.2/just-1.25.2-x86_64-unknown-linux-musl.tar.gz
tar -xf just-1.25.2-x86_64-unknown-linux-musl.tar.gz && rm just-1.25.2-x86_64-unknown-linux-musl.tar.gz && rm just.1
sudo chmod +x just && sudo mv just /usr/local/bin
mkdir $ZSH/custom/plugins/just
just --completions zsh >> $ZSH/custom/plugins/just/_just
add_zsh_plugin just

# Vim #########################################################################
sudo wget https://gist.githubusercontent.com/jatinderjit/f51b7cb01ec7bca4297b0f9f782e4eb1/raw/ba46fae8241a7a43c54672037fc07bb4f7b0427e/vimrc -O /etc/vim/vimrc.local

# Certbot ###################################################################
# sudo apt-get install -y snapd
# sudo snap install core
# sudo snap refresh core
# sudo snap install --classic certbot
# sudo ln -s /snap/bin/certbot /usr/bin/certbot

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

# Poetry ################
if [ $(which poetry) ]; then
    echo "Already installed: poetry"
else
    curl -sSL https://install.python-poetry.org | sudo POETRY_HOME=/opt/poetry python3 -
    sudo chown -R $(whoami):$(whoami) /opt/poetry
    echo 'export PATH=/opt/poetry/bin:$PATH' >> ~/.zshrc
    echo ''
    echo "Installed: poetry"
fi

# Go ##########################################################################
if [ $(which go) ]; then
    echo "Already installed: go"
else
    cd /tmp/
    wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
    tar -xf go1.22.0.linux-amd64.tar.gz
    sudo mv go /opt/go-1.22.0
    sudo ln -s /opt/go-1.22.0 /opt/go
    echo 'export PATH=/opt/go/bin:$PATH' >> ~/.zshrc
    echo "Installed: go"
fi

# Redis #######################################################################
sudo apt install redis-server
sudo systemctl stop redis
sudo systemctl disable redis

# Postgres ####################################################################
sudo apt install postgresql postgis libpq-dev
sudo systemctl stop postgresql
sudo systemctl disable postgresql

# oh my zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
add_zsh_plugin zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
add_zsh_plugin zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
add_zsh_plugin zsh-history-substring-search

sd 'plugins=\(git\)' "plugins=($(echo $ZSH_PLUGINS)\n)" ~/.zshrc
