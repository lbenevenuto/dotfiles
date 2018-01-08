#!/usr/bin/env bash

if [[ -e $HOME/.dotfiles/.bootstrap ]]; then
	echo "Bootstrap has been executed already."
	echo "If you really want to run this again: rm \$HOME/.dotfiles/.bootstrap"
	exit 0
fi

sudo apt-get update && sudo apt-get install -fy \
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
    aptitude \
    #libpg-perl \
    #postgresql-client \
    #postgresql-server-dev-all \
    ;

# Install nvm
export NVM_DIR="$HOME/.nvm" && (
  git clone https://github.com/creationix/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" origin`
) && . "$NVM_DIR/nvm.sh"

# Install Node-latest
nvm install node
npm install -g \
    npm \
    less

# Install Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install -fy yarn

echo "Install PERL modules";
curl -L https://cpanmin.us | perl - --sudo App::cpanminus

sudo cpanm YAML;
#sudo cpanm Log::Log4perl Log::Dispatch::Email::MailSend JSON::Parse File::Slurp Benchmark Modern::Perl common::sense DDP MIME::Lite DBI;
#sudo cpanm JSON Net::SFTP Net::FTP Spreadsheet::XLSX Spreadsheet::ParseXLSX List::Util;
#sudo cpanm Digest::MD5 DateTime Date::Parse Text::Soundex Net::Curl;
#sudo cpanm YADA WWW::UserAgent::Random File::Listing DBD::Pg JSON::Any Locale::Currency::Format Date::Calc;
#sudo cpanm Date::Calc::XS Cpanel::JSON::XS JSON::XS

# Install oh-my-zsh
chsh -s $(which zsh);
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)";

echo "Alterando o .zshrc"
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.zshrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> ~/.zshrc

# Install Spaceship theme
echo "Instalando o spaceship-zsh-theme";
npm install -g spaceship-zsh-theme
echo 'SPACESHIP_TIME_SHOW=true' >> ~/.zshrc
echo 'SPACESHIP_BATTERY_SHOW=true' >> ~/.zshrc
echo 'DISABLE_UPDATE_PROMPT=true' >> ~/.zshrc
echo 'export UPDATE_ZSH_DAYS=1' >> ~/.zshrc
echo 'HIST_STAMPS="dd.mm.yyyy"' >> ~/.zshrc
echo 'plugins+=(git-flow docker docker-compose perl cpanm common-aliases nvm npm node composer laravel5 redis-cli supervisor ubuntu sudo debian)' >> ~/.zshrc

# linkando os aliases
ln -s ~/.dotfiles/.aliases ~/.aliases
echo 'source $HOME/.aliases' >> ~/.zshrc
echo 'ulimit -n 65536' >> ~/.zshrc

# Setando o vim como editor principal
sudo update-alternatives --config editor

# instalando Docker
echo "Instalando o docker"
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -fy docker-ce
gpasswd -a $USER docker

# instalando o Docker compose
echo "Instalando o docker compose"
sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# Cleanup
echo "Limpando o apt";
sudo apt-get autoremove -y

cd ~