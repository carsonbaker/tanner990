#!/bin/env ruby

require 'sqlite3'
require 'json'

db = SQLite3::Database.new('index.sqlite3')

index_2017 = File.read("index_2017-pretty.json")

index_json = JSON.parse(index_2017)

db.execute( %{
  CREATE TABLE index2017
  (ein varchar(100) PRIMARY KEY,
  url varchar(1000),
  organization_name varchar(200))
} )

for org in index_json["Filings2017"]
  begin
    db.execute( %{ INSERT INTO index2017 VALUES( "#{org["EIN"].to_s}", "#{org["URL"]}", "#{org["OrganizationName"]}") })
  rescue
    puts 'x'
  end
end

