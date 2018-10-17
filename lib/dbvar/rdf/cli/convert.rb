require 'active_support'
require 'active_support/inflector'
require 'optparse'

module DbVar::RDF
  module CLI
    class Convert

      DEFAULT_OPTIONS = { help:  false }.freeze

      def initialize
        @options = Hash[DEFAULT_OPTIONS]
      end

      def run
        @args = option_parser.parse(ARGV)

        if @options[:help]
          STDERR.puts option_parser.help
          exit 0
        end

        @model = "DbVar::RDF::Models::#{@args.first.camelize}".safe_constantize

        unless valid?
          STDERR.puts option_parser.help
          exit 1
        end

        Writer::Turtle.new do |writer|
          Reader::GVF.new.each { |data| writer << data.to_rdf(@model) }
        end
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
          op.banner = "Usage: #{DbVar::RDF::CLI::PROG_NAME} #{self.class.name.demodulize.underscore} <model>\n"
          op.banner += "Convert dbVar data to RDF\n"
          op.banner += "\nArguments:\n"
          op.banner += "    model: <variant_region|variant_call>\n"

          op.separator("\nOptions:")
          op.on('-h', '--help', 'show help') do
            @options[:help] = true
          end

          op.separator('')
        end
      end

      def valid?
        return false unless @args.length == 1

        return false unless @model

        true
      end
    end
  end
end
