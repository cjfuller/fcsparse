Gem::Specification.new do |s|
  s.name        = 'fcsparse'
  s.version     = '0.1.0'
  s.date        = '2012-06-18'
  s.summary     = "Parser for FCS v3.x file format"
  s.description = "Parses flow cytometry FCS v3.x files and allows output to plain (delimited) text."
  s.authors     = ["Colin J. Fuller"]
  s.email       = 'cjfuller@gmail.com'
  s.files       = Dir['lib/**/*.rb']
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
end