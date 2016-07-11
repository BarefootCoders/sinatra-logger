# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minodes/sinatra/logger/version'

Gem::Specification.new do |spec|
  spec.name          = "minodes-sinatra-logger"
  spec.version       = Minodes::Sinatra::Logger::VERSION
  spec.authors       = ["Yehya Abouelnaga"]
  spec.email         = ["yehya.abouelnaga@minodes.com"]

  spec.summary       = %q{A gem that wires `SemanticLogger` to Sinatra painlessly}
  spec.description   = %q{Sinatra Logging is a pain. This gem helps with wiring Access logs, Error logs, and plain debugging logs (i.e. logger.info, logger.warn, ... etc).}
  spec.homepage      = "https://github.com/minodes/sinatra-logger"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "semantic_logger"
  spec.add_dependency "sinatra"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
end
