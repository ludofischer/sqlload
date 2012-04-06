Gem::Specification.new do |s|
  s.name = "sqlloader"
  s.version = "0.2.0"
  s.license = 'Apache License, Version 2.0'
  s.summary = 'Load and execute SQL from a directory hierarchy. Only supports PostgreSQL'
  s.description = 'sqlloader inspects a directory hierarchy: for each subdirectoyr, sqlloader offers to execute any SQL file, using the database specified in the JSON configuration.'
  s.authors = ['Ludovico Fischer']
  s.email = 'ludovico.fischer@lunatech.com'
  s.homepage = 'https://github.com/ludovicofischer/sqlloader'
  s.add_runtime_dependency 'pg'
  s.files = ['lib/sqlloader.rb', 'lib/sqlloader/database.rb']
  s.executables << 'sqlload'
end
