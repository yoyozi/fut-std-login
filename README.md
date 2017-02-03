## Loading this App to build on Digital Ocean

**Clone the std app to your desktop as the name of the new application**
> git clone https://github.com/yoyozi/reponame.git newreponame

**Create newreponame on github**
**Set the remote to created**

> git remote set-url origin https://github.com/yoyozi/newreponame.git

**Submit to repo just created**
> git add -A
> git commit -m "Ready" 
> git push -u origin master
> git push -u origin master

## On remote: Sign up with Digital Ocean or rebuild your existing droplet
Delete the fingerprints of the known host in the known hosts file on your local machine

**User accounts and remote ssh. On droplet**
Log in with you cert and change root password
> passwd
> adduser username
> adduser deploy_user
> gpasswd -a username sudo
> gpasswd -a deploy_user sudo

**Make editing the sudo file use vim**
__AFTER Defaults        env_reset
>Defaults        editor=/usr/bin/vim

**Make the deploy user passwordless when running listed commands/apps**
> visudo

```
for now
#deploy_user ALL=(ALL) NOPASSWD:ALL
will change later to 
deploy_user ALL=NOPASSWD:/usr/bin/apt-get
```

## On local machine (on mac use):
> ssh-copy-id deploy_user@x.x.x.x
> ssh-copy-id username@x.x.x.x

**Test that you can login with the deployer user and your own username, and su to root BEFORE removing root remote login!!!**
> ssh -p xxxx deployer@x.x.x.x
> sudu su -

**For better security, it's recommended that you disable remote root login**
> vi /etc/ssh/sshd_config

```
Port 22 # change this to whatever port you wish to use
Protocol 2
PermitRootLogin no
(At the end of sshd_config, enter):
UseDNS no
AllowUsers username username
```

**To squeulch the perl WARNIG**

Edit the /etc/ssh/ssh_config file
> vi /etc/ssh/ssh_config
Find the line "SendEnv LANG LC_*"

```
# SendEnv LANG LC_*
```

Save the file
> reload ssh

## Digital Ocean specific

Configure the time zone and ntp service
> sudo dpkg-reconfigure tzdata
> sudo apt-get install ntp

Configure swap space
> sudo fallocate -l 4G /swapfile
> sudo chmod 600 /swapfile
> sudo mkswap /swapfile
> sudo swapon /swapfile
> sudo sh -c 'echo "/swapfile none swap sw 0 0" >> /etc/fstab'

**Setup ssh login to Github from the droplet server so no password is used to pull repository**

As the deploying user run
> ssh-keygen -t rsa

Cut and paste the output of below (the public key) to your github repo
> cat ./.ssh/id_rsa.pub

Test the login to github
> ssh -T git@github.com
Should be a welcome message

Set the locale (add at end of file)
> sudo vi /etc/environment
> export LANG=en_US.utf8

## On local 

In the Capfile make sure these are all commented out
```
#require 'capistrano/figaro_yml'
#require "capistrano/rbenv"
#require "capistrano/bundler"
#require "capistrano/rails/assets"
#require "capistrano/rails/migrations"
#require 'capistrano/safe_deploy_to'
#require 'capistrano/unicorn_nginx'
#require 'capistrano/rbenv_install'
#require 'capistrano/secrets_yml'
#require 'capistrano/database_yml'
```

## Run the task droplet:dsetup
Make sure file looks like this
```
namespace :droplet do

  desc "Updating the server"  
  task :setup do   
      on roles(:app) do 
        execute "echo 'export LANG=\"en_US.utf8\"' >> ~/.bashrc"
        execute "echo 'export LANGUAGE=\"en_US.utf8\"' >> ~/.bashrc"
        execute "echo 'export LC_ALL=\"en_US.UTF-8\"' >> ~/.bashrc"
        execute "source /home/#{fetch(:user)}/.bashrc"
        execute "source /home/deployer/.bashrc"
        execute :sudo, "/usr/bin/apt-get -y update"
        execute :sudo, "/usr/bin/apt-get -y install python-software-properties"
        execute :sudo,  "apt-get -y install git-core curl zlib1g-dev logrotate build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev libpq-dev"
        execute :sudo, "apt-get -y install nginx"
        execute :sudo, "apt-get -y install postgresql postgresql-contrib libpq-dev"
        execute :sudo, "service postgresql start"
        execute 'echo | sudo add-apt-repository ppa:chris-lea/node.js'          
        execute :sudo, "/usr/bin/apt-get -y install nodejs"
        execute :sudo, "/usr/bin/apt-get -y update"  
    end  
  end 
end
```

