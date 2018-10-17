require 'active_support'
require 'active_support/core_ext/hash'
require 'csv'
require 'uri'

module DbVar::RDF
  module Reader
    class FormatError < StandardError
    end

    # = Genome Variation Format 1.10
    #
    # == Specifications
    #
    # === Pragmas:
    # - Begin with '##'
    # - Contain meta-data.
    # - Only this one is required: `##gvf-version 1.10`
    #
    # === Feature Lines:
    # - Nine tab-delimited columns.
    #   - seqid: The chromosome or contig on which the sequence_alteration is located (text).
    #   - source: The source (i.e. an algorithm or database) of the sequence_alteration (text.)
    #   - type: An SO term describing the type of sequence_alteration (child term of SO sequence_alteration), no_sequence_alteration (SO no sequence alteration), or a gap.
    #   - start: A 1-based integer for the begining of the sequence_alteration locus on the plus strand (integer).
    #   - end: A 1-based integer of the end of the sequence_alteration on plus strand (integer).
    #   - score: A (Phred scaled) probability that the sequence_alteration call is incorrect (real number).
    #   - strand: The strand of the feature (+/-).
    #   - phase: This column allows compatibility with GFF3 (.).
    #   - attributes: Tag/value pairs describing attributes of the sequence_alteration (tag1=value1,value2;tag2=value1;).
    #     - ID: A file-wide unique identifier (required).
    #     - Variant_seq: All unique sequences seen in the individual described in the file at the features locus - including the reference sequence if appropriate (required). Any IUPAC nucleotide symbol is allowed, but usually just A, T, G, C. Plus any of the following:
    #       - . (period): Unknown/missing value.
    #       - - (hyphen): No sequence (e.g. for a homozygous deletion Variant_seq=-;).
    #       - ~ (tilde): Place holder for a sequence too long to show. The tilde can be followed by an integer that describes the length of the omitted sequence.
    #       - @ (at): An alias for the sequence found in the Reference_seq attribute.
    #       - ! (exclamation): Place holder for the missing sequence at a hemizygous locus.
    #       - ^ (caret): Place holder for the missing sequence at a location without enough data to make an accurate call (no-call locus).
    #     - Reference_seq: The reference sequence. Nucleotide characters as well as '-' and '~' as described above.
    #
    # @note see more details on https://github.com/The-Sequence-Ontology/Specifications/blob/master/gvf.md
    class GVF
      class Attributes < Hash
        class << self
          # @param [String] str string at `INFO` column
          # @return [Hash] a hash that values are associated with column ID
          def parse(str)
            entries = str.split(';')
                        .map { |x| x.split('=', 2) }
                        .map { |k, v| [k, CSV.parse_line(v)&.map { |x| ::URI.decode(x) }] }
            Hash[entries].symbolize_keys
          end
        end
      end

      class Row
        attr_accessor :header

        # @return [String]
        attr_accessor :seqid

        # @return [String]
        attr_accessor :source

        # @return [String]
        attr_accessor :type

        # @return [Integer]
        attr_accessor :start

        # @return [Integer]
        attr_accessor :end

        # @return [Float]
        attr_accessor :score

        # @return [String]
        attr_accessor :strand

        # @return [Integer]
        attr_accessor :phase

        # @return [Attributes]
        attr_accessor :attributes

        def initialize(header = nil)
          @header = header

          yield self if block_given?
        end

        def to_rdf(model)
          model.new(self)
        end
      end

      class << self

        COLUMN_DELIMITER = "\t".freeze
        INFO_DELIMITER   = ';'.freeze

        MISSING_VALUE = '.'.freeze
        NO_SEQUENCE   = '-'.freeze
        TOO_LONG_SEQ  = '~'.freeze

        attr_accessor :reference

        def parse(line, header = nil)
          columns = line.split(COLUMN_DELIMITER).map(&:strip)

          raise FormatError, line unless columns.length == 9

          Row.new(header) do |r|
            r.seqid      = columns[0]
            r.source     = columns[1]
            r.type       = columns[2]
            r.start      = Integer(columns[3])
            r.end        = Integer(columns[4])
            r.score      = ((v = columns[5]).present? && v != MISSING_VALUE ? Float(v) : nil)
            r.strand     = ((v = columns[6]).present? && v != MISSING_VALUE ? v : nil)
            r.phase      = ((v = columns[7]).present? && v != MISSING_VALUE ? Integer(v) : nil)
            r.attributes = Attributes.parse(columns[8])
          end
        rescue => e
          raise FormatError, ["#{e.message}: #{line}", e.backtrace].join("\n")
        end
      end

      attr_reader :header

      def initialize(io = STDIN)
        @io     = io
        @header = {}
      end

      def each
        line_no = 0
        if block_given?
          line_no += process_header

          if @last_line
            yield self.class.parse(@last_line, @header)
          end

          while (line = @io.gets&.chomp)
            line_no += 1
            next if line.start_with?('#')

            begin
              yield self.class.parse(line, @header)
            rescue ActiveModel::ValidationError => e
              @logger ||= Logger.new(STDERR)
              @logger.warn("Failed to convert data due to validation error at line #{line_no}: #{line}")
            rescue => e
              @logger ||= Logger.new(STDERR)
              @logger.fatal(["#{e.message} at line #{line_no}: #{line}", e.backtrace].join("\n"))
            end
          end
        else
          to_enum
        end
      end

      private

      def process_header
        line_no = 0

        while (line = @io.gets)
          line_no += 1
          unless line.start_with?('#')
            @last_line = line.chomp
            break
          end

          line.chomp!
          key, value = line.sub(/^[# ]*/, '').split(' ', 2)
          if key && !(k = key.strip.sub(/:&/, '')).empty?
            @header[k] = value.freeze
          end
        end

        line_no
      end
    end
  end
end
