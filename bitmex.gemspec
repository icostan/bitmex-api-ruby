lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bitmex/version'

Gem::Specification.new do |spec|
  spec.name          = 'bitmex-api'
  spec.version       = Bitmex::VERSION
  spec.authors       = ['Iulian Costan']
  spec.email         = ['iulian.costan@gmail.com']

  spec.summary       = %q{Idiomatic Ruby library for BitMEX API}
  spec.description   = %q{Fully-featured library for Rest/Websocket BitMEX API}
  spec.homepage      = 'https://github.com/icostan/bitmex-api-ruby'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/icostan/bitmex-api-ruby.git'
    spec.metadata['changelog_uri'] = 'https://github.com/icostan/bitmex-api-ruby/blob/master/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'eventmachine'
  spec.add_dependency 'faye-websocket'
  spec.add_dependency 'hashie'
  spec.add_dependency 'httparty'

  spec.add_development_dependency 'bump'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-doc'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
end
