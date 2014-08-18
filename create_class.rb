require_relative 'file_operations.rb'

class CreateClass	
	include FileOperation
	
	def self.read_csv_file
		puts @file_name
	end

	def self.create_class(class_name)
		klass= Object.const_set "#{class_name}",Class.new
		@data[0].each  do |x|
			x.gsub!(/\s/,'_')
			x.downcase
		end
		class_properties=@data[0]
		eval("#{class_name}").class_eval do
			attr_accessor *class_properties
		end
		object_counter = 0
		@data.each do |elements|
			if object_counter >=1
				#element_counter = 0
				Object.const_set "#{class_name}_object_#{object_counter}", eval("#{class_name}.new")
					class_properties.zip(elements).each do |var,value|
						puts Object.const_defined? "#{class_name}_object_#{object_counter}"
						puts "#{var}.....#{value}......#{class_name}_object_#{object_counter}"
						puts("#{class_name}_object_#{object_counter}.#{var}=value")
						eval("#{class_name}_object_#{object_counter}.#{var}=value")
					end
				#end
			end
			object_counter+=1
		end
	end

	def self.set_class
		@csv_file_name="#{@file_name}.csv"
		class_name=@file_name.capitalize
		class_name[class_name.size-1]=''
		@data=CSV.read(@csv_file_name,"r")
		CreateClass.create_class(class_name)
	end
end
CreateClass.run_file
CreateClass.read_csv_file
CreateClass.set_class