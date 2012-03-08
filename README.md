SQL Loader
==========

SQL Loader executes SQL scripts contained in a directory hierarchy into a PostgreSQL database.

Usage
-----
In the sqlloader directory, execute `gem build`, then `gem install` to make the gem available to your Ruby installation.

You will then be able to use the _sqlload_ command-line utility to automate the execution of SQL scripts. 

You must supply a directory layout similar to this:

SQL/
   Dataset1/1.sql
   Dataset1/config.json
   Dataset2/reset.sql

sqlload will look below the SQL directory in the directory where it is executed. Each subdirectory regroups a collection of SQL scripts and a configuration file in JSON format that describes how to connect to the database.

* sqlload list will list the datasets.
* sqlload load [dataset name] will execute the sql scripts in that dataset ordered by filename, except the 'reset.sql' one
* sqlload reset [dataset name] will execute the 'reset.sql' script, then the others

You can override the connection information by passing named command line arguments. The syntax is meant to be the same as the psql command line utility.

Configuration
-------------

Configuration is per dataset. You can place a config.json file in the dataset directory, where you can override the following properties:

 * host
 * port
 * dbname
 * username
 * password

Example config.json:

    { "dbname": "bar", "username": "foo" }
    
Copyright
---------
Copyright 2012 Ludovico Fischer

Licensed under the Apache License, Version 2.0 (the "License");
   
   You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.