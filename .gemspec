--- !ruby/object:Gem::Specification 
name: dnote
version: !ruby/object:Gem::Version 
  hash: 3
  prerelease: false
  segments: 
  - 1
  - 5
  - 0
  version: 1.5.0
platform: ruby
authors: 
- Thomas Sawyer
autorequire: 
bindir: bin
cert_chain: []

date: 2011-05-13 00:00:00 -04:00
default_executable: 
dependencies: 
- !ruby/object:Gem::Dependency 
  name: syckle
  prerelease: false
  requirement: &id001 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        hash: 3
        segments: 
        - 0
        version: "0"
  type: :development
  version_requirements: *id001
- !ruby/object:Gem::Dependency 
  name: lemon
  prerelease: false
  requirement: &id002 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        hash: 3
        segments: 
        - 0
        version: "0"
  type: :development
  version_requirements: *id002
description: DNote makes it easy to extract developer's notes from source code, and supports almost any language.
email: transfire@gmail.com
executables: 
- dnote
extensions: []

extra_rdoc_files: 
- README.rdoc
files: 
- .ruby
- bin/dnote
- lib/dnote/core_ext.rb
- lib/dnote/format.rb
- lib/dnote/note.rb
- lib/dnote/notes.rb
- lib/dnote/session.rb
- lib/dnote/string.rb
- lib/dnote/templates/html/file.erb
- lib/dnote/templates/html/label.erb
- lib/dnote/templates/html/list.erb
- lib/dnote/templates/html.erb
- lib/dnote/templates/json/file.erb
- lib/dnote/templates/json/label.erb
- lib/dnote/templates/json/list.erb
- lib/dnote/templates/json.erb
- lib/dnote/templates/md/file.erb
- lib/dnote/templates/md/label.erb
- lib/dnote/templates/md/list.erb
- lib/dnote/templates/md.erb
- lib/dnote/templates/rdoc/file.erb
- lib/dnote/templates/rdoc/label.erb
- lib/dnote/templates/rdoc/list.erb
- lib/dnote/templates/rdoc.erb
- lib/dnote/templates/soap/file.erb
- lib/dnote/templates/soap/label.erb
- lib/dnote/templates/soap/list.erb
- lib/dnote/templates/soap.erb
- lib/dnote/templates/text/file.erb
- lib/dnote/templates/text/label.erb
- lib/dnote/templates/text/list.erb
- lib/dnote/templates/text.erb
- lib/dnote/templates/xml/file.erb
- lib/dnote/templates/xml/label.erb
- lib/dnote/templates/xml/list.erb
- lib/dnote/templates/xml.erb
- lib/dnote/templates/xoxo/file.erb
- lib/dnote/templates/xoxo/label.erb
- lib/dnote/templates/xoxo/list.erb
- lib/dnote/templates/xoxo.erb
- lib/dnote/templates/yaml/file.erb
- lib/dnote/templates/yaml/label.erb
- lib/dnote/templates/yaml/list.erb
- lib/dnote/templates/yaml.erb
- lib/dnote/version.rb
- lib/dnote.rb
- lib/plugins/rake/task.rb
- lib/plugins/redline/dnote.rb
- test/notes_case.rb
- try/sample.bas
- try/sample.js
- try/sample.rb
- HISTORY.rdoc
- LICENSE.txt
- README.rdoc
- VERSION
- Redfile
has_rdoc: true
homepage: http://rubyworks.github.com/dnote
licenses: []

post_install_message: 
rdoc_options: 
- --title
- DNote API
- --main
- README.rdoc
require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      hash: 3
      segments: 
      - 0
      version: "0"
required_rubygems_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      hash: 3
      segments: 
      - 0
      version: "0"
requirements: []

rubyforge_project: dnote
rubygems_version: 1.3.7
signing_key: 
specification_version: 3
summary: Extract developer's notes from source code
test_files: []

