require 'json'

file = File.read(File.join(File.dirname(__FILE__),'location_shelf_to_location_library.json'))
JSON.parse(file)