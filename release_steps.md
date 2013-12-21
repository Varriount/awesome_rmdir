What to do for a new public release?
====================================

* Create new milestone with version number.
* Create new dummy issue "Release versionname" and assign to that milestone.
* Move closed issues from "future milestone" to the release milestone.
* To start release type "git flow release start 0.2.0".
* Do... stuff... or maybe not.
* To finish release type "git flow release finish 0.2.0", use v+version as tag.
* Push.
* Push tags.
* Close the dummy release issue.
* Announce at http://forum.nimrod-code.org/t/147.
