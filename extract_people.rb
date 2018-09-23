#!/bin/env ruby

require 'csv'
require 'oga'
require 'byebug'

require './helper'

selectors = %w(
  /Return/ReturnHeader/Filer/EIN
  /Return/ReturnHeader/Filer/BusinessName/BusinessNameLine1Txt
)

subsection = "/Return/ReturnData/IRS990/Form990PartVIISectionAGrp"

subsection_cols = %w(
  PersonNm
  TitleTxt
  AverageHoursPerWeekRt
  HighestCompensatedEmployeeInd
  ReportableCompFromOrgAmt
  OtherCompensationAmt
)

yooks = []
zooks = []

# open each file
ARGV.each do |a|

  # parse the xml
  document = File.open(a) { |f| Oga.parse_xml(f) }

  # store the fixed-length cols (name and ein) in row_data_1
  # let's call the data from these types of columns Yooks
  yooks << selectors.map do |s|
    document.at_xpath(s)&.text
  end

  # store the var-length cols as an array in the array row_data_2
  # let's call the data from these types of columns Zooks
  zooks << document.xpath(subsection).map do |subsection|
    subsection_cols.map { |sc| subsection.xpath(sc)&.text }
  end

end

max_size_zooks = zooks.map(&:count).max

cols = selectors.map { |selector| pretty_col_name(selector) }
cols << subsection_cols.each.map { |subsection_col|
  max_size_zooks.times.each.map { |i|
    subsection_col + "-#{i+1}"
  }
}

filler = Array.new(subsection_cols.count, nil)
puts gen_csv(cols, yooks, zooks, filler, max_size_zooks)
