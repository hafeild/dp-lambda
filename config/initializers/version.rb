## Version information. Sets two global variables: 
##
##   VERSION -- an array of Year, Month, Number, and Hotfix or build number.
##   VERSION_STRING -- a string formatted as Year.Month.Number.Hotfix (for 
##                     release) or Yearm.Month.Build (for developement).
##                     Note that in a release, 00 is ignored for Hotfix, and
##                     for Number if both Number and Hotfix are 00.
##
## Some of the info below needs to be updated when going to production releases 
## -- namely, change the isRelease variable to true and update the Year, 
## Month, Number, and Hotfix versions. Editing this file requires a server
## restart.

## Update these fields ##
isRelease = false
yearVersion   = "17" ## Year of release.
monthVersion  = "04" ## Month of release.
numberVersion = "00" ## Number of release within Year-Month
hotFixNo      = "00" ## Hot fix no. for release.


VERSION = [
  yearVersion, 
  monthVersion,
  numberVersion,
  isRelease ? hotFixNo : `git describe --always --tags`.strip
]

VERSION_STRING = VERSION.join(".").sub(/(\.{0,1}00)*/, '')
