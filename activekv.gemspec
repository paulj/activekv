--- !ruby/object:Gem::Specification 
name: activekv
version: !ruby/object:Gem::Version 
  version: 0.0.1
platform: ruby
authors: 
- Paul Jones
autorequire: 
bindir: bin
cert_chain: []

date: 2009-03-22 00:00:00 +00:00
default_executable: 
dependencies: 
- !ruby/object:Gem::Dependency 
  name: activesupport
  type: :runtime
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: 2.2.2
    version: 
description: ActiveKV provides ActiveRecord style data storage for Key/Value stores.
email: pauljones23@gmail.com
executables: []

extensions: []

extra_rdoc_files: []

files: 
- Rakefile
- README.rdoc
- lib/activekv
- lib/activekv/base.rb
- lib/activekv.rb
- spec/base.rb
- spec/simple-config.yml
has_rdoc: true
homepage: http://github.com/vuderacha/activekv/
post_install_message: 
rdoc_options: []

require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
required_rubygems_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
requirements: []

rubyforge_project: 
rubygems_version: 1.3.1
signing_key: 
specification_version: 2
summary: Ruby Active Key/Value Objects.
test_files: []

