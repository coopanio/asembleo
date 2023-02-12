# Asembleo
  
[![CodeQL](https://github.com/coopanio/asembleo/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/coopanio/asembleo/actions/workflows/codeql-analysis.yml)
[![Semgrep](https://github.com/coopanio/asembleo/actions/workflows/semgrep.yml/badge.svg)](https://github.com/coopanio/asembleo/actions/workflows/semgrep.yml)
[![Coverage Status](https://coveralls.io/repos/github/coopanio/asembleo/badge.svg?branch=dcc/gh-rails-test-run)](https://coveralls.io/github/coopanio/asembleo?branch=dcc/gh-rails-test-run)
[![DeepSource](https://deepsource.io/gh/coopanio/asembleo.svg/?label=active+issues&show_trend=true&token=G_FrkdoCFPuIPKU-lYa2OSnT)](https://deepsource.io/gh/coopanio/asembleo/?ref=repository-badge)

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
