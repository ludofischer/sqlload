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

module DB
  require 'pg'
  ##
  # Yields a database connection configured with the supplied options.
  # This method will attempt to close the connection once the block terminates.
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
  ##
  # Generates a configuration hash from a JSON file
  #
  # [path] the path to the dataset to load a config for 
  def load_config(path)
    require 'json'

    config = JSON.parse(File.read(self.get_config_path(path)), :symbolize_names => true)
  end

  def get_config_path(dataset_path)
    File.join(dataset_path, 'config.json')
  end
end
