# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'marc_to_argot/version'

is_java = RUBY_PLATFORM =~ /java/

Gem::Specification.new do |s|
  s.name          = 'marc_to_argot'
  s.version       = MarcToArgot::VERSION
  s.authors       = ['Luke Aeschleman', 'Cory Lown', 'Kristina Spurgin', 'Adam Constabaris']
  s.email         = ['lukeaeschleman@gmail.com']

  s.summary       = 'Transfrom MARC into a nested JSON Schema: Argot'
  s.description   = 'See summary'
  s.homepage      = 'https://github.com/trln/marc-to-argot'
  s.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if s.respond_to?(:metadata)
    s.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '~> 2.0'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rspec', '~> 3.0'

  # pick our JSON library to install depending on the platform
  if is_java
    s.platform = 'java'
    s.add_runtime_dependency 'jar-dependencies', ['~> 0.3', '>=0.3.9']
    s.requirements << 'jar org.noggit:noggit, 0.8'
  else
    s.platform = 'ruby'
    s.add_runtime_dependency 'yajl-ruby', ['>=1.3.1']
  end

  s.add_runtime_dependency 'activesupport', '> 5.1', '< 7'
  s.add_runtime_dependency 'logging', '~> 2.2.2'
  s.add_runtime_dependency 'library_stdnums', '~> 1.6'
  s.add_runtime_dependency 'nokogiri', '~> 1.8'
  s.add_runtime_dependency 'lcsort', '~> 0.9.0'
  s.add_runtime_dependency 'thor', '~> 0.20.0'
  s.add_runtime_dependency 'traject', '~> 2.0'
end
