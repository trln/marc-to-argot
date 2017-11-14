require 'yaml'
require 'traject'
require 'marc_to_argot'

# Utilities for specs
module Util
  class TrajectRunTest
    def self.run_traject(collection, file, extension = 'xml')
      indexer = Util::TrajectLoader.load(collection, extension)
      test_file = Util.find_marc(collection, file, extension)
      Util.capture_stdout do |_|
        indexer.process(File.open(test_file))
      end
    end
  end

  # utility method for loading MARC data for testing
  def self.find_marc(collection, file, extension = 'xml')
    data = File.expand_path('data', File.dirname(__FILE__))
    File.join(data, collection, "#{file}.#{extension}")
  end

  # resets stdout and executes a block, returning
  # all output as a string
  def self.capture_stdout
    io = StringIO.new
    old_stdout = $stdout
    $stdout = io
    begin
      yield io
    ensure
      $stdout = old_stdout
    end
    io.string
  end

  # Loads a traject configuration
  class TrajectLoader
    def self.load(collection = 'argot', extension = 'xml')
      data_dir = File.expand_path('../lib/data',File.dirname(__FILE__))
      spec = MarcToArgot::SpecGenerator.new(collection)
      marc_source_type = extension == 'mrc' ? 'binary' : 'xml'
      flatten_attributes = YAML.load_file("#{data_dir}/flatten_attributes.yml")
      override = File.exist?("#{data_dir}/#{collection}/overrides.yml") ? YAML.load_file("#{data_dir}/#{collection}/overrides.yml") : []

      settings = {
        'argot_writer.flatten_attributes' => flatten_attributes,
        'argot_writer.pretty_print' => false,
        'writer_class_name' => 'Traject::ArgotWriter',
        'specs' => spec.generate_spec,
        'processing_thread_pool' => 1,
        'marc_source.type' => marc_source_type,
        'marc_source.encoding' => 'utf-8',
        'override' => override
      }

      conf_files = ["#{data_dir}/extensions.rb", "#{data_dir}/#{collection}/traject_config.rb", "#{data_dir}/argot/traject_config.rb"]

      traject_indexer = Traject::Indexer.new settings
      conf_files.each do |conf_path|
        begin
          traject_indexer.load_config_file(conf_path)
        rescue Errno::ENOENT, Errno::EACCES => e
          raise "Could not read configuration file '#{conf_path}', exiting..."
        rescue Traject::Indexer::ConfigLoadError => e
          raise e
        rescue StandardError => e
          raise e
        end
      end
      traject_indexer
    end
  end
end
