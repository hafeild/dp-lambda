# Contributing to Alice

## Branching
The primary branches are:

  * master, where released, tagged versions live (see below for details on 
    versioning)
  * develop, where the current stable development version lives

Beyond these two branches, others should also be created in the following
scenarios:

  * `<feature>`, a branch for a specific feature
  * `release-<version>`, a branch for staging a new release
  * `hotfix-<version>`, a branch for patching a release

The workflow of these branches follows from Vincent Driessen's model
[see here](http://nvie.com/posts/a-successful-git-branching-model/). In a
nutshell:

  * when you go to work on a new feature:
    - branch from develop, name the branch after your feature
    - develop that feature only on that branch
  * when you are finished a feature:
    - submit a pull request to merge back into develop
    - whoever reviews the pull request should delete the branch after merging
  * when you are ready to create a pre-release:
    - branch from develop, name the branch v<version>, where version is the
      next version to release 
      (see below for details on versioning)
    - update the versioning information in `config/initializers/version.rb`
    - perform last minute tests
  * when the pre-release is ready for official release:
    - submit a pull request to merge with master
      * after the pull request has been reviewed and merged with master, 
        master needs to be tagged with the current version number
    - submit another pull request to merge with develop
      * after the pull request has been reviewed and merged with develop,
        remove the v<version> branch
      * update develop so that `config/initializers/version.rb` indicates it is
        a development version and commit
  * for mission-critical bugs found in the current release that require 
    patching:
    - create a branch from master; name this v<version>-hotfix
    - update the version to include the new patch level
    - after fixing the issue, submit a pull request to merge with master
    - if the fix is critical to develop, then put in a pull request to merge
      with develop, too
    - remove the branch after merges are completed

Before any pull request is made, all tests should be passing.

### Branching examples

#### Example: create feature3 branch from develop

First things first, make sure you have the `develop` branch on your local
machine. To check this, do the following:

    git branch

If you do not see `develop` as one of the branches listed, then you need to
check it out and track it; issue the following command:

    git checkout -t origin/develop

Once you have the `develop` branch, make it your current branch and update it:

    git checkout develop
    git pull origin develop

Now suppose you want to create a new feature branch called `feature3` (you 
can call this whatever you want). Since your current branch is `develop`, that
will be used as the base for the new branch (as opposed to `master` or something
else); if you wanted the base to be a different branch, checkout that branch
before proceeding. To create the new feature branch, do:

    git checkout -t origin/feature3

Add, commit, push, and pull like usual, making sure to specify the feature 
branch name for the latter two (e.g., `git push origin feature3`).


## Release versioning
Versions should be in the format:

    <YY>.<MM>.<number>.<patch>

where:

  * `<YY>` is the last two digits of the current year
  * `<MM>` is the month number, padded with a leading 0 if 1–9
  * `<number>` is a the two digit number of the release within the given 
    year/month, starting with 00 (the first release)
  * `<patch>` is the two-digit patch level (i.e., hotfix number), starting with 
    00 (i.e., no patch)

00 values may be omitted for `<number>` and `<patch>`. However, if `<patch>` is
greater than 00, then `<number>` must be included regardless of whether it is
00 or not.

### Example version numbers

  * **17.06**: the first release of June, 2017
  * **17.08.01**: the second release of August, 2017
  * **18.01.00.05**: the fifth patch to the first release of January, 2018

### Example tagging a release

Assume that you have merged your release branch to master (see 
[Branching](#branching) above) and you're ready to tag. First, move to `master`
if you're not already there:

    git checkout master

Supposing you want to release version 17.05, do:

    git tag -a 17.05
    git push --tags



## Committing and commit/push request messages
Commits on feature branches should occur frequently. Every commit should include
a descriptive message describing what was modified.

Pull requests should include a summary of the changes made in the branch being
merged. Bulleted lists of changes/additions are preferred.


## Changelog
For every release, update [CHANGELOG.md](CHANGELOG.md) with a list of new 
features and changes made between the previous and current release.


## Coding style
Because this application is implemented on top of the Ruby on Rails framework,
we follow the conventions used therein. The main points are:

  * variable and function names should used snake_case (not camelCase)
  * the indentation level is two spaces
  * every functions should have a comment describing what it does, what
    the parameters are, and what is returned

