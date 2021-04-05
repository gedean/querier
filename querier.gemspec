Gem::Specification.new do |s|
  s.name          = 'querier'
  s.version       = '0.2.0'
  s.date          = '2021-04-05'
  s.summary       = 'Active Record Querier'
  s.description   = 'Active Record queries with variable number of params'
  s.authors       = ['Gedean Dias']
  s.email         = 'gedean.dias@gmail.com'
  s.files         = Dir['README.md', 'lib/**/*']
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.7.0'
  s.homepage      = 'https://github.com/gedean/querier'
  s.license       = 'MIT'
end
