#/usr/bin/zsh

# BASIC SERVER SETUP

set -e

SERVER_NAME=
# read -p "Enter server name: " SERVER_NAME
# read -p "SSH keys: enter github usernames: " GITHUB_USERNAMES

# Add SSH Keys
GITHUB_USERNAMES=(jatinderjit) # space separated usernames
for username in $GITHUB_USERNAMES; do
    echo "\n# $username" >> ~/.ssh/authorized_keys
    curl "https://github.com/$username.keys" >> ~/.ssh/authorized_keys
done

sudo apt update
sudo apt upgrade
sudo apt install -y zsh git gettext zip unzip

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
echo 'export EDITOR=vim' >> ~/.zshrc
echo "alias gl='git log'" >> ~/.zshrc
echo "alias glp='git log --patch'" >> ~/.zshrc
echo "alias v=vim" >> ~/.zshrc
echo "alias vd="vim -d"" >> ~/.zshrc
echo "alias -g G='| rg'" >> ~/.zshrc  # global alias (substitute anywhere in a command)
echo "alias -g Gi='| rg -i'" >> ~/.zshrc  # global alias (substitute anywhere in a command)
echo "alias -s git='git clone'" >> ~/.zshrc
echo "alias ls=exa" >> ~/.zshrc
echo "alias cat="bat --theme=1337"" >> ~/.zshrc
echo "export MANPAGER=\"sh -c 'col -bx | bat --theme=Dracula -l man -p'\"" >> ~/.zshrc
echo "alias rgn='rg --no-ignore'" >> ~/.zshrc  # to ignore .gitignore (and other ignore files)
echo 'alias ls=exa' >> ~/.zshrc
echo 'alias fd=fdfind' >> ~/.zshrc
echo 'alias py=python' >> ~/.zshrc
echo 'alias j=just' >> ~/.zshrc


# Utilities ###################################################################

# install bat, dust, sd, jq, choose, just
download_install() {
    # download_install name url
    pushd /tmp
    wget $2
    if [[ $2 == *.tar.gz ]]; then
        fn=$(echo $2 | choose -f '/' -1)
        dir_name=$(echo $fn | choose -f '.tar.gz' -1)
        tar -xf $fn
        mv "$dir_name/$1" .
        rm -r $dir_name $fn
    elif [[ $2 == *choose* ]]; then
        mv choose-x86_64-unknown-linux-gnu choose
    else
        mv "$(echo $2 | choose -f '/' -1)" $1
    fi
    sudo chmod +x $1
    sudo mv $1 /usr/local/bin/
    popd
}

sudo apt install -y ripgrep exa
download_install choose https://github.com/theryangeary/choose/releases/download/v1.3.4/choose-x86_64-unknown-linux-gnu
download_install bat https://github.com/sharkdp/bat/releases/download/v0.23.0/bat-v0.23.0-x86_64-unknown-linux-gnu.tar.gz
download_install dust https://github.com/bootandy/dust/releases/download/v0.8.6/dust-v0.8.6-x86_64-unknown-linux-gnu.tar.gz
download_install sd https://github.com/chmln/sd/releases/download/v0.7.6/sd-v0.7.6-x86_64-unknown-linux-gnu
download_install jq https://github.com/jqlang/jq/releases/download/jq-1.6/jq-linux64

wget https://github.com/casey/just/releases/download/1.14.0/just-1.14.0-x86_64-unknown-linux-musl.tar.gz
tar -xf just-1.14.0-x86_64-unknown-linux-musl.tar.gz && rm just-1.14.0-x86_64-unknown-linux-musl.tar.gz && rm just.1
sudo chmod +x just && sudo mv just /usr/local/bin
mkdir $ZSH/custom/plugins/just
just --completions zsh >> $ZSH/custom/plugins/just/_just
sd 'plugins=\(git\)' 'plugins=(git just)' ~/.zshrc
omz reload

# Vim #########################################################################
sudo wget https://gist.githubusercontent.com/jatinderjit/f51b7cb01ec7bca4297b0f9f782e4eb1/raw/d026fb2c7cf57f5a2104b468f23c7de283297935/vimrc -O /etc/vim/vimrc.local

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
omz reload

git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc
omz reload

sudo apt install -y build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Poetry ################
curl -sSL https://install.python-poetry.org | sudo POETRY_HOME=/opt/poetry python3 -
sudo chown -R $(whoami):$(whoami) /opt/poetry
echo 'export PATH=/opt/poetry/bin:$PATH' >> ~/.zshrc
echo ''
omz reload

# Go ##########################################################################
cd /tmp/
wget https://go.dev/dl/go1.20.5.linux-amd64.tar.gz
sudo mv go /opt/go-1.20.5
sudo ln -s /opt/go-1.20.5 /opt/go
echo 'export PATH=/opt/go/bin:$PATH' >> ~/.zshrc
omz reload

# Redis #######################################################################
sudo apt install redis-server
sudo systemctl stop redis
sudo systemctl disable redis

# Postgres ####################################################################
sudo apt install postgresql postgis libpq-dev
sudo systemctl stop postgresql
sudo systemctl disable postgresql
