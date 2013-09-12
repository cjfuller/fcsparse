# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fcsparse/version'

Gem::Specification.new do |s|
  s.name        = 'fcsparse'
  s.version     = FCSParse::VERSION
  s.date        = '2013-09-11'
  s.summary     = "Parser for FCS v3.x file format"
  s.description = "Parses flow cytometry FCS v3.x files and allows output to plain (delimited) text."
  s.authors     = ["Colin J. Fuller"]
  s.email       = 'cjfuller@gmail.com'
  s.homepage    = "http://github.com/cjfuller/fcsparse"
  s.files       = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
end
