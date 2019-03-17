# Changelog

Changes made in each release are summarized below.

## NEXT VERSION

New features:

  * ...

Bug fixes:

  * ...


## 19.03

New features:

  * editors can now add stub users as instructors or authors when creating or editing assignment pages
  * non-assignment vertical listings no longer include the creator's name

Bug fixes:

  * assignments are now ordered by creation date
  * emails are no longer retrievable for users/user stubs
  * updated a vulnerable library
    - required update to Ruby 2.3.5
      ```
      rbenv install 2.3.5
      rbenv global 2.3.5
      gem install bundler
      gem pristine --all
      bundler install
      ```
  * thumbnail files are no longer saved in their original size; everything is
    resized to under 600x600 pixels
  * upgraded the actionview library to v5.0.7.2 to mitigate a vulnerability
  * updated INSTALLING.md to include the new version of ruby
  * updated INSTALLING.md to include g++ as one of the prereqs for installing
    on a production system

## 19.02.02

New features:

  * all verticals now support thumbnails
  * index pages have a new tiled look
  * assignment pages now list all assignment versions

## 19.02.01

New features:

  * examples have been renamed "How-tos" to make their purpose clearer
  * added production database backup and restore instructions to INSTALLING.md
  * errors encountered while creating or updating any vertical will now
    kick the user back to the form they were editing with the values they
    entered re-populated in the form along with detailed error messages
  * editing an assignment group page with an assignment showing will
    redirect back to that page when the update completes
  * there's now an `update-production.sh` script for running all the update
    procedures on a production server

Bug fixes: 

  * short search queries were treated as conjunctions (all terms must appear in
    each result) instead of disjunctions (only one term must appear in each
    result); now they're correctly treated as the latter
  * sqlite3-dev, required for installation on Linux, has been added to the
    installation instructions

## 19.02

New features:

  * updated assignment listing and search results (now includes versions)
  * wider author/instructor search box
  * whitespace is now honored when displaying notes and outcome summaries
    for assignments
  * tags have counts (the number of pages each is associated with)

Bug fixes:

  * no more mystery text appearing at the bottom of the assignment and
    assignment group edit pages when selecting authors or instructors

## 19.01

New features:

  * new interface for verticals
  * verticals can now be linked to assignments
  * assignment face lift!
    - one assignment can have multiple versions (e.g., for multiple iterations
      of a course)
    - authors (of assignments) and instructors (of assignment instances)
      are now linked to other users
  * users can login or recover their password with their email
    - also means each account must have a unique email
    - ...and no '@'s in usernames

Bug fixes:

  * none

## 18.08

New features:

  * more descriptive section labels on the new assignment form

Bug fixes:

  * none

## 18.05.01

New features:

  * description and outcome summaries are no longer displayed in an iframe
  * file attachment updates:
      - users can now provide descriptions
      - files and their descriptions can be edited
      - attachments can be reordered
  * analyses and software can be linked
  * index and result snippets for software and analyses show related 
      analyses and software
  * examples are now treated like other vertical; they can be...
      - browsed
      - searched
      - added directly from the user menu if an editor
  * edit buttons are now hidden by default, but can be toggled
      - the last selected mode persists across page loads
  * the vertical type being viewed is highlighted in the header
      - this helps a user tell what kind of vertical they're looking at
    

Bug fixes:

  * linked verticals resources are now re-indexed when a vertical is updated
    or deleted

## 18.05

New features:

  * snippets on index and search result pages include metadata

Bug fixes:

  * tag, web resource, and example pages now show the correct associated
    verticals
  * trashcan delete button works on tag badges
  * cancel buttons now work
  * links to non-existing pages have been removed

## 18.01

New features:

  * files can now be attached to all verticals and examples
    - 5 MiB limit per upload
    - 25 MiB limit per vertical

## 17.12

New features:

  * can now select multiple related vertical entries when linking two
    verticals (e.g., tags, software, etc.)
  * the description field for assignments is no longer mandatory
  * users can request viewer (default), editor, and admin permissions
  * admins can administer users and permission change requests
  
Bug fixes:

  * the cancel button on new/create vertical forms now works (see
    https://github.com/hafeild/alice/issues/13)

## 17.08

A mostly small incremental release. This includes some minimal UI polishing:

  * refined vertical displays
  * "add page" buttons at the top of vertical listings
  * tag badges instead of bulleted lists

For security, new users are not given editing permissions. There is currently
no administration interface, however, so these permissions must be granted
through the rails console.

## 17.07

Our first release! This release has the following features:

  * user account creation
  * logged in users can create, modify, and delete content
  * any user can browse entries created in four verticals:
    - assignments
    - analyses
    - software
    - databases
  * all verticals can be searched using a basic and advanced search
    interfaces

