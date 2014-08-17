#!/usr/bin/ruby
require 'csv'
module FileOperation
  
  def self.included(base)
    base.extend(AccessMethods)    
  end

  module AccessMethods
    def get_file_name
      puts "Enter the file name you want to parse :"
      @file_name=gets.chomp
    end

    def run_file
      @file_name=get_file_name
      file_parse=File.open("#{@file_name}.html","r")
      if file_parse
        csv=CSV.open("states.csv","w")
        if csv
          csv.truncate(0)
        end
        csv.close
          file_parse.each_line do |line|
            header = line.scan(/<th>([a-z0-9\s]*)<\/th>/i)
            unless header.eql?(nil)
              write_record_in_csv(header)
            end
            records = line.scan(/<td>([a-z0-9\s\-\.' ]*)<\/td>/i)
            write_record_in_csv(records)
          end
      else
      	puts "File not found..!"
     	end
     	file_parse.close
    end
    
    def write_record_in_csv(content)
      data=Array.new
      CSV.open("states.csv","a") do |csv|
        content.each do |counter|
          counter.each do |element|
            data << element
          end
          if (data.size).eql?(3)
            csv << data
          end
        end
      end
    end
  end
end