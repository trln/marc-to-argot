require 'json'
require 'traject/line_writer'

# The ArgotWriter outputs one JSON hash per record, separated by newlines.
# It's pretty much an exact copy of the JSON writer, but with a "de-arrayifier
# I.e., it takes a list of attributes and converts the matching attribute value (array) into a hash
#
# ## Settings
#
# * output_file A filename to send output; default will use stdout.
#
# * argot_writer.pretty_print: [default: false]: Pretty-print (e.g., include newlines, indentation, etc.)
# each JSON record instead of just mashing it all together on one line. The default, no pretty-printing option
# produces one record per line, easy to process with another program.
#
# * argot_writer.flatten_attrbiutes: An array of attributes to "de-array"
#
# ## Example output
#
# Without pretty printing, you end up with something like this (just two records shown):
#
#     {"id":["000001118"],"oclc":["ocm00085737"],"sdrnum":["sdr-nrlf.b170195454"],"isbn":["0137319924"],"lccn":["73120791"],"mainauthor":["Behavioral and Social Sciences Survey Committee. Psychiatry Panel."],"author":["Behavioral and Social Sciences Survey Committee. Psychiatry Panel.","Hamburg, David A., 1925-"],"author2":["Behavioral and Social Sciences Survey Committee. Psychiatry Panel.","Hamburg, David A., 1925-"],"authorSort":["Behavioral and Social Sciences Survey Committee. Psychiatry Panel."],"author_top":["Behavioral and Social Sciences Survey Committee. Psychiatry Panel.","Edited by David A. Hamburg.","Hamburg, David A., 1925- ed."],"title":["Psychiatry as a behavioral science."],"title_a":["Psychiatry as a behavioral science."],"title_ab":["Psychiatry as a behavioral science."],"title_c":["Edited by David A. Hamburg."],"titleSort":["Psychiatry as a behavioral science"],"title_top":["Psychiatry as a behavioral science."],"title_rest":["A Spectrum book"],"series2":["A Spectrum book"],"callnumber":["RC327 .B41"],"broad_subject":["Medicine"],"pubdate":[1970],"format":["Book","Online","Print"],"publisher":["Prentice-Hall"],"language":["English"],"language008":["eng"],"editor":["David A. Hamburg."]}
#     {"id":["000000794"],"oclc":["ocm00067181"],"lccn":["78011026"],"mainauthor":["Clark, Albert Curtis, 1859-1937."],"author":["Clark, Albert Curtis, 1859-1937."],"authorSort":["Clark, Albert Curtis, 1859-1937."],"author_top":["Clark, Albert Curtis, 1859-1937."],"title":["The descent of manuscripts.","descent of manuscripts."],"title_a":["The descent of manuscripts.","descent of manuscripts."],"title_ab":["The descent of manuscripts.","descent of manuscripts."],"titleSort":["descent of manuscripts"],"title_top":["The descent of manuscripts."],"callnumber":["PA47 .C45 1970"],"broad_subject":["Language & Literature"],"pubdate":[1918],"format":["Book","Online","Print"],"publisher":["Clarendon Press"],"language":["English"],"language008":["eng"]}
#
# ## Example configuration file
#
#     require 'traject/argot_writer'
#
#     settings do
#       provide "writer_class_name", "Traject::ArgotWriter"
#       provide "output_file", "out.json"
#       provide "argot_writer.flatten_attributes", %w('title')
#     end
class Traject::ArgotWriter < Traject::LineWriter

  def self.flatten_record!(rec,flatten_attributes)
    rec.each do |key,value|
      if flatten_attributes.include?(key)
        if value.is_a?(Array)
          rec[key] = value[0]
        end
      end
    end
  end

  def serialize(context)
    hash = context.output_hash
    if settings["argot_writer.flatten_attributes"]
      self.class.flatten_record!(hash,settings["argot_writer.flatten_attributes"])
    end

    if settings["argot_writer.pretty_print"]
      JSON.pretty_generate(hash)
    else
      JSON.generate(hash)
    end
  end
end