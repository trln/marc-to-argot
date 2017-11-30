require 'marc_to_argot'

module MarcToArgot
  #loads and generates spec files for Traject configuration
  class SpecGenerator
    @data_dir = ''
    @collections = []
    @DEFAULT_SPEC_PATH = ''
    @override_spec_path = ''
    @spec_file_path = ''
    @input = ''

    def initialize(input)
      @input = input
      @data_dir = File.expand_path('../data', File.dirname(__FILE__))
      @DEFAULT_SPEC_PATH = File.join(@data_dir, 'argot/marc_specs.yml')
      get_collections
      get_override_spec_path
    end

    def get_collections
      @collections = Dir.entries(@data_dir.to_s).select { |entry| File.directory?(File.join(@data_dir, entry)) && !(entry == '.' || entry == '..') }
    end

    def get_override_spec_path
      default = @override_spec_path
      if @collections.include?(@input)
        @override_spec_path = File.join(@data_dir, @input, 'marc_specs.yml')
      else
        @override_spec_path = @input if File.exist?(@input)
      end
      if default == @override_spec_path
        warn('Spec file could not be found, using default Argot specs')
      end
    end

    def default_spec_file
     @DEFAULT_SPEC_PATH
    end

    def override_spec_file
      @override_spec_path
    end


    def generate_spec
      if @override_spec_path == nil
        transform_spec(YAML.load_file(@DEFAULT_SPEC_PATH))
      else
        transform_spec(merge_specs)
      end
    end

    def merge_specs
      mspec = {}
      dspec = YAML.load_file(@DEFAULT_SPEC_PATH)
      ospec = YAML.load_file(@override_spec_path)

      dspec.each do |k, v|
        if v.is_a?(Hash)
          mspec[k] = {}
          v.each do |subk, subv|
            if ospec.has_key?(k)
              if ospec[k].has_key?(subk)
                mspec[k][subk] = ospec[k][subk]
              else
                mspec[k][subk] = subv
              end
            else
             mspec[k][subk] = subv
            end
          end
        else
          if ospec.has_key?(k)
            mspec[k] = ospec[k]
          else
            mspec[k] = dspec[k]
          end
        end
      end

      in_o_only = ospec.keys - dspec.keys
      in_o_only.each { |k| mspec[k] = ospec[k] }

      mspec

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
