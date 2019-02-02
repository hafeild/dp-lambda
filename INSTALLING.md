# Installing Alice

## Development

### First time setup
First, install Ruby 2.3 or greater. If developing on Windows, install
[RailsInstaller](http://railsinstaller.org/en) (Ruby 2.3). There may be in issue
with a few of the commands, so after cloning, do the following in the alice
directory (this will remove rails, but don't worry, it'll be reinstalled with
the next step):

    gem uninstall rails 5.0.2 

Install [ImageMagick](https://www.imagemagick.org/script/binary-releases.php)
(required for uploading photos). This needs to be done before moving on or else
uploads won't work properly (everything else should function).

Install Java 1.8 or above. Make sure that the `JAVA_HOME` environment variable
is set up properly and points to the correct Java install. This is needed for
the document indexer (Solr/Lucene) and without it, you won't be able to use the
search feature.

To clone, go into the desired parent directory in a terminal window. When
changing directories, be sure to use the correct capitalization (e.g., if
developing on Windows, if Desktop is your parent folder for Alice, do:
`cd ~/Desktop`, not `cd ~/desktop`. This is true any time you navigate to
the Alice directory in a terminal. Ruby will not interpret paths correctly
if you use the incorrect capitalization, even if Windows is happy to let you
do it from the terminal. Here's the command to clone:

    git clone https://github.com/hafeild/alice.git

That'll make a new directory called `alice` that you can decend into.

On any system, do the following after the initial clone or any subsequent pull
to install any gems that were added to the Gemfile; this should be done from
within the `alice` directory:

    bundle install --without=production

After the initial clone, do the following:

    cp application.EXAMPLE.yml config/application.yml

and fill out `config/application.yml`. For development, nothing really needs to
be filled in. This file is in the ignore list, so it will never be committed.

After the first install, configure and run migrations:

    bundle exec rake db:migrate
    bundle exec rake db:migrate RAILS_ENV=test



### After every update

Check if `application.EXAMPLE.yml` has changed; if so, see what has changed
and migrate any new settings over to your `config/application.yml` file. One
way to do this is to look at the differences between those two files:

    diff application.EXAMPLE.yml config/application.yml
    
Check for entire lines that exist in the former but not the latter.

Install any new gems specified in the Gemfile:

    bundle install --without=production

Run the migrations in the test and development environments:

    bundle exec rake db:migrate
    bundle exec rake db:migrate RAILS_ENV=test

Any time you want to run a test, do:

    ## Start Solr (this uses the development version; you can swap it out for
    ## your own version of Solr; see below).
    bundle exec rake sunspot:solr:run RAILS_ENV=test

    ## In a separate terminal, run:
    bundle exec rake test

    ## Ctr-C the solor instance in the first terminal when you're finished
    ## running the tests.


Start the Solr dev instance. You can do this by manually starting a Solr
instance (see the Setting up Solr section), or use the built-in Sunspot Solr, 
as described here:

    bundle exec rake sunspot:solr:run

Reindex all data (unless you know for a fact that nothing has changed with 
indexing):

    bundle exec rake sunspot:reindex

To start the dev server, do:

    bin/rails s

That will fire up a server at [http://localhost:3000]() (3000 is the default
port, but if it's in use, another may be used; the port used will be displayed
in the output of the command).

When signing up, resetting your password, or changing your email address in
development mode, no real email will be sent. Instead, you can view the
appropriate email (and access the necessary activation link) by looking at
the server output (the contents of the email message will be printed in
it entirety to the console, so you can copy and paste the confirmation link).

## Production

This assumes production is running on Ubuntu and will use Apache + Unicorn,
and have SSL enabled. 

### Setting up the environment

Install the following packages:

    sudo apt-get update
    sudo apt-get install -y git imagemagick nodejs postgresql libpq-dev \
        make libreadline-dev sqlite3 apache2 sendmail

You will need Java 1.8 in order to use Solr; to install the Oracle version, do:

    sudo add-apt-repository ppa:webupd8team/java
    sudo apt-get update
    sudo apt-get install oracle-java8-installer

Set as default java -- if you don't do this, make sure that you set JAVA_HOME
to point to the 1.8 version and update the `init.d/alice` script below to
reflect the installation path to Java 1.8.

    sudo apt-get install oracle-java8-set-default

Start the Postgres server

    sudo service postgresql start


Open the Postgres file for editing using the following command:

    sudo vim $(sudo -u postgres psql -t -P format=unaligned -c 'show hba_file')

Add the line:

    host DB_NAME DB_NAME 127.0.0.1/32 md5

where DB_NAME is the name you will set for the databse in 
`config/application.yml`.

Restart the service:

    sudo service postgresql restart

Create the database user and password; DB_USERNAME and DB_PASSWORD should
correspond to the value you set for the database user and password in
`config/application.yml`:

    sudo -u postgres psql -c "create role DB_USERNAME with createdb login \
        password 'DB_PASSWORD';"

### Setup a dedicated user for alice

Create a new user:

    sudo useradd -m alice
    sudo passwd alice

Switch to that user when doing everything below.

    su alice

Download rbenv, etc.:

    git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    git clone https://github.com/sstephenson/ruby-build.git \
        ~/.rbenv/plugins/ruby-build
    source ~/.bashrc
 
Install and configure Ruby v2.3.0:

    rbenv install 2.3.0
    rbenv global 2.3.0
    gem install bundler

### First time installing Alice

Create a directory for Alice, e.g., `/var/www/alice`. If you choose a
different directory here, make sure to update this page in the Apache
configuration. For the this first step, you need to be a user with sudo
access (i.e., not `alice` unless you explicitly add `alice` to sudoers).

    sudo mkdir -p /var/www/alice
    sudo chown alice  /var/www/alice

Switch to the alice user:

    su alice

Clone Alice and copy configuration files.

    git clone https://github.com/hafeild/alice.git /var/www/alice
    cd /var/www/alice
    git checkout master
    bundle install
    cp application.EXAMPLE.yml config/application.yml

Go through the production section of `config/application.yml` and add in
the database information. Create a secret key base using the command 
located in the comments. Modify the server settings as needed (domain
and reply email).

Setup the necessary components:

    bundle exec rake db:setup RAILS_ENV=production
    bundle exec rake assets:precompile RAILS_ENV=production

### During the first install or after an update

Update gems:

    bundle install

Run migrations:

    bundle exec rake db:migrate RAILS_ENV=production
    bundle exec rake assets:precompile RAILS_ENV=production

Run the unicorn server (restart it if it's already running):

    unicorn_rails -p 5000 -E production

Start up Solr; this should be done using a stand alone Solr instance
(rather than sunspot). See ["Setting up Solr"](#setting_up_solar) below.
It is recommended to install Solr in `/var/www/alice` to keep things
tidy and so the init script works.

### Make Unicorn and Solr start at boot

Copy the startup scripts in `init.d/` to your system's init.d directory and make
them executable (as a user with sudo access):

    sudo cp init.d/* /etc/init.d/
    sudo chmod +x /etc/init.d/alice*
    sudo update-rc.d alice-unicorn defaults
    sudo update-rc.d alice-solr defaults

The default ports are 5000 for Unicorn and 8983 for Solr. The scripts assume
that you created a dedicated user named alice, rbenv is installed in
`/home/alice/.rbenv`, Solr is installed in `/var/www/alice/solr-6.6.0`, and the
Alice web directory is `/var/www/alice`.

Modify the tops of these scripts if you want to change any ports for Unicorn or
Solr. 

Start the Unicorn service by doing:

    sudo service alice-unicorn start

Start Solr by doing:

    sudo service alice-solr start

You can stop and restart, as well -- just replace `start` above with `stop` or 
`restart`.


### Truncating the database
**WARNING:** this will delete everything from the database permanently.

    `bundle exec rake db:drop db:create db:schema:load RAILS_ENV=production`


<a id="setting_up_solr"></a>
# Setting up Solr

Download Solr 6.6.0 or higher from here: 

    http://www.apache.org/dyn/closer.lua/lucene/solr/6.6.0

Unpack the zip (or tar ball) file and extract the contents to somewhere 
permanent. This will act as both the Solr execution directory as well as the
index repository. Change directories to this location.

Start the server like this, specifying the production, development, or test
port as described below:

    bin/solr start -p <port>

The default ports defined in the `config/application.yml`, are as follows;
use whatever you have them set to in that file (feel encouraged to change them):

    production:     8983
    development:    8982
    test:           8981    

You can actually use the same exact port if you'd like, but keeping them
separate means that you can run separate, isolated instances of Solr.

Copy the `sunspot` directory from the Alice repository to 
`server/solr/configsets` in the Solr execution directory.

The first time running Solr, create a core for the environments you care about
-- this step can be done regardless of which port you started up on:

    bin/solr create_core -c development -d sunspot
    bin/solr create_core -c production -d sunspot
    bin/solr create_core -c test -d sunspot

When you need to stop a Solr instance, do:

    bin/solr stop -p <port>

You need to start the appropriate Solr instance (`bin/solr start -p <port>`) any
time you intend to modify Alice records through the server or perform a search.





## Configure Apache

This configuration was tested on Apache 2.4.7. First, enable the necessary
modules:

    sudo a2enmod ssl rewrite proxy_balancer proxy_http \
        lbmethod_byrequests headers

We recommend you use SSL when using Alice. You can generate free SSL 
certificates for a domain using [Let's Encrypt](https://letsencrypt.org/). We
provide Apache site templates for both with and without SSL. The SSL varient
will also redirect all HTTP traffic to HTTPS.

Both of these site files connect to the production Unicorn server. If you 
would like to run the development server (WebBricks), either:

  a. start WebBricks on port 5000 (the production port): `bin/rails s -p 5000`
  b. change the port numbers in in the `<Proxy>` section of the Apache site
     configs to use the development port (usually 3000).

### With SSL (RECOMMENDED)

Create a site configuration file in `/etc/apache2/site-avaialble/`, e.g.,
`/etc/apache2/site-avaialble/alice-ssl.conf`. Copy and paste the following
into that file. Replace `yourdomain.com` with whatever your domain is.
    
    <IfModule mod_ssl.c>
    <VirtualHost *:80>
        ServerName yourdomain.com
        Redirect / https://yourdomain.com
        RewriteEngine on
        RewriteCond %{SERVER_NAME} =yourdomain.com
        RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
    </VirtualHost>
    
    <VirtualHost *:443>
        SSLEngine on
    
        ServerName yourdomain.com
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/alice/public
    
        ErrorLog ${APACHE_LOG_DIR}/alice.error.log
        CustomLog ${APACHE_LOG_DIR}/alice.access.log combined
        LogLevel warn

        RewriteEngine On
        RewriteCond %{DOCUMENT_ROOT}/maintenance.html -f
        RewriteCond %{DOCUMENT_ROOT}/../site-down -f
        RewriteCond %{SCRIPT_FILENAME} !/maintenance.html
        RewriteRule ^.*$ /maintenance.html [R=503,L]
        ErrorDocument 503 /maintenance.html
    
        <Proxy balancer://unicornservers>
            BalancerMember http://127.0.0.1:5000
        </Proxy>
    
        RewriteEngine on
        RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} !-f
        RewriteRule ^(.*) balancer://unicornservers%{REQUEST_URI} [P,QSA,L]
        RequestHeader set X_FORWARDED_PROTO 'https'
    
        <Proxy *>
            Order deny,allow
            Allow from all
        </Proxy>
    
        SSLCertificateFile /etc/letsencrypt/live/yourdomain.com/cert.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/yourdomain.com/privkey.pem
        SSLCertificateChainFile /etc/letsencrypt/live/yourdomain.com/chain.pem
    </VirtualHost>
    </IfModule>
    # vim: syntax=apache ts=4 sw=4 sts=4 sr noet

Then do the following, substituting `alice-ssl.conf` with whatever you named
your site file.

    sudo a2ensite alice-ssl.conf

Restart the server:

    sudo service apache2 restart

Now visit http://yourdomain.com and you should be redirected to
https://yourdomain.com and see the Alice home page.


### Without SSL

Create a site configuration file in `/etc/apache2/site-avaialble/`, e.g.,
`/etc/apache2/site-avaialble/alice.conf`. Copy and paste the following
into that file. Replace `yourdomain.com` with whatever your domain is.
    
    <VirtualHost *:80>
        ServerName yourdomain.com
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/alice/public

        ErrorLog ${APACHE_LOG_DIR}/alice.error.log
        CustomLog ${APACHE_LOG_DIR}/alice.access.log combined
        LogLevel warn
    
        RewriteEngine On
        RewriteCond %{DOCUMENT_ROOT}/maintenance.html -f
        RewriteCond %{DOCUMENT_ROOT}/../site-down -f
        RewriteCond %{SCRIPT_FILENAME} !/maintenance.html
        RewriteRule ^.*$ /maintenance.html [R=503,L]
        ErrorDocument 503 /maintenance.html

        <Proxy balancer://unicornservers>
            BalancerMember http://127.0.0.1:5000
        </Proxy>
    
        RewriteEngine on
        RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} !-f
        RewriteRule ^(.*) balancer://unicornservers%{REQUEST_URI} [P,QSA,L]
    
        <Proxy *>
            Order deny,allow
            Allow from all
        </Proxy>
    </VirtualHost>
    # vim: syntax=apache ts=4 sw=4 sts=4 sr noet

Then do the following, substituting `alice.conf` with whatever you named
your site file.

    sudo a2ensite alice.conf

Restart the server:

    sudo service apache2 restart

Now visit http://yourdomain.com and you should see the Alice homepage.
