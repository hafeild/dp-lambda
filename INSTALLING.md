# Installing Alice
More to come...


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

On any system, do the following after the initial clone or any subsequent pull
to install any gems that were added to the Gemfile:

    bundle install

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

    bundle install

Run the migrations in the test and development environments:

    bundle exec rake db:migrate
    bundle exec rake db:migrate RAILS_ENV=test

Any time you want to run a test, do:

    ## Start Solr (this uses the development version; you can swap it out for
    ## your own version of Solr; see below).
    bundle exec sunspot-solr start -p 8981
    bundle exec rake test
    ## To stop Solr if you're using the dev version bundled with Sunspot.
    bundle exec sunspot-solr stop


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

## Setting up Solr

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

Create a core for each one -- this step can be done regardless of which port
you started up on:

    bin/solr create_core -c development -d sunspot
    bin/solr create_core -c production -d sunspot
    bin/solr create_core -c test -d sunspot

When you need to stop a Solr instance, do:

    bin/solr stop -p <port>

You need to start the appropriate Solr instance (`bin/solr start -p <port>`) any
time you intend to modify Alice records through the server or perform a search.