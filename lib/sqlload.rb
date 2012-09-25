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

require 'sqlload/database'
require 'pty'
require 'expect'

## 
# A collection of data that can be inserted together into a database
class DataSet
  include DBConfig, DB
  attr_accessor :ups, :downs, :raws, :config, :directory

  ##
  # Creates a dataset using the SQL and the configuration contained
  # in directory. The supplied user configuration overrides
  # the configuration contained in the directory
  def initialize(directory, user_config = {})
    @ups = []
    @downs = []
    @raws = []
    @directory = directory
    populate() 
    @config = load_config(directory).merge(user_config)
    if insufficient(config)
      raise ArgumentError, 'No database name'
    end
  end
  
  ##
  # If there are reset scripts available,
  # executes them before executing once again the regular scripts
  def reset
    if @downs.empty?
      raise ArgumentError, 'There are no reset scripts to run'
    end
    delete
    load
  end
  
  ##
  # Executes the SQL scripts associated with the dataset.
  def load
    get_db_connection(@config) do |db_connection|
      @ups.each do |s|
        result = db_connection.exec(s.statement)
        puts "#{s.filename}: #{result.cmd_status}"
      end
    end
    psql_count = 0
    @raws.each do |s|
      puts "Executing #{s.filename}"
      system({'PGPASSWORD' => @config[:password]}, "psql -h localhost -U #{@config[:user]} -d #{@config[:dbname]} < #{s.filename}")
      psql_count += 1
    end
    puts "psql invoked #{psql_count} time(s)"
  end
   
  ##
  # Executes the SQL scripts marked as reset scripts
  def delete
    get_db_connection(@config) do |db_connection|
      @downs.each do |s|
        result = db_connection.exec(s.statement)
        puts "#{s.filename}: #{result.cmd_status}"
      end
    end
  end
  
  def to_s
    File.basename(@directory)
  end
  
  private
  
  DataPiece = Struct.new(:filename, :statement)
  
  # Fills the list of statements to execute from the information
   # found by inspecting the directory contents
  def populate()
    require 'find'
    Find.find(@directory) do |path|
       if File.file?(path) && File.extname(path) == '.sql'
         data = DataPiece.new(path, File.read(path))
         if is_raws path
           @raws << data
         elsif is_downs path
           @downs << data
         elsif is_ups path
           @ups << data
         end
       end
    end
    
    @ups.sort! do |x, y|
      File.basename(x.filename) <=> File.basename(y.filename)
    end

    @raws.sort! do |x, y|
      File.basename(x.filename) <=> File.basename(y.filename)
    end
  end

  # Returns true if the configuration does not contain enough information
  # to connect to a database 
  def insufficient(config)
    config[:dbname].nil? 
  end
  
  def is_ups(path)
    File.extname(path) == '.sql' && File.basename(path) != 'reset.sql'
  end
  
  def is_downs(path)
    File.basename(path) == 'reset.sql'
  end
  
  def is_raws(path)
    File.fnmatch?('*psql*', path)
  end
end
