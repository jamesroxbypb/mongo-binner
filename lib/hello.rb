require "mongo"
require "yaml"
require "pry"

include Mongo

@config = YAML.load_file "../config/config.yaml"
@client = MongoClient.new(@config["mongo-host"], 27017)
@db     = @client[@config["mongo-db"]]

collection = "items"
in_need = @db[collection].find({"bin_analysis" => {"$ne" => true}})
in_need.each {|n|
  t = n["_id"].generation_time 
  puts n
binding.pry
}


