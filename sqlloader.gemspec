Gem::Specification.new do |s|
  s.name = "sqlloader"
  s.version = "0.0.1"
  s.license = 'Apache License, Version 2.0'
  s.summary = 'Load and execute SQL from a directory hierarchy. Only supports PostgreSQL'
  s.authors = ['Ludovico Fischer']
  s.email = 'ludovico.fischer@lunatech.com'
  s.homepage = 'https://github.com/ludovicofischer/sqlloader'
  s.add_runtime_dependency 'pg'
end
