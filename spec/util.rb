require 'yaml'
require 'traject'
require 'marc_to_argot'
if RUBY_PLATFORM =~ /java/
  java_import 'org.noggit.ObjectBuilder'
else
  require 'yajl'
end

# Utilities for specs
module Util
  # create a brief, simple MARC record that to be populated directly for testing
  def make_rec
    rec = MARC::Record.new
    rec << MARC::ControlField.new('008', ' ' * 40)
    return rec
  end

  def data_path(name)
    File.join(File.expand_path('data', __dir__), name)
  end

  def load_yaml(collection, base)
    filename = data_path(File.join(collection, "#{base}.yml"))
    yaml = File.open(filename) do |f|
      YAML.safe_load(f, permitted_classes: [:Symbol], aliases: true)
    end
    yield yaml if block_given?
    yaml
  end

  def yaml_to_item_fields(collection, base, tag = '999')
    data = load_yaml(collection, base)
    item_fields = data.map do |name, vals|
      field = MARC::DataField.new('999', ' ', ' ')
      vals.each do |k, v|
        field.subfields << MARC::Subfield.new(k, v)
      end
      [name, field]
    end
    items = Hash[item_fields]
    yield items if block_given?
    items
  end

  # utility method for loading MARC data for testing
  def find_marc(collection, file, extension = 'xml')
    data = File.expand_path('data', File.dirname(__FILE__))
    File.join(data, collection, "#{file}.#{extension}")
  end

  def load_json_multiple(json_data)
    records = []
    p = Yajl::Parser.new
    p.on_parse_complete = ->(x) { records << x }
    p.parse(json_data)
    records
  end

  # Loads a traject configuration
  module TrajectLoader
    def create_settings(collection, data_dir, extension)
      spec = MarcToArgot::SpecGenerator.new(collection)
      marc_source_type = extension == 'mrc' ? 'binary' : 'xml'
      flatten_attributes = YAML.load_file("#{data_dir}/flatten_attributes.yml")
      override = File.exist?("#{data_dir}/#{collection}/overrides.yml") ? YAML.load_file("#{data_dir}/#{collection}/overrides.yml") : []

      {
        'argot_writer.flatten_attributes' => flatten_attributes,
        'argot_writer.pretty_print' => false,
        'writer_class_name' => 'Traject::ArgotWriter',
        'specs' => spec.generate_spec,
        'processing_thread_pool' => 1,
        'marc_source.type' => marc_source_type,
        'marc_source.encoding' => 'utf-8',
        'override' => override,
        'log_level' => :error
      }
    end

    def load_indexer(collection = 'argot', extension = 'xml')
      data_dir = File.expand_path('../lib/data',File.dirname(__FILE__))     
      conf_files = ["#{data_dir}/extensions.rb", "#{data_dir}/argot/traject_config.rb", "#{data_dir}/#{collection}/traject_config.rb"]
      indexer_class = MarcToArgot::Indexers.find(collection.to_sym)
      traject_indexer = indexer_class.new create_settings(collection, data_dir, extension)
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

  module TrajectRunTest
    include Util
    include Util::TrajectLoader

    # resets stdout and executes a block, returning
    # all output as a string
    def capture_stdout(capture_stderr = false)
      io = StringIO.new
      err_io = StringIO.new
      old_stdout = $stdout
      old_stderr = $stderr
      $stdout = io
      $stderr = err_io
      begin
        if capture_stderr
          yield io, err_io
        else
          yield io
        end
      ensure
        $stdout = old_stdout
        $stderr = old_stderr
      end
      io.string
    end

    def run_traject(collection, file, extension = 'xml')
      indexer = load_indexer(collection, extension)
      test_file = find_marc(collection, file, extension)
      output = capture_stdout do |_|
        indexer.process(File.open(test_file))
      end
      output
    end

    # Runs traject and parses the results as JSON.
    def run_traject_json(collection, file, extension = 'xml')
      JSON.parse(run_traject(collection, file, extension))
    end

    # Runs traject on a single MARC record and returns JSON
    def run_traject_on_record(collection, record)
      indexer = load_indexer(collection, 'mrc')
      indexer.map_record(record)
    end

  end
end
