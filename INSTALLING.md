# Installing Alice
More to come...


## Development
If developing on Windows, install [RailsInstaller](http://railsinstaller.org/en)
(Ruby 2.3). There may be in issue with a few of the commands, so after cloning,
do the following in the alice directory (this will remove rails, but don't 
worry, it'll be reinstalled with the next step):

    gem uninstall rails 5.0.2 


On any system, do the following after the initial clone or any subsequent pull
to install any gems that were added to the Gemfile:

    bundler install

After the initial clone, after any pull, and after any time you add a new
migration, run the migrations in the test and development environments:

    bin/rails db:migrate
    bin/rails db:migrate RAILS_ENV=test

Any time you want to run a test, do:

    bundler exec rake test