# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rbslicer/version'

Gem::Specification.new do |spec|
  spec.name          = "rbslicer"
  spec.version       = Rbslicer::VERSION
  spec.authors       = ["SlicingDice LLC"]
  spec.email         = ["help@slicingdice.com"]

  spec.summary       = %q{Official Ruby client for SlicingDice, Data Warehouse and Analytics Database as a Service.}
  spec.homepage      = 'https://rubygems.org/gems/rbslicer'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
