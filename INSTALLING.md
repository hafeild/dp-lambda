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
Next, build the Docker image:

```bash
docker/scripts/build-dev-image.sh`
```

You should do this step anytime you've finalized making changes to the Gemfile
or pull changes that affect the Gemfile; this will save you time when you go
to run the container.

To start the container, do:

```bash
docker/scripts/run-dev-image.sh
```

This will run the container, perform any outstanding database migrations on the
development database (sqlite), start Sunspot Solr (for indexing and searching),
and start the rails server listening on port 3000. You can use `ctrl-c` to exit
the server and drop to a shell, e.g., to perform rake tasks, run tests, etc. If
you want to restart the server, enter this from within the container:

```bash
bin/rails s -b 0.0.0.0
```

This command also mounts the Alice directory as a volume in the container, so
you can use whatever text editor or IDE you'd like to edit files on your machine
and see those changes in the container. The container is based on Docker's
Alpine image, which is a lightweight Linux distribution and uses ash rather than
bash as the shell. If you need additional tools installed, use the `apk add
<package>` command in the ash shell.

In development mode, rails will integrate most changes to the app live, so
you only need to restart the server if you change a configuration file (which 
are only checked when the server starts) or modify gems.

### Testing

To test the system, make sure you've built the development image
(`docker/scripts/build-dev-image.sh`). Then run:

```bash
docker/scripts/run-dev-container-tests.rb
```
