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

grants_other_asst = "/Return/ReturnData/IRS990ScheduleI/GrantsOtherAsstToIndivInUSGrp"

# /Return/ReturnData/IRS990/ProgramServiceRevenueGrp/TotalRevenueColumnAmt
# /Return/ReturnData/IRS990/ProgramServiceRevenueGrp/RelatedOrExemptFuncIncomeAmt

# Pretty column names from the xpath
def pretty_col_name(xpath)
  name_parts = xpath.split(/\//).drop(3)
  name_parts.shift if name_parts.first == "IRS990"
  name_parts.join('-')
end

csv_string = CSV.generate do |csv|

  # For xpath selectors that reference multi-dimensional data, flatten
  # to fill the amount of "room" that we decide to give each selector.

  grants_other_asst_room = 4 # known from inspection

  cols_2 = Array.new(grants_other_asst_room) { |i|
    [
      grants_other_asst + "-#{i}-txt",
      grants_other_asst + "-#{i}-recip-count",
      grants_other_asst + "-#{i}-cash-grant-amt",
      grants_other_asst + "-#{i}-non-cash-asst-amt",
      grants_other_asst + "-#{i}-valuation-method",
      grants_other_asst + "-#{i}-non-cash-asst-desc"
    ]
  }

  # Write columns to CSV
  csv << [selectors, cols_2].flatten.map { |s| pretty_col_name(s) }

  ARGV.each do |a|

    document = File.open(a) { |f| Oga.parse_xml(f) }

    row_data_1 = selectors.map do |s|
      el = document.at_xpath(s)
      if el
        el.text
      end
    end

    row_data_2 = document.xpath(grants_other_asst).map do |grant|
      [
        grant.xpath("GrantTypeTxt").text,
        grant.xpath("RecipientCnt").text, 
        grant.xpath("CashGrantAmt").text, 
        grant.xpath("NonCashAssistanceAmt").text,
        grant.xpath("ValuationMethodUsedDesc").text,
        grant.xpath("NonCashAssistanceDesc").text
      ]
    end

    csv << row_data_1.concat(row_data_2.flatten)

  end

end

puts csv_string
