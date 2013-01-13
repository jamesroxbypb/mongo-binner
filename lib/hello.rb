require "mongo"
require "yaml"
require "pry"

include Mongo

@config = YAML.load_file "../config/config.yaml"
@client = MongoClient.new(@config["mongo-host"], 27017)
@db     = @client[@config["mongo-db"]]

collection = "items"
analysis = "#{collection}.analysis"
resolution = 15*60

in_need = @db[collection].find({"bin_analysis" => {"$ne" => true}})
in_need.each {|n|
  t = n["_id"].generation_time.to_i
  div = t / resolution
  rounded = div * resolution
  time_bin = Time.at(rounded)
  @db[analysis].update({"bin" => time_bin},{"$inc" => {"count" => 1}}, {:upsert => true})
  n["bin_analysis"] = true
  @db[collection].save(n)
}
#  binding.pry

