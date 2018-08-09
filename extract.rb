#!/bin/env ruby

require 'csv'
require 'oga'

selectors = %w(
  /Return/ReturnHeader/Filer/EIN
  /Return/ReturnHeader/Filer/BusinessName/BusinessNameLine1Txt
  /Return/ReturnData/IRS990/AccountsReceivableGrp/BOYAmt
  /Return/ReturnData/IRS990/AccountsReceivableGrp/EOYAmt
)

# /Return/ReturnData/IRS990/ProgramServiceRevenueGrp/TotalRevenueColumnAmt
# /Return/ReturnData/IRS990/ProgramServiceRevenueGrp/RelatedOrExemptFuncIncomeAmt

csv_string = CSV.generate do |csv|

  # output column names
  csv << selectors.map { |s| s.split(/\//).last(2).join('-') }

  ARGV.each do |a|

    STDERR.puts "Processing #{a}"

    handle = File.open(a)
    document = Oga.parse_xml(handle)

    cols = []

    selectors.each do |s|
      el = document.at_xpath(s)
      if el
        cols << el.text
      else
        cols << nil
      end
    end

    csv << cols
  end

end

puts csv_string
