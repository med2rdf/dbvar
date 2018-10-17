require 'active_support'
require 'active_support/concern'
require 'active_support/core_ext/hash'
require 'yaml'

module DbVar::RDF
  require 'dbvar/rdf/vocabularies'

  module Helpers
    module Mappings
      extend ActiveSupport::Concern

      # @param [String] refseq refseq accession (e.g. NC_000001.11)
      # @param [String] assembly needed if the refseq accession is associated with some assemblies [GRCh37|GRCh38]
      # @return [RDF::URI]
      def refseq2hco(refseq, assembly = nil)
        hco = mappings[:chromosome][refseq]

        return nil if hco.nil?

        return HCO[hco] unless hco.is_a?(Array)

        raise('assembly should not be nil') unless assembly

        hco = hco.select { |x| x.end_with?(assembly) }

        raise('cannot assign a unique hco') unless hco.length == 1

        HCO[hco.first]
      end

      # @param [String] var_class
      # @return [RDF::URI]
      def var_class2so(var_class)
        so = mappings[:variant_class][var_class]
        OBO[so] if so
      end

      private

      def mappings
        @mappings ||= YAML.load_file(File.expand_path('../mappings.yml', __FILE__)).symbolize_keys
      end
    end
  end
end
