require_relative 'file_operations.rb'
class CreateClass
	include FileOperation
	
	def self.read_csv_file
		puts @file_name
	end

	def self.create_class(class_name,*attributes)
		c=Class.new do
			attributes.each do |attributes|
				define_method attributes.intern do
					instance_variable_get("#{attributes}")
				end

				define_method "#{attributes}=".intern do |arg|
					instance_variable_set("#{attributes}",arg)
				end
			end
		end
		#Object.const_set class_name, c
	end

	def self.set_class
		counter =0
		object_id=0
		file_name="#{@file_name}.csv"
		f_name=@file_name.capitalize
		f_name[f_name.size-1]=' '
		data=CSV.read(file_name,"r")
		data.each do |element|
				if counter.eql?(0)
					p data[0]
					CreateClass.create_class(f_name,*element)
					counter+=1
				else
					state[object_id]=f_name.new
					state.attributes=element
					p state.element
					object_id+=1
				end
		end
	end
end
obj=CreateClass.new
CreateClass.run_file
CreateClass.read_csv_file
CreateClass.set_class