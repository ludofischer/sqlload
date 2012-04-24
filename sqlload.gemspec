Gem::Specification.new do |s|
  s.name = "sqlload"
  s.version = "0.3.0beta"
  s.license = 'Apache License, Version 2.0'
  s.summary = 'Load and execute SQL from a directory hierarchy. Only supports PostgreSQL'
  s.description = 'sqlload inspects a directory hierarchy: for each subdirectory, sqlload offers to execute any SQL file, using the database specified in the JSON configuration.'
  s.authors = ['Ludovico Fischer']
  s.email = 'ludovico.fischer@lunatech.com'
  s.homepage = 'https://github.com/ludovicofischer/sqlloader'
  s.add_runtime_dependency 'pg', '~> 0.13.0'
  s.files = ['lib/sqlload.rb', 'lib/sqlload/database.rb']
  s.executables << 'sqlload'
end
