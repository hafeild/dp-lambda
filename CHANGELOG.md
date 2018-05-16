# Changelog

Changes made in each release are summarized below.

## Next

New features:

    * description and outcome summaries are no longer displayed in an iframe
    * file attachment updates:
        - users can now provide descriptions
        - files and their descriptions can be edited
        - attachments can be reordered

Bug fixes:

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

