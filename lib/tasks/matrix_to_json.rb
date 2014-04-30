#!/usr/bin/env ruby

# Copy and paste the matrix from Excel to Notepad, including table headers.
# Save the file and pass the filename to this script for conversion.

OUTPUT_FILE = "./loan-matrix.json"
input = ARGV[0]
matrix = {}

puts "Converting #{input}"

File.open(input, 'r') do |f|
  f.gets # Discard the first line
  while line = f.gets
    lamt,acq,handling,p1,p2,p3,p4,p5,p6,p7,p8 = line.gsub(/[^0-9\s\.]/,'').split
    matrix[p1] = {
      "loan_amount" => lamt,
      "acq"         => acq,
      "handling"    => handling,
      "payment-1"   => p1,
      "payment-2"   => p2,
      "payment-3"   => p3,
      "payment-4"   => p4,
      "payment-5"   => p5,
      "payment-6"   => p6,
      "payment-7"   => p7,
      "payment-8"   => p8,
    }
  end
end

require 'json'
File.open(OUTPUT_FILE, 'w') { |f| f.puts matrix.to_json }