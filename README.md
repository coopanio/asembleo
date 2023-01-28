# Asembleo

Pseudoanonymous voting system for general assemblies

## Setup

```shell
apt install dirmngr gpg curl git gawk nginx

git clone https://github.com/coopanio/asembleo.git /opt/asembleo
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.11.1

echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
. "$HOME/.asdf/asdf.sh"

asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git

asdf install ruby 3.2.0
asdf install nodejs 19.5.0

asdf global nodejs 3.2.0
asdf global nodejs 19.5.0

npm install --global yarn
cd /opt/asembleo
yarn

RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rake db:migrate
```