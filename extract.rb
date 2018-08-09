#!/bin/env ruby

require 'csv'
require 'oga'

selectors = %w(
  /Return/ReturnHeader/Filer/EIN
  /Return/ReturnHeader/Filer/BusinessName/BusinessNameLine1Txt
  /Return/ReturnHeader/TaxPeriodEndDt

  /Return/ReturnHeader/PreparerFirmGrp/PreparerUSAddress/AddressLine1Txt
  /Return/ReturnHeader/PreparerFirmGrp/PreparerUSAddress/CityNm
  /Return/ReturnHeader/PreparerFirmGrp/PreparerUSAddress/StateAbbreviationCd
  /Return/ReturnHeader/PreparerFirmGrp/PreparerUSAddress/ZIPCd

  /Return/ReturnHeader/Filer/USAddress/AddressLine1Txt
  /Return/ReturnHeader/Filer/USAddress/CityNm
  /Return/ReturnHeader/Filer/USAddress/StateAbbreviationCd
  /Return/ReturnHeader/Filer/USAddress/ZIPCd

  /Return/ReturnHeader/Filer/BusinessNameControlTxt
  /Return/ReturnHeader/Filer/PhoneNum

  /Return/ReturnHeader/BusinessOfficerGrp/PersonNm
  /Return/ReturnHeader/BusinessOfficerGrp/PersonTitleTxt
  /Return/ReturnHeader/BusinessOfficerGrp/PhoneNum

  /Return/ReturnData/IRS990/WebsiteAddressTxt
  /Return/ReturnData/IRS990/FormationYr
  /Return/ReturnData/IRS990/ActivityOrMissionDesc
  /Return/ReturnData/IRS990/TotalEmployeeCnt
  /Return/ReturnData/IRS990/TotalVolunteersCnt

  /Return/ReturnData/IRS990/PYContributionsGrantsAmt
  /Return/ReturnData/IRS990/CYContributionsGrantsAmt
  /Return/ReturnData/IRS990/PYProgramServiceRevenueAmt
  /Return/ReturnData/IRS990/CYProgramServiceRevenueAmt
  /Return/ReturnData/IRS990/PYInvestmentIncomeAmt
  /Return/ReturnData/IRS990/CYInvestmentIncomeAmt
  /Return/ReturnData/IRS990/PYOtherRevenueAmt
  /Return/ReturnData/IRS990/CYOtherRevenueAmt
  /Return/ReturnData/IRS990/PYTotalRevenueAmt
  /Return/ReturnData/IRS990/CYTotalRevenueAmt
  /Return/ReturnData/IRS990/PYGrantsAndSimilarPaidAmt
  /Return/ReturnData/IRS990/CYGrantsAndSimilarPaidAmt
  /Return/ReturnData/IRS990/PYBenefitsPaidToMembersAmt
  /Return/ReturnData/IRS990/CYBenefitsPaidToMembersAmt
  /Return/ReturnData/IRS990/PYSalariesCompEmpBnftPaidAmt
  /Return/ReturnData/IRS990/CYSalariesCompEmpBnftPaidAmt
  /Return/ReturnData/IRS990/PYTotalProfFndrsngExpnsAmt
  /Return/ReturnData/IRS990/CYTotalProfFndrsngExpnsAmt
  /Return/ReturnData/IRS990/CYTotalFundraisingExpenseAmt
  /Return/ReturnData/IRS990/PYOtherExpensesAmt
  /Return/ReturnData/IRS990/CYOtherExpensesAmt
  /Return/ReturnData/IRS990/PYTotalExpensesAmt
  /Return/ReturnData/IRS990/CYTotalExpensesAmt
  /Return/ReturnData/IRS990/PYRevenuesLessExpensesAmt
  /Return/ReturnData/IRS990/CYRevenuesLessExpensesAmt

  /Return/ReturnData/IRS990/TotalAssetsBOYAmt
  /Return/ReturnData/IRS990/TotalAssetsEOYAmt
  /Return/ReturnData/IRS990/TotalLiabilitiesBOYAmt
  /Return/ReturnData/IRS990/TotalLiabilitiesEOYAmt
  /Return/ReturnData/IRS990/NetAssetsOrFundBalancesBOYAmt
  /Return/ReturnData/IRS990/NetAssetsOrFundBalancesEOYAmt

  /Return/ReturnData/IRS990/MissionDesc


  /Return/ReturnData/IRS990/AccountsReceivableGrp/BOYAmt
  /Return/ReturnData/IRS990/AccountsReceivableGrp/EOYAmt
)

# /Return/ReturnData/IRS990/ProgramServiceRevenueGrp/TotalRevenueColumnAmt
# /Return/ReturnData/IRS990/ProgramServiceRevenueGrp/RelatedOrExemptFuncIncomeAmt

csv_string = CSV.generate do |csv|

  # output column names
  csv << selectors.map { |s| s.split(/\//).drop(2).join('-') }

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
