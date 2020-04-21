require 'rake'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name = 'twisty_puzzles'
  s.version = "0.0.0"
  s.date = '2020-4-21'
  s.summary = <<~SUMMARY
    Gem for my cube_trainer rails app. Some things are better left in a separate gem with no rails, e.g. native extensions.
    The main purpose is to support my Rails app, but if it's useful for someone else, feel free to use it at your own risk.
  SUMMARY
  s.authors = ['Bernhard F. Brodowsky']
  s.email = 'bernhard.brodowsky@gmail.com'
  s.files = FileList[
    'lib/**/*.rb',
    'README.md',
    'LICENSE',
  ].to_a
  s.homepage = 'https://github.com/Lykos/twisty_puzzles'
  s.require_paths = ["lib"]
  s.extensions << 'ext/twisty_puzzles/native/extconf.rb'
  spec.extra_rdoc_files = ['README.md']
  s.licence = 'MIT'
  s.add_runtime_dependency 'colorize'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rake-compiler'
  s.add_development_dependency 'rantly'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-prof'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rake'
  s.add_development_dependency 'rubocop-performance'
  s.add_development_dependency 'simplecov'
end
