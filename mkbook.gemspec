# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mkbook/version'

Gem::Specification.new do |spec|
  spec.name          = 'mkbook'
  spec.version       = Mkbook::VERSION
  spec.authors       = ['Henry He']
  spec.email         = ['henryhyn@163.com']

  spec.summary       = %q{tools to generate ebooks from markdown}
  spec.description   = %q{the ebook generate tools from markdown plain text}
  spec.homepage      = 'https://github.com/henryhyn/mkbook'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
end
