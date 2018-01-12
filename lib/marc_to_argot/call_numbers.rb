require 'nokogiri'
require 'json'
require 'lcsort'

module MarcToArgot
  # Utilities for handling call numbers
  module CallNumbers
    def self.included(base)
      base.extend(LCC)
    end

    # Call numbers in Library of Congress Classification style
    module LCC
      @root = nil

      def self.normalize(lccn, options = {})
        norm = Lcsort.normalize(lccn, options)
        norm || lccn
      end

      # represents a range of call numbers
      # associated with a label that can be indexed.
      # rubocop:disable BlockLength
      Range = Struct.new(:label, :bounds, :children, :first) do
        def initialize(label, bounds = [], children = [], first = nil)
          super
          if bounds.empty?
            if match = label.match(/^([A-Z])\W+-/)
              self.first ||= match.captures[0]
            end
          end
        end

        def path(normalized_lccn)
          if contains(normalized_lccn)
            parts = [self]
            while (child = parts[-1].children.find { |c| c.contains(normalized_lccn) })
              parts << child
            end
            parts
          end
        end

        def contains(normalized_lccn)
          if bounds.empty?
            first == '*' || first == normalized_lccn[0]
          else
            bounds[0] <= normalized_lccn && bounds[1] >= normalized_lccn
          end
        end

        def to_json(*_)
          JSON.generate(to_h)
        end

        def self.from_json(h)
          children = h.fetch('children', []).map { |d| from_json(d) }
          Range.new(h['label'], h['bounds'], children, h['first'])
        end
      end # class Range

      def self.root
        @root ||= load_root
      end

      # get contents of a specified range as a tree
      def self.tree(node = nil, indent = 0)
        node ||= root
        result = '  ' * indent + "#{node.label} : #{node.bounds}\n"
        result << node.children.collect { |x| tree(x, indent + 1) }.join("\n")
      end

      # get an array of range labels that match the supplied call number
      # from least to most specific
      def self.find_path(call_number)
        norm = normalize(call_number)
        return '' unless norm
        begin
          root.path(norm)[1..-1].collect(&:label)
        rescue
          nil
        end
      end

      def self.load_root
        path = File.expand_path('../../data/shared/lcc_callnums.json', __FILE__)
        raise 'Source LCC data (data/shared/lcc_callnums.json) is not available.' unless File.exist?(path)
        local_root = File.open(path) do |f|
          Range.from_json(JSON.parse(f.read))
        end
        local_root
      end

      def self.extract_range_xml(el)
        label = el.xpath('DVAL/SYN')[0].text
        children = el.xpath('DIMENSION_NODE').collect { |x| extract_range(x) }
        bounds = [el.xpath('DVAL/LBOUND/BOUND/@VALUE').first, el.xpath('DVAL/UBOUND/BOUND/@VALUE').first]
        bounds = [] if bounds.all?(&:nil?)
        bounds.map! { |x| Lcsort.normalize(x.value) }
        Range.new(label, bounds, children)
      end

      def self.from_xml(path)
        doc = File.open(path) do |f|
          Nokogiri::XML(f)
        end
        local_root = Range.new('* - Root', [], [], '*')
        results = doc.xpath('/DIMENSIONS/DIMENSION/DIMENSION_NODE/DIMENSION_NODE').collect do |node|
          extract_range_xml(node)
        end
        local_root.children = results
        local_root
      end
    end # LCC
  end # CallNumbers
end # MarcToArgot
