# Changelog

Changes made in each release are summarized below.

## NEXT

New features:

    * can now select multiple related vertical entries when linking two
      verticals (e.g., tags, software, etc.)
  
Bug fixes:

    * The cancel button on assignment forms now works (see
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

