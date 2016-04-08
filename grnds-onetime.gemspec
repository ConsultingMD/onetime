# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grnds/onetime/version'

Gem::Specification.new do |spec|
  spec.name          = "grnds-onetime"
  spec.version       = Grnds::Onetime::VERSION
  spec.authors       = ["Maximo Dominguez"]
  spec.email         = ["maximo.dominguez@grandrounds.com"]

  spec.summary       = %q{Gem for managing scripts that should be run only once (e.g., data migrations)}
  spec.homepage      = 'https://github.com/ConsultingMD/onetime'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
end
