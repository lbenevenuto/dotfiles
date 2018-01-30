#!/usr/bin/env bash

# Constants
black=`tput setaf 0`;
red=`tput setaf 1`;
green=`tput setaf 2`;
yellow=`tput setaf 3`;
blue=`tput setaf 4`;
magenta=`tput setaf 5`;
cyan=`tput setaf 6`;
white=`tput setaf 7`;
reset=`tput sgr0`;

if [[ -e $HOME/.dotfiles/.bootstrap ]]; then
	echo "Bootstrap has been executed already."
	echo "If you really want to run this again: rm \$HOME/.dotfiles/.bootstrap"
	exit 0
fi

echo "${green}Instalando as dependencias${reset}"
sudo apt-get update && sudo apt-get install -fy \
    ntp \
    ssh \
    openssl \
    apt-transport-https \
    ca-certificates \
    gnupg2 \
    software-properties-common \
    build-essential \
    curl \
    libcurl4-openssl-dev \
    git \
    git-flow \
    zsh \
    vim \
    pkg-config \
    autoconf \
    automake \
    libtool \
    nasm \
    zip unzip bzip2 \
    #zram-config \
    aptitude
    #gcm
    #libpg-perl \
    #postgresql-client \
    #postgresql-server-dev-all \

echo "${green}Full-Upgrade do sistema${reset}";
sudo aptitude -fy full-upgrade;

# Install nvm
echo "${green}Instalando o nvm${reset}";
export NVM_DIR="$HOME/.nvm" && (
    git clone https://github.com/creationix/nvm.git "$NVM_DIR"
    cd "$NVM_DIR"
    #git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" origin`

    # Get new tags from remote
    git fetch --tags

    # Get latest tag name
    latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)

    # Checkout latest tag
    git checkout $latestTag

) && . "$NVM_DIR/nvm.sh"

# Install Node-latest
echo "${green}Instalando o node e latest npm${reset}";
nvm install node --latest-npm

# Install Yarn
echo "${green}Instalando o Yarn${reset}";
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install -fy yarn

echo "${green}Install PERL modules${reset}";
curl -L https://cpanmin.us | perl - --sudo App::cpanminus

sudo cpanm YAML;
#sudo cpanm Log::Log4perl Log::Dispatch::Email::MailSend JSON::Parse File::Slurp Benchmark Modern::Perl common::sense DDP MIME::Lite DBI;
#sudo cpanm JSON Net::SFTP Net::FTP Spreadsheet::XLSX Spreadsheet::ParseXLSX List::Util;
#sudo cpanm Digest::MD5 DateTime Date::Parse Text::Soundex Net::Curl;
#sudo cpanm YADA WWW::UserAgent::Random File::Listing DBD::Pg JSON::Any Locale::Currency::Format Date::Calc;
#sudo cpanm Date::Calc::XS Cpanel::JSON::XS JSON::XS

# Install oh-my-zsh
echo "${green}Instalando o oh-my-zsh${reset}";
chsh -s $(which zsh);
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)";

echo "${green}Alterando o .zshrc${reset}";
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.zshrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> ~/.zshrc

# Install Spaceship theme
echo "${green}Instalando o spaceship-zsh-theme${reset}";
npm install -g spaceship-zsh-theme
echo 'SPACESHIP_TIME_SHOW=true' >> ~/.zshrc
echo 'SPACESHIP_BATTERY_SHOW=true' >> ~/.zshrc
echo 'DISABLE_UPDATE_PROMPT=true' >> ~/.zshrc
echo 'export UPDATE_ZSH_DAYS=1' >> ~/.zshrc
echo 'HIST_STAMPS="dd.mm.yyyy"' >> ~/.zshrc
# Colocando os plugins no lugar certo
sed --follow-symlinks -i -e "s/\(source \$ZSH\/oh-my-zsh.sh\)/plugins\+\=\(git-flow docker docker-compose perl cpanm common-aliases nvm npm node composer laravel5 redis-cli supervisor ubuntu sudo debian\)\n\1/" ~/.zshrc
#echo 'plugins+=(git-flow docker docker-compose perl cpanm common-aliases nvm npm node composer laravel5 redis-cli supervisor ubuntu sudo debian)' >> ~/.zshrc

# linkando os aliases
echo "${green}Linkando os aliases${reset}";
ln -s ~/.dotfiles/.aliases ~/.aliases
echo 'source $HOME/.aliases' >> ~/.zshrc
echo 'ulimit -n 65536' >> ~/.zshrc

# Setando o vim como editor principal
echo "${green}Alterando o editor default${reset}";
#sudo update-alternatives --config editor
echo 'export VISUAL="vim"' >> ~/.zshrc
echo 'export EDITOR="vim"' >> ~/.zshrc
echo "echo 'export VISUAL=\"vim\"' >> /etc/bash.bashrc" | sudo sh
echo "echo 'export EDITOR=\"vim\"' >> /etc/bash.bashrc" | sudo sh

# instalando Docker
echo "${green}Instalando o docker${reset}";
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -fy docker-ce
sudo gpasswd -a $USER docker

# instalando o Docker compose
echo "${green}Instalando o docker compose${reset}";
sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
sudo docker pull alpine

# linkando os update all images
echo "${green}Linkando o update all docker images${reset}";
ln -s ~/.dotfiles/update-docker-images.sh ~/update-images.sh

# Instalando o mozjpeg
echo "${green}Instalando o mozjpeg${reset}";
git clone git@github.com:mozilla/mozjpeg.git /tmp/mozjpeg
cd /tmp/mozjpeg
git checkout $(git describe --tags $(git rev-list --tags --max-count=1))
autoreconf -fiv
./configure
make all
#make test
sudo make install

# Cleanup
echo "${green}Limpando o apt${reset}";
sudo apt-get autoremove -y

echo "${cyan}Reboot?${reset}"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) sudo init 6; break;;
        No ) exit;;
        * ) echo "${red}Please answer 1 or 2.${reset}";;
    esac
done

cd ~