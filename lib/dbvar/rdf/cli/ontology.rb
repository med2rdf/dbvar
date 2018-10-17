require 'optparse'

module DbVar::RDF
  module CLI
    class Ontology

      DEFAULT_OPTIONS = { help: false }.freeze

      def initialize
        @options = Hash[DEFAULT_OPTIONS]
      end

      def run
        option_parser.parse!

        if @options[:help]
          STDERR.puts option_parser.help
          exit 0
        end

        ontology = ::RDF::Turtle::Writer.buffer(prefixes: PREFIXES) do |writer|
          DBVAR.each_statement { |x| writer << x }
        end

        puts ontology

      rescue OptionParser::ParseError => e
        STDERR.puts e.message
        STDERR.puts
        STDERR.puts option_parser.help
        exit 1
      rescue StandardError => e
        STDERR.puts e.message
        STDERR.puts e.backtrace
        exit 99
      end

      private

      def option_parser
        OptionParser.new do |op|
          op.banner = "Usage: #{DbVar::RDF::CLI::PROG_NAME} #{self.class.name.demodulize.underscore} <src>\n"
          op.banner += "Convert dbVar data to RDF\n"

          op.separator("\nOptions:")
          op.on('-h', '--help', 'show help') do
            @options[:help] = true
          end

          op.separator('')
        end
      end
    end
  end
end
