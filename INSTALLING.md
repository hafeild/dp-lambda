# Installation

For ease of distribution, Alice has several scripts to assist with
development and production environments using Docker. Install Docker before
proceeding with the instructions below. If you'd rather not use Docker,
see `docker/Docker.dev`, `docker/Docker.prod`, and `docker/Compose.prod.yml` for
a list of the system dependencies required to run Alice.

## Production installation

*Coming soon...*


## Development installation

First, clone the repository and change over the the development branch:

```bash
git clone https://github.com/hafeild/alice.git
cd alice
git checkout -t origin/develop
```

Second, copy `application.EXAMPLE.yml` to `config/application.yml` and edit as
necessary (most of this can stay as is for development). You'll need to register
for a reCAPTCHA v2 Checkbox key; this is used to protect against bot-generated
spam on any forms that result in emails being sent out as well as the login.
Paste the key and secret to the corresponding entries in
`config/application.yml`.

Next, build the Docker image:

```bash
docker/scripts/build-dev-image.sh
```

You should do this step anytime you've finalized making changes to the Gemfile
or pull changes that affect the Gemfile; this will save you time when you go
to run the container.


Create an admin user (see (Adding users)[#adding-users]).


To start the server, do:

```bash
docker/scripts/run-dev-container.sh
```

This will run the container, perform any outstanding database migrations on the
development database (sqlite), start Sunspot Solr (for indexing and searching),
and start the rails server listening on port 3000. You can use `ctrl-c` to exit
the server and exit the container. 

This command also mounts the Alice directory as a volume in the container, so
you can use whatever text editor or IDE you'd like to edit files on your machine
and see those changes in the container. The container is based on the Docker
Alpine image, which is a lightweight Linux distribution and uses ash rather than
bash as the shell. If you need additional tools installed, use the `apk add
<package>` command in the ash shell.

In development mode, rails will integrate most changes to the app live, so
you only need to restart the server if you change a configuration file (which 
are only checked when the server starts) or modify gems.

<a name="adding-users"></a>
### Adding users

You should first add a default `admin` user. To do this, ensure the server
isn't running (or any instance of the development container) and 
run the following:

```bash
docker/scripts/run-dev-container.sh user-admin users:add_admin
# follow the prompts to enter/confirm a password
```

You can create additional users two ways: through the command line or through
the web application. To add a user via the command line, use this command:

```bash
docker/scripts/run-dev-container.sh user-admin users:add
# follow the prompts to enter information; be sure to set 'is_registered' and 
# 'activated' to true or the user won't be be able to sign in.
```

To create additional users through the web app, start the server and use the
"Sign up" page. In the production environment, an activation email will be sent
to users when they register and contain a link they must click before they can
log into the system. No emails are sent in the development environment, but the
email text is displayed in the server logs (this is what is displayed in your
terminal when you are running the server using the
`docker/scripts/run-dev-container.sh` script). Any time you add a user through
the "Sign up" form, copy and past the activation URL from that email message in
the log, or you can use the `users:activate[USERNAME]` rake task to activate the
user:

```bash
## Replace USERNAME with the username of the user you'd like to activate.
docker/scripts/run-dev-container.sh user-admin users:activate[USERNAME]
```

You can also perform other user administration tasks. Run the following for
a full list:

```bash
docker/scripts/run-dev-container.sh user-admin
```


### Testing

To test the system, make sure you've built the development image
(`docker/scripts/build-dev-image.sh`). Then run:

```bash
docker/scripts/run-dev-container.sh test
```

Or, to run a specific directory or file of tests, use the TEST argument.

```bash
## Run all controller tests.
docker/scripts/run-dev-container.sh test TEST=test/controllers

## Run just the analyses controller test.
docker/scripts/run-dev-container.sh test TEST=test/controllers/analyses_controller_test.rb
```

Alternatively, you can enter an interactive shell on the container and run tests
directly (this useful if you want don't want to wait for the container and Solr
to spin up before each time you test).

```bash
docker/scripts/run-dev-container.sh ash
# ...wait for container to start...

# Start the test Solr instance
bundle exec rake sunspot:solr:start RAILS_ENV=test

# Run the tests:
bundle exec rake test
# or to run a specific directory or file of tests:
bundle exec rake test TEST=test/controllers/user_controller_test.rb
# You can run as many times as you want -- no need to start and stop Solr
# each time.

# Stop Solr
bundle exec rake sunspot:solr:stop RAILS_ENV=test
```

### Interacting with the container

As mentioned above, you can enter an interactive shell on the development 
container in a few ways aside from those mentioned above.

For general access to an ash command line, do:

```bash
docker/scripts/run-dev-container.sh ash
```

This doesn't do anything on spin up: no database migrations, and no checks to
see if the Gemfile has been updated, no Solr configuration, startup, or
re-indexing. You'll need to do those things manually if you need any of them. 
If you use this method and want to run the server, enter this in ash:

```bash
bin/rails s -b 0.0.0.0
```

If you want to run a shell script that is running after all that set up, do

```bash
docker/scripts/run-dev-container.sh docker/scripts/dev-run-wrapper.sh ash
```

You can also provide an ash script to run. If it's named `myscript.sh`, then
do:

```bash
docker/scripts/run-dev-container.sh myscript.sh ...any args to your script...
```

Or if you want the script to run after the spin up setup (migrations, etc.),
do: 

```bash
docker/scripts/run-dev-container.sh docker/scripts/dev-run-wrapper.sh myscript.sh ...any args to your script...
```
   
Importantly, `run-dev-container.sh` starts a new container that is removed
when exited. This means you cannot use this script to run things in the
container in more than one place simultaneously (e.g., if you have the 
server up and running in one terminal, you can't run tests in another terminal).

