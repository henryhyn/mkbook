# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mkbook/version'

Gem::Specification.new do |spec|
  spec.name          = 'mkbook'
  spec.version       = Mkbook::VERSION
  spec.date          = %q{2015-09-16}
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ['Henry He']
  spec.email         = ['henryhyn@163.com']

  spec.summary       = %q{tools to generate ebooks from markdown}
  spec.description   = %q{the ebook generate tools from markdown plain text}
  spec.homepage      = 'https://github.com/henryhyn/mkbook'
  spec.license       = 'MIT'

  spec.files         = Dir['bin/*','lib/**/*','lib/template/.mkbook.yml','lib/template/.gitignore','lib/template/images/.keep','lib/template/resources/.keep']
  spec.bindir        = 'bin'
  spec.executables   = ['mkbook']
  spec.require_paths = ['lib']

  spec.required_rubygems_version = '>= 1.3.6'
  spec.rubyforge_project         = 'mkbook'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'

  spec.add_runtime_dependency 'claide', '~> 0.9.1'
  spec.add_runtime_dependency 'colored', '~> 1.2'
  spec.add_runtime_dependency 'replace', '~> 1.0.1'
end
