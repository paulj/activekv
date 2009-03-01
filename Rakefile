require 'rake'
require 'spec/rake/spectask'

desc "Run all examples"
Spec::Rake::SpecTask.new('examples') do |t|
  t.spec_opts  = ["-cfs"]
  t.spec_files = FileList['spec/**/*.rb']
end

