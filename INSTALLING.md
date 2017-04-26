# Installing Alice
More to come...


## Development

### First time setup
If developing on Windows, install [RailsInstaller](http://railsinstaller.org/en)
(Ruby 2.3). There may be in issue with a few of the commands, so after cloning,
do the following in the alice directory (this will remove rails, but don't 
worry, it'll be reinstalled with the next step):

    gem uninstall rails 5.0.2 


Install [ImageMagick](https://www.imagemagick.org/script/binary-releases.php)
(required for uploading photos). This needs to be done before running bundle
install.

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

Install any new gems specified in the Gemfile:

    bundle install

Run the migrations in the test and development environments:

    bundle exec rake db:migrate
    bundle exec rake db:migrate RAILS_ENV=test

Any time you want to run a test, do:

    bundle exec rake test

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




