# Pretty column names from the xpath
def pretty_col_name(xpath)
  name_parts = xpath.split(/\//).drop(3)
  name_parts.shift if name_parts.first == "IRS990"
  name_parts.join('-')
end

def gen_csv(col_names, yooks, zooks, filler, max_size_zooks)
  CSV.generate do |csv|
    csv << col_names.flatten
    yooks.count.times do |i|
      row = yooks[i] # [ein, name]
      transposition = zooks[i].dup
      distance_to_fill = max_size_zooks - zooks[i].count
      transposition = transposition.fill(filler, zooks[i].count, distance_to_fill).transpose
      row << transposition
      csv << row.flatten
    end
  end
end
