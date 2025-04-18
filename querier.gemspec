Gem::Specification.new do |s|
  s.name          = 'querier'
  s.version       = '0.4.6'
  s.date          = '2025-04-18'
  s.summary       = 'Execução de queries SQL parametrizadas com ActiveRecord'
  s.description   = 'Permite executar consultas SQL a partir de templates fixos com substituição segura de parâmetros, integrando com ActiveRecord e retornando resultados como hash ou struct.'
  s.authors       = ['Gedean Dias']
  s.email         = 'gedean.dias@gmail.com'
  s.files         = Dir['README.md', 'lib/**/*']
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 3.4'
  s.homepage      = 'https://github.com/gedean/querier'
  s.license       = 'MIT'
end
