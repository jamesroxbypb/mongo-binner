require "yaml"
require "./lib/webapp.rb"

@config = YAML.load_file "./config/config.yaml"
run MongoBinner
