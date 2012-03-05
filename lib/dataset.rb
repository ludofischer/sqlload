module DB
  require 'pg'
  def get_db_connection(options)
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


module DBConfig
  def load_config(path)
    require 'json'

    config = JSON.parse(File.read(self.get_config_path(path)), :symbolize_names => true)
  end

  def get_config_path(dataset_path)
    File.join(dataset_path, 'config.json')
  end
end


class DataSet
  include DBConfig, DB
  attr_accessor :ups, :downs, :config
  def initialize(directory, user_config)
    @ups = []
    @downs = []
    @directory = directory
    populate() 
    @config = load_config(directory).merge(user_config)
    if insufficient(config)
      raise ArgumentError, 'No database name'
    end
  end
  
  def reset
    load
    delete
   end

   def load
     get_db_connection(@config) do |db_connection|
       @ups.each do |s|
         result = db_connection.exec(s)
         puts result.cmd_status
       end
     end
   end

   def delete
     get_db_connection(@config) do |db_connection|
     @downs.each do |s|
         result = db_connection.exec(s)
         puts result.cmd_status
       end
     end
   end

   def populate()
     require 'find'
     upfiles = []
     downfiles = []
     Find.find(@directory) do |path|
       if is_downs(path)
           downfiles.push(path)
       elsif is_ups(path)
         upfiles.push(path)
       end
    end
    upfiles.sort! do |x, y|
      File.basename(x) <=> File.basename(y)
    end
    
    upfiles.each do |f|
      @ups.push File.read(f)
    end
    
    downfiles.each do |f|
      @downs.push File.read(f)
    end
  end

  private

  def insufficient(config)
    return config[:dbname].nil? 
  end

  def is_ups(path)
    return File.extname(path) == '.sql' && File.basename(path) != 'reset.sql'
  end

  def is_downs(path)
    return File.basename(path) == 'reset.sql'
  end
end
