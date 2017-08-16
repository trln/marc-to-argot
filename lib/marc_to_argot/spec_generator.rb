require 'marc_to_argot'

module MarcToArgot
  #loads and generates spec files for Traject configuration
  class SpecGenerator
    @data_dir = ''
    @collections = []
    @spec_file_path = ''
    @input = ''

    def initialize(input)
      @input = input
      @data_dir = File.expand_path('../data', File.dirname(__FILE__))
      @spec_file_path = File.join(@data_dir, 'argot/marc_specs.yml')
      get_collections
    end

    def get_collections
      @collections = Dir.entries(@data_dir.to_s).select { |entry| File.directory?(File.join(@data_dir, entry)) && !(entry == '.' || entry == '..') }
    end

    def get_spec_file_path
      default = @spec_file_path
      if @collections.include?(@input)
        @spec_file_path = File.join(@data_dir, @input, 'marc_specs.yml')
      else
        @spec_file_path = @input if File.exist?(@input)
      end
      if default == @spec_file_path
        warn('Spec file could not be found, using default Argot specs')
      end
    end

    def generate_spec
      get_spec_file_path
      transform_spec(YAML.load_file(@spec_file_path))
    end

    def transform_spec(set)
      config = {}
      set.each do |k, v|
        config[k.to_s] = if v.is_a?(Hash)
                           transform_spec(v)
                         else
                           v.join(':')
                         end
      end
      config unless config.empty?
    end
  end
end
