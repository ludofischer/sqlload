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

module Tasks
  def self.get_datasets(directory = 'SQL')
    require 'find'
    datasets = []
    
    Find.find(directory)  do |path|
     if File.extname(path) == '.sql'
        datasets.push(path)
      end
    end
    
    datasets.sort! do |x, y|
      File.basename(x) <=> File.basename(y)
    end
    datasets
  end

  def self.get_statements(datasets)
    statements = []
    datasets.each do |dataset|
      statements.push File.read(dataset)
    end
    statements
  end

  def self.list_available_datasets
    puts self.get_datasets
  end

  def self.load_dataset(directory, db_connection)
    statements = self.get_statements(self.get_datasets(directory))
    statements.each do |statement| 
      result = db_connection.exec(statement)
      puts result.cmd_status
    end
  end

  def self.delete_dataset(directory, db_connection)
  end
end

module User
  def self.get_commandline_options(command_string)
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

    optparse.parse!(command_string)
    options

  end
end

module DBConfig
  def self.load(path)
    require 'json'

    config = JSON.parse(File.read(self.get_config_path(path)), :symbolize_names => true)
  end

  def self.get_config_path(dataset_path)
    File.join(dataset_path, 'config.json')
  end
end

module DB
  require 'pg'
  def self.get_db_connection(options)
    dbname = options[:dbname]
    unless dbname
      abort  "You must specify a database name"
    end
    user = options.fetch(:user, dbname)
    password = options[:password]
    port = options.fetch(:port, 5432)
    begin
      db_connection = PG.connect(:host => 'localhost', :port => port, :dbname => dbname, :user => user, :password => password)
      yield db_connection
    ensure
      db_connection.finish unless db_connection.nil?
    end
  end
end

user_options = User.get_commandline_options(ARGV)

case ARGV[0]
when 'list'
  Tasks.list_available_datasets
when 'load'
  dataset = ARGV[1]
  options = DBConfig.load(dataset).merge(user_options)
  if dataset.nil? then abort 'You must specify a dataset to load' end
  DB.get_db_connection(options) do |db_connection|
    Tasks.load_dataset(dataset, db_connection)
  end
when 'reset'
  dataset = ARGV[1]
  options = DBconfig.load(dataset).merge(user_options)
  if dataset.nil? then abort 'You must specify a dataset to reset' end
  DB.get_db_connection(options) do |db_connection|
    Tasks.delete_dataset(dataset, db_connection)
    Tasks.load_dataset(dataset, db_connection)
  end
else abort 'You must specify one of list, load or reset.'
end

