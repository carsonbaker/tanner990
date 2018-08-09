#!/bin/env ruby

require 'csv'

CSV.foreach("school-index.csv") do |row|
  url = row.last
  `cd downloads; curl -O #{url}`
end
