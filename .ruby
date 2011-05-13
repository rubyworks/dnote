--- 
spec_version: 1.0.0
replaces: []

loadpath: 
- lib
name: dnote
repositories: 
  public: git://github.com/rubyworks/dnote.git
conflicts: []

engine_check: []

title: DNote
contact: trans <transfire@gmail.com>
resources: 
  code: http://github.com/rubyworks/dnote
  api: http://rubyworks.github.com/dnote/rdoc
  mail: http://groups.google.com/group/rubyworks-mailinglist
  wiki: http://wiki.github.com/rubyworks/dnote
  home: http://rubyworks.github.com/dnote
maintainers: []

requires: 
- group: 
  - build
  name: syckle
  version: 0+
- group: 
  - test
  name: lemon
  version: 0+
manifest: MANIFEST
version: 1.5.0
licenses: []

copyright: Copyright (c) 2009 Thomas Sawyer
authors: 
- Thomas Sawyer
organization: RubyWorks
description: DNote makes it easy to extract developer's notes from source code, and supports almost any language.
summary: Extract developer's notes from source code
created: 2009-10-09
