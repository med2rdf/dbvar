require 'rdf'
require 'rdf/turtle'
require 'zlib'

module DbVar::RDF
  module Writer
    class Turtle
      class << self
        def open(path, compress: true)
          f = if compress
                Zlib::GzipWriter.open(path)
              else
                File.open(path, 'w')
              end

          writer = new(f)

          return writer unless block_given?

          begin
            yield writer
          ensure
            if f && !f.closed?
              f.close
            end
          end
        end
      end

      DEFAULT_OPTIONS = { prefixes: PREFIXES }

      def initialize(io = STDOUT, **options)
        @io = io
        @options = DEFAULT_OPTIONS.merge(options)

        yield self if block_given?
      end

      # @param  [RDF::Enumerable, RDF::Statement, #to_rdf] data
      # @return [Integer] the number of bytes written
      def <<(data)
        buffer = ::RDF::Turtle::Writer.buffer(@options) do |writer|
          writer << data
        end

        buffer.gsub!(/^@.*\n/, '')

        unless @header_written
          ::RDF::Turtle::Writer.new(@io, @options.merge(stream: true)).write_epilogue
          @header_written = true
        end

        @io.write buffer
      end
    end
  end
end
