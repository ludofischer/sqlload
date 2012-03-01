#!/usr/bin/env ruby

#   Copyright 2012 Ludovico Fischer
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.


def get_jobs(directory = 'SQL')
  require 'find'
  jobs = []
  
  Find.find(directory)  do |path|
    unless FileTest.directory?(path)
      jobs.push(path)
    end
  end
  
  jobs.sort! do |x, y|
    File.basename(x) <=> File.basename(y)
  end
  
  jobs
end

def get_statements(jobs)
  statements = []
  jobs.each do |path|
    statements.push File.read(path)
  end

  statements
end

require 'optparse'

options = {}

optparse = OptionParser.new do |opts|
  opts.on('-U', '--user USERNAME', 'Specify username') do |user|
    options[:user] = user
  end

  opts.on('-W', '--password PASSWORD', 'Specify password') do |password|
    options[:password] = password
  end

  opts.on('-d', '--database DBNAME', 'Specify database name') do |dbname|
    options[:dbname] = dbname
  end

  opts.on('-p', '--port PORT', 'Specify port') do |port|
    options[:port] = port
  end

  opts.on('-h', '--help', 'Print usage') do
    puts opts
    exit
  end
end

optparse.parse!

dbname = options[:dbname]
  
unless dbname
  abort  "You must specify a database name"
end

user = options.fetch(:user, dbname)
password = options[:password]
port = options.fetch(:port, 5432)

statements = get_statements(get_jobs)

require 'pg'

conn = PG.connect(:host => 'localhost', :port => port, :dbname => dbname, :user => user, :password => password)

statements.each { |statement| conn.exec(statement) }

conn.finish
