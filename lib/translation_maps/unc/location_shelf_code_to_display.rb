require 'json'

file = File.read(File.join(File.dirname(__FILE__),'location_shelf_code_to_display.json'))
JSON.parse(file)