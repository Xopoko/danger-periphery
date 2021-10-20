# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "version"

Gem::Specification.new do |spec|
  spec.name          = "danger-periphery"
  spec.version       = DangerPeriphery::VERSION
  spec.authors       = ["Ryosuke Ito"]
  spec.email         = ["rito.0305@gmail.com"]
  spec.description   = "A Danger plugin to detect unused codes."
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/manicmaniac/danger-periphery"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "danger-plugin-api", "~> 1.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "listen", "3.0.7"
  spec.add_development_dependency "pry"
end
