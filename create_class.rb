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
				Object.const_set "#{class_name}_object_#{object_counter}", eval("#{class_name}.new")
					class_properties.zip(elements).each do |var,value|
						eval("#{class_name}_object_#{object_counter}.#{var}=value")
					end
				#end
			end
			object_counter+=1
		end
	end

	def self.insert_update_values class_name
		mongo_client = Mongo::MongoClient.new("localhost",27017)
		@db = mongo_client.db("my_database")
		collection_name=class_name.downcase
		collection_name[collection_name.size]='s'
		@coll=@db.collection(collection_name)
		puts "Collection name : #{collection_name}"
		print "Please set Primary Key for collection :"
		primary_key=gets.chomp
		if @coll.count.eql?(0)
			self.insert_values
		else 
			self.update_values primary_key
		end
	end	

	def self.insert_values
		p "here i m in insert_values"
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

	def self.update_values primary_key
		counter=0
		key_flag=0
		@coll.find().each do |document|
			doc_hash = document.to_hash
			if doc_hash.key?(primary_key)
				@data.each do |elements|
					if counter>=1
						array=@clas_properties.zip(elements)
						hash=Hash[*array.flatten]
						if hash[primary_key]==doc_hash[primary_key]
							p hash 
							@coll.update({primary_key => doc_hash[primary_key]},hash)
							key_flag=1
							@coll.save(counter)
						end	
					end
					counter+=1
				end
			else
				key_flag = 0
			end
		end
		if key_flag==0
			puts "Sorry Primary key is not present.Cant Update collection!"
		end
	end

	def self.set_class
		@csv_file_name="#{@file_name}.csv"
		class_name=@file_name.capitalize
		class_name[class_name.size-1]=''
		@data=CSV.read(@csv_file_name,"r")
		CreateClass.create_class class_name
		self.insert_update_values class_name
	end
end
CreateClass.run_file
CreateClass.read_csv_file
CreateClass.set_class