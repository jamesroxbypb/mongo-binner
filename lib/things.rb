require "sinatra"
require "json"
require "mongo"
require "sinatra/reloader"

class Things < Sinatra::Base

before do
	content_type 'application/json'
end 

get "/hi" do
  body "Hello world"
  status 200
end

get "/:tenant/:collection" do
	limit = 20
	offset = 0
	limit  = Integer(params["limit"]) if params.has_key?("limit")
	offset = Integer(params["offset"]) if params.has_key?("offset")

	@config = YAML.load_file "./config/config.yaml"
	@client = Mongo::MongoClient.new(@config["mongo-host"], 27017)
	@db     = @client[@config["mongo-db"]]

	collection = "#{params[:tenant]}.#{params[:collection]}"
	results = @db[collection].find({},{:limit => limit, :skip => offset}).to_a
	results.each {|r|
		r["id"] = r["_id"].to_s
		r.delete "_id"
	}
	body results.to_json
	status 200
end

post "/:tenant/:collection" do
	blob = JSON.parse request.body.read
	@config = YAML.load_file "./config/config.yaml"
	@client = Mongo::MongoClient.new(@config["mongo-host"], 27017)
	@db     = @client[@config["mongo-db"]]

	collection = "#{params[:tenant]}.#{params[:collection]}"
	a = @db[collection].save(blob)
	body a.to_json
	status 200
end


run! if app_file == $0
end