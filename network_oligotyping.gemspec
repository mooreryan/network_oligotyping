# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "network_oligotyping/version"

Gem::Specification.new do |spec|
  spec.name          = "network_oligotyping"
  spec.version       = NetworkOligotyping::VERSION
  spec.authors       = ["Ryan Moore"]
  spec.email         = ["moorer@udel.edu"]

  spec.summary       = %q{Graph aware Oligotyping}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/mooreryan/network_oligotyping"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "yard", "~> 0.9.9"

  spec.add_runtime_dependency "abort_if", "~> 0.2"
  spec.add_runtime_dependency "parse_fasta", "~> 2.2"
  spec.add_runtime_dependency "shannon", "~> 0.1.1"
  spec.add_runtime_dependency "trollop", "~> 2.1", ">= 2.1.2"
end
