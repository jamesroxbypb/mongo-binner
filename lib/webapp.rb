require "sinatra"
require "json"
require "sinatra/reloader"

class MongoBinner < Sinatra::Base
get "/hi" do
  body "Hello world"
  status 200
end

get "/graph" do
	@wibble = 11
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