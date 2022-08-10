module MarcToArgot
  unless const_defined? :VERSION
    def self.version 
      @version ||= File.read(File.expand_path('../../VERSION', __dir__))
    end
  end
  VERSION = version
end
