require 'active_model'
require 'active_support'
require 'active_support/inflector'

module DbVar::RDF
  module Models
    class VariantCall < Base
      def initialize(data)
        build_from_gvf(data) if data.is_a? Reader::GVF::Row

        yield self if block_given?
      end

      def to_rdf
        return @graph if @graph

        validate!

        subject = VARIANT_CALL_BASE / id
        @graph  = ::RDF::Graph.new do |g|
          g << [subject, ::RDF.type, DBVAR.VariantCall]
          g << [subject, ::RDF.type, var_class2so(variation_class)]
          g << [subject, ::RDF::Vocab::DC.identifier, id]
          g << [subject, OBO['RO_0002162'], TAXONOMY_BASE / 9606] # TODO
          if (v = alternative_allele)
            g << [subject, M2R.alternative_allele, v]
          end
          if (v = reference_allele)
            g << [subject, M2R.reference_allele, v]
          end
          if (v = zygosity)
            g << [subject, M2R.zygosity, v]
          end
          parents&.each do |x|
            if (m = x.match(/([en]sv\d+)/))
              g << [subject, ::RDF::Vocab::DC.isPartOf, VARIATION_BASE / m[1]]
            end
          end
          clinical_significance&.each do |x|
            g << [subject, M2R.clinical_significance, x]
          end
          phenotype_names&.each do |x|
            g << [subject, M2R.phenotype, x]
          end
        end

        if (v = allele_frequency)
          insert_frequency(subject, v)
        end
        if (v = allele_count)
          insert_allele_count(subject, v)
        end
        if (v = allele_number)
          insert_allele_total(subject, v)
        end

        insert_faldo(subject)

        cross_references&.each { |source, id| insert_cross_reference(subject, source, id) }
        phenotypes&.each { |source, id| insert_phenotype(subject, source, id) }

        @graph
      end
    end
  end
end
