require_relative 'file_operations.rb'

require 'mongo'

class CreateClass	
	include FileOperation
	
	def self.read_csv_file
		puts "Reading #{@file_name}.csv file...."
	end

	def self.create_class(class_name)
		Object.const_set "#{class_name}",Class.new
		@data[0].each  do |x|
			x.gsub!(/\s/,'_')
			x.downcase
		end
		
		class_properties=@data[0]
		@clas_properties=class_properties
		eval("#{class_name}").class_eval do
			attr_accessor *class_properties
		end

		object_counter = 0
		@data.each do |elements|
			if object_counter >=1
				#element_counter = 0
				Object.const_set "#{class_name}_object_#{object_counter}", eval("#{class_name}.new")
					class_properties.zip(elements).each do |var,value|
						eval("#{class_name}_object_#{object_counter}.#{var}=value")
					end
				#end
			end
			object_counter+=1
		end
		self.insert_values class_name
	end

	def self.insert_values class_name
		mongo_client = Mongo::MongoClient.new("localhost",27017)
		@db = mongo_client.db("my_database")
		collection_name=class_name.downcase
		collection_name[collection_name.size]='s'
		@coll=@db.collection(collection_name)
		puts "Collection name : #{collection_name}"
		counter=0
		@data.each do |elements|
				if counter>=1
					array=@clas_properties.zip(elements)
					hash=Hash[*array.flatten]
					p hash
					@coll.insert(hash)
				end
			counter+=1
		end
		
	end	

	def self.set_class
		@csv_file_name="#{@file_name}.csv"
		class_name=@file_name.capitalize
		class_name[class_name.size-1]=''
		@data=CSV.read(@csv_file_name,"r")
		CreateClass.create_class class_name
		self.insert_values class_name
	end
end
CreateClass.run_file
CreateClass.read_csv_file
CreateClass.set_class