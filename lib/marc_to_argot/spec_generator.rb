require 'marc_to_argot'

module MarcToArgot
   
    class SpecGenerator

        @data_dir = ''
        @collections = []
        @spec_file_path = ''
        @input = ''
            
        def initialize(input)
            @input = input
            @data_dir = File.expand_path("../data",File.dirname(__FILE__))
            @spec_file_path = File.join(@data_dir,'argot/marc_specs.yml')
            get_collections
        end

        def get_collections
            @collections = Dir.entries("#{@data_dir}").select {|entry| File.directory? File.join(@data_dir,entry) and !(entry =='.' || entry == '..')}
        end

        def get_spec_file_path()
            default = @spec_file_path
            if @collections.include?(@input)
                @spec_file_path = File.join(@data_dir,@input,'marc_specs.yml')
            else
                if File.exist?(@input)
                    @spec_file_path = @input
                end
            end
            if default == @spec_file_path
                warn("Spec file could not be found, using default Argot specs")
            end
        end

        def generate_spec()
            get_spec_file_path
            return transform_spec(YAML.load_file(@spec_file_path))
        end

        def transform_spec(set)
            config = {}
            set.each do |k,v|
                if v.is_a?(Hash)
                    config[k.to_s] = transform_spec(v)
                else
                    config[k.to_s] = v.join(":")
                end
            end
            config if !config.empty?
        end

    end
end