## On remote: setup postgresql on the remote server
> sudo -u postgresql createuser -s rails-psql-user
> sudo -u postgres psql
> \password (set the postgres user password)
> \password rails-psql-user (set the rails-user password)
> sudo -u postgres createdb chraig_production
> \q

## on local

**Ensure IP address and the project repo is adjusted to suite**
deploy.rb and production.rb

Create the ./config/secrets.yml file and use keys "rake secret" to populate
```
development:
  secret_key_base: xxx
test:
  secret_key_base: xxxcxccv
production:
  secret_key_base: <%= ENV['SECTRETSTRING'] %>
```

Create ./config/application.yml file for figaro
```
production:
   DBPW: thepw
   SECTRETSTRING: "the string from rake secret"
```

Create the database.yml file
```
default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5
  host: localhost

development:
  <<: *default
  database: db_development

test:
  <<: *default
  database: db_test

production:
  <<: *default
  database: db_production
  username: rails-psql-user
  password: <%= ENV['production-DB-password'] %>
```

Create linked files and directories by adding into deploy.rb
```
set :linked_files, %w{config/database.yml}
set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
```

In the Capfile make sure these are all NOT commented out
```
require 'capistrano/figaro_yml'
require "capistrano/rbenv"
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require 'capistrano/safe_deploy_to'
require 'capistrano/unicorn_nginx'
require 'capistrano/rbenv_install'
require 'capistrano/secrets_yml'
require 'capistrano/database_yml'
```

## Install bootstrap srr (https://github.com/twbs/bootstrap-sass)
Add gem 'bootstrap-sass', '~> 3.3', '>= 3.3.6' in Gemfile
change file application.css to application.css.scss 
> vi ./application.css.scss 

Add at bof
```
@import "bootstrap-sprockets";
@import "bootstrap";
```

bootstrap-sprockets provides individual Bootstrap Javascript files (alert.js or dropdown.js, for example), while bootstrap provides a concatenated file containing all Bootstrap Javascripts.
> vi application.js 

```
//= require bootstrap-sprockets
```

## Setup the server

> cap -T
> cap production safe_deploy_to:ensure
> cap production setup
> cap production deploy


## Layout and formatting

**Bootstrap and fontawesome install**

In Gemfile add and bundle:
```
gem 'bootstrap-sass', '~> 3.3', '>= 3.3.6'
gem 'font-awesome-sass', '~> 4.5.0'
gem 'bootstrap-sass-extras'
```

Application.css rename to application.css.scss
> vi application.css.scss 

And add:
```
 *= require_tree .
 *= require_self
 */

@import "bootstrap";
@import "bootstrap-sprockets";

@import "font-awesome";
@import "font-awesome-sprockets";
```

> rails g bootstrap:install
and for responsive layout run 
>rails g bootstrap:layout application fluid

## Authentication with Devise

In Gemfile add and bundler
```
gem 'devise'
```
> bundle 
> rails generate devise:install
> rails generate devise User (user is the model you choose)

gem 'bootstrap-sass-extras' gives you auto alerting and flash messaging so you dont need to add  in the file: 
<p class="notice"><%= notice %></p>
<p class="alert"><%= alert %></p>

Change the User miration created to be
```
class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :username,           null: false, default: ""
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end
end
```

> rake db:migrate

**Adding simpleform (Also by platformatec who do Devise)**
In Gemfile add and bundle 
```
gem 'simple_form'
```
> bundle

Simple Form can be easily integrated to the Bootstrap. To do that you have to use the bootstrap option in the install generator, like this:
>rails generate simple_form:install --bootstrap

NOW install the Devise views as devise uses simple form
> rails g devise:views

Edit the development.rb file in environment folder to cater for mailing to url
```
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```
















