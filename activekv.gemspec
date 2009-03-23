# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{activekv}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Jones"]
  s.date = %q{2009-03-23}
  s.description = %q{ActiveKV provides ActiveRecord style data storage for Key/Value stores.}
  s.email = %q{pauljones23@gmail.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["Rakefile", "README.rdoc", "lib/activekv", "lib/activekv/base.rb", "lib/activekv.rb", "spec/base.rb", "spec/simple-config.yml"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/vuderacha/activekv/}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Ruby Active Key/Value Objects.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.2.2"])
      s.add_runtime_dependency(%q<wycats-moneta>, [">= 0.5.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.2.2"])
      s.add_dependency(%q<wycats-moneta>, [">= 0.5.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.2.2"])
    s.add_dependency(%q<wycats-moneta>, [">= 0.5.0"])
  end
end
