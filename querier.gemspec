require 'date'

Gem::Specification.new do |s|
  s.name          = 'querier'
  s.version       = '0.5.0'
  s.date          = Date.today.to_s
  s.summary       = 'Safe execution of parameterized SQL queries with ActiveRecord'
  s.description   = 'Gem that simplifies the execution of custom SQL queries using ActiveRecord, ' \
                    'with support for parameterized templates and practical result formats. ' \
                    'Allows safe parameter substitution and data return as hash or struct.'
  s.authors       = ['Gedean Dias']
  s.email         = 'gedean.dias@gmail.com'
  s.files         = Dir['README.md', 'LICENSE', 'lib/**/*'].select { File.file?(it) }
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 3.4'
  s.homepage      = 'https://github.com/gedean/querier'
  s.license       = 'MIT'
  
  s.add_runtime_dependency 'activerecord'
  s.add_runtime_dependency 'ostruct'
  
  s.add_development_dependency 'rspec', '~> 3.12'
  s.add_development_dependency 'rake', '~> 13.0'
  
  s.metadata = {
    'bug_tracker_uri'   => 'https://github.com/gedean/querier/issues',
    'changelog_uri'     => 'https://github.com/gedean/querier/blob/main/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/gedean/querier#readme',
    'homepage_uri'      => 'https://github.com/gedean/querier',
    'source_code_uri'   => 'https://github.com/gedean/querier',
    'rubygems_mfa_required' => 'true'
  }
end
