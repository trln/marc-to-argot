require 'json'

file = File.read(File.join(File.dirname(__FILE__),'status_map.json'))
JSON.parse(file)