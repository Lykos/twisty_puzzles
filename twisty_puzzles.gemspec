# frozen_string_literal: true

require_relative 'lib/twisty_puzzles/version'
require 'rake'

REPO_URI = 'https://github.com/Lykos/twisty_puzzles'

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'twisty_puzzles'
  s.version = TwistyPuzzles::VERSION
  s.summary = <<~SUMMARY
    Gem for my cube_trainer rails app. Some things are better left in a separate gem with no rails, e.g. native extensions.
    The main purpose is to support my Rails app, but if it's useful for someone else, feel free to use it at your own risk.
  SUMMARY
  s.authors = ['Bernhard F. Brodowsky']
  s.email = 'bernhard.brodowsky@gmail.com'
  s.files = FileList[
    'ext/**/*.{c,h}',
    'lib/**/*.rb',
    '*.md',
    'LICENSE'
  ].to_a
  s.homepage = REPO_URI
  s.required_ruby_version = Gem::Requirement.new('>= 3.0.0')

  s.metadata['homepage_uri'] = s.homepage
  s.metadata['source_code_uri'] = REPO_URI
  s.metadata['changelog_uri'] = "#{REPO_URI}/blob/master/CHANGELOG.md"
  s.require_paths = ['lib']
  s.extensions << 'ext/twisty_puzzles/native/extconf.rb'
  s.extra_rdoc_files = ['README.md']
  s.license = 'MIT'
  s.add_runtime_dependency 'colorize'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rake-compiler'
  s.add_development_dependency 'rantly'
  s.add_development_dependency 'rspec', '~> 3.8'
  s.add_development_dependency 'rspec-prof'
  s.add_development_dependency 'rubocop', '~> 1.7'
  s.add_development_dependency 'rubocop-performance'
  s.add_development_dependency 'rubocop-rake'
  s.add_development_dependency 'simplecov'
  s.metadata['rubygems_mfa_required'] = 'true'
end
