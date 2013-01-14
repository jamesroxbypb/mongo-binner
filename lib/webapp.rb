require "sinatra"
require "json"
require "mongo"
require "sinatra/reloader"

class MongoBinner < Sinatra::Base

get "/hi" do
  body "Hello world"
  status 200
end

get "/:collection/graph" do
    # There is way too much going on here, but ...
	@config = YAML.load_file "./config/config.yaml"
	@client = Mongo::MongoClient.new(@config["mongo-host"], 27017)
	@db     = @client[@config["mongo-db"]]

	collection = params[:collection]
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
	to_graph = @db[analysis].find()
	@wibble = 11
	@item = collection
	@rows = []
	to_graph.each {|item|
		next_entry = Hash.new()
		next_entry["year"] = item["bin"].year
		next_entry["month"] = item["bin"].month-1 # Ah JavaScript
		next_entry["day"] = item["bin"].day
		next_entry["hour"] = item["bin"].hour
		next_entry["min"] = item["bin"].min
		next_entry["sec"] = item["bin"].sec
		next_entry["count"] = item["count"]
		@rows.push(next_entry)
	}
	erb :graph
end

get "/data.json" do
	content_type 'application/json'
	to_return = '{"cols":[{"id":"", "label": "Date", "type": "date"},{"id":"",  "label": "submissions", "type": "number"}],'
	to_return += '"rows": ['
    to_return += '{"c":[{"v": "Date(2008,10,6,12,0,0)"}, {"v": 123}]},'
    to_return += '{"c":[{"v": "Date(2008,10,6,12,15,0)"}, {"v": 125}]},'
    to_return += '{"c":[{"v": "Date(2008,10,6,12,30,0)"}, {"v": 227}]},'
    to_return += '{"c":[{"v": "Date(2008,10,6,12,45,0)"}, {"v": 190}]},'
	#to_return += '{"c":[{"v": "2008/10/6"}, {"v": 123}]},'
	to_return += "]}"	

	body to_return
	status 200
end

run! if app_file == $0
end