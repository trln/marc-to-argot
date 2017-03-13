# Encoding: UTF-8

require 'yaml'
require 'marc_to_argot'

module MarcToArgot
   
    class SpecGenerator
            
        def self.generate_spec_file(spec_file)
            spec_config = YAML.load_file(spec_file)
            config = transform_spec(spec_config)
            config if !config.empty?
        end

        def self.transform_spec(set)
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
