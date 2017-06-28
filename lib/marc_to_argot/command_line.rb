require 'marc_to_argot'

module MarcToArgot
  # The class that executes for the Argot command line utility.
  class CommandLine < Thor
    ###############
    # Flatten
    ###############
    desc 'create <collection> [<input>] [<output>]', 'Create an argot file'
    long_desc <<-LONGDESC
      Creates Argot (JSON) formatted output  from MARC21/MARCXML formatted input.
      <input> and <output> filenames are both optional, if omitted, input will be read from 
      STDIN and output sent to STDOUT.  

      For the case where you want to read from STDIN and send output to a named file, specify - (a single dash) 
      for <input>.

     Traject configuration is achieved through the use of 'spec' files, which are in YAML format and specify common mappings.
     Each collection also uses a standard `traject` configuration file.

     By default, the configuration files are loaded from directories stored along with the gem's library files.  Usually this will 
     be somewhere like 

     `$HOME/.gem/ruby/[ruby version]/gems/marc_to_argot_${VERSION}/lib/data/[collection]`

     but that can change depending on how you installed the gem.
     LONGDESC

    method_option(pretty: {
                            type: :boolean,
                    default: false,
                    aliases: '-p',
                    desc:  'pretty print resulting json'
                      }
                                                                  )
    method_option   :spec_option,
                    :type => :string,
                    :default => "",
                    :aliases => "-s",
                    :desc => "use a different marc spec file, can either be a path to a spec file, or the name of an existing collection"
    method_option   :thread_pool,
                    :type => :numeric,
                    :default => 3,
                    :aliases => "-z",
                    :desc => "processing thread pool"
    method_option   :type,
                    :type => :string,
                    :default => "xml",
                    :aliases => "-t",
                    :desc => "xml, json or binary"
    method_option   :encoding,
                    :type => :string,
                    :default => "UTF-8",
                    :aliases => "-e",
                    :desc => "UTF-8 or MARC-8. MARC-8 only used if type = binary"
    def create(collection, input=$stdin, output=$stdout)
      # allow traditional '-' to designate stdin as input, so you can specify just an output filename
      input = $stdin if input == '-'

      data_dir = File.expand_path("../data",File.dirname(__FILE__))
      spec = MarcToArgot::SpecGenerator.new options.spec_option.empty? ? collection : options.spec_option
      marc_specs = spec.generate_spec
      if collection.empty?
        coll_opt = spec.instance_variable_get(:@collections).join("\n")
        abort("Plesae specify a collection \n Available options: \n #{coll_opt}")
      end
      
      abort('Could not find the input file at #{input}') unless File.exist?(input)

      if output.nil?
        abort('Please provide an output file')
      end

      flatten_attributes = YAML.load_file("#{data_dir}/flatten_attributes.yml")

      override = File.exist?("#{data_dir}/#{collection}/overrides.yml") ? YAML.load_file("#{data_dir}/#{collection}/overrides.yml") : []

      settings = {
        "argot_writer.flatten_attributes" => flatten_attributes,
        "argot_writer.pretty_print" => options.pretty,
        "writer_class_name" => "Traject::ArgotWriter",
        "specs" => marc_specs,
        "processing_thread_pool" => options.thread_pool,
        "marc_source.type" => options.type,
        "marc_source.encoding" => options.encoding,
        "override" => override
      }

      # only set the output file if ''output' doesn't look like an IO object already.
      settings["output_file"]= output unless output.respond_to?(:read)

      conf_files = ["#{data_dir}/extensions.rb","#{data_dir}/#{collection}/traject_config.rb","#{data_dir}/argot/traject_config.rb"]

      traject_indexer = Traject::Indexer.new settings
      conf_files.each do |conf_path|
        begin
          traject_indexer.load_config_file(conf_path)
        rescue Errno::ENOENT, Errno::EACCES => e
          puts "Could not read configuration file '#{conf_path}', exiting..."
          exit 2
        rescue Traject::Indexer::ConfigLoadError => e
          puts "\n"
          puts e.message
          puts e.config_file_backtrace
          puts "\n"
          puts "Exiting..."
          exit 3
        end
      end

      traject_indexer.logger.info("traject (#{Traject::VERSION}) executing with: ")

      io = input.respond_to?(:read) ? input : File.open(input, 'r')
      filename = input.to_s
      traject_indexer.settings['command_line.filename'] = filename if filename

      result = traject_indexer.process(io)
      
      return result

    rescue Exception => e
      # Try to log unexpected exceptions if possible
      traject_indexer && traject_indexer.logger &&  traject_indexer.logger.fatal("Traject::CommandLine: Unexpected exception, terminating execution: #{e.inspect}") rescue nil
      raise e
    end
  end
end