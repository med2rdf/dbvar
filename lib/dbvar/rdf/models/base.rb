require 'active_model'
require 'active_support'
require 'active_support/inflector'

module DbVar::RDF
  module Models
    class Base
      include ActiveModel::Model
      include Helpers::Mappings

      # # List of items
      # - GRCh37
      # - GRCh38
      # @return [String]
      attr_accessor :reference

      # The chromosome or contig on which the sequence_alteration is located
      # # List of items
      # - CM\d{6}\.\d+
      # - GL\d{6}\.\d+
      # - JH\d{6}\.\d+
      # - KI\d{6}\.\d+
      # - NC_\d{6}\.\d+
      # - NT_\d{6}\.\d+
      # - NW_\d{9}\.\d+
      # @return [String]
      attr_accessor :chromosome

      # An SO term describing the type of sequence_alteration, no_sequence_alteration, or a gap.
      # # List of items
      # - Alu_deletion
      # - Alu_insertion
      # - complex_chromosomal_rearrangement
      # - complex_substitution
      # - copy_number_gain
      # - copy_number_loss
      # - copy_number_variation
      # - deletion
      # - duplication
      # - HERV_deletion
      # - indel
      # - insertion
      # - interchromosomal_translocation
      # - intrachromosomal_translocation
      # - inversion
      # - LINE1_deletion
      # - LINE1_insertion
      # - mobile_element_deletion
      # - mobile_element_insertion
      # - novel_sequence_insertion
      # - sequence_alteration
      # - short_tandem_repeat_variation
      # - SVA_deletion
      # - SVA_insertion
      # - tandem_duplication
      # - translocation
      # @return [String]
      attr_accessor :variation_class

      # A 1-based integer for the begining of the sequence_alteration locus on the plus strand
      # @return [Integer]
      attr_accessor :start

      # A 1-based integer of the end of the sequence_alteration on plus strand
      # @return [Integer]
      attr_accessor :end

      # An ID for variant call
      # @return [String]
      attr_accessor :id

      # Link(s) to external database(s)
      # List of keys
      # - URL
      # - ClinVar: SCV\d+ -> identifiers.org/clinvar.submission
      # - PubMed: \d+ -> identifiers.org/pubmed
      # - OMIM: \d+ -> identifiers.org/mim
      # - GENBANK: ((AC|AP|NC|NG|NM|NP|NR|NT|NW|XM|XP|XR|YP|ZP)_\d+|(NZ\_[A-Z]{4}\d+))(\.\d+)? -> identifiers.org/refseq
      #            ([A-Z]\d{5}|[A-Z]{2}\d{6}|[A-Z]{4}\d{8}|[A-J][A-Z]{2}\d{5})(\.\d+)? -> identifiers.org/insdc
      # - TRACE: TEMPLATE_ID=[A-Z0-9]+ -> https://www.ncbi.nlm.nih.gov/Traces/trace.cgi?cmd=retrieve&val=TEMPLATE_ID=%27{TEMPLATE_ID}%27
      # - CLONE -> will be retried in Jan 2019
      # - dbSNP: rs\d+ -> identifiers.org/dbsnp
      # - ClinGen: [A-Z]+-\d+ -> https://www.ncbi.nlm.nih.gov/projects/dbvar/clingen/clingen_region.cgi?id={ClinGen}
      # - GENE: [A-Za-z-0-9_]+ -> https://www.ncbi.nlm.nih.gov/sites/entrez?Db=gene&Cmd=DetailsSearch&Term={GENE}[sym]+AND+txid9606[orgn]
      # - GeneReviews: NBK\d+ -> https://www.ncbi.nlm.nih.gov/books/NBK65707
      # - dbVar: [en]sv\d+ -> DbVar::RDF::Models::Base::VARIATION_BASE / {dbVar}
      # @return [Array<Array<String>>, nil] an array of string pair(database name and ID)
      attr_accessor :cross_references

      # An array of alternative allele
      # @return [Array<String>, nil]
      attr_accessor :alternative_allele

      # Reference allele
      # @return [String]
      attr_accessor :reference_allele

      # @return [Array<Integer>, nil] two integers (or a '.' for unknown values) separated by a comma
      #   The first value defines a range of ambiguity less-than the value given in `start` and must be less-than or
      #   equal-to that coordinate (or '.').
      #   The second value defines a range of ambiguity greater-than the coordinate specified in `start` and must be
      #   greater-than or equal-to the value of that coordinate (or '.').
      attr_accessor :start_range

      # @return [Array<Integer>, nil] two integers (or a '.' for unknown values) separated by a comma
      attr_accessor :end_range

      # # List of items
      # - heterozygous
      # - homozygous
      # - hemizygous
      # @return [String, nil]
      attr_accessor :zygosity

      # =============================
      #  Special attributes in dbVar
      # =============================

      # An ID for parent variant region
      # @return [Array<String>, nil]
      attr_accessor :parents

      # Clinical significance for this single variant
      # @return [Array<String>, nil]
      attr_accessor :clinical_significance

      # @return [Array<String>, nil]
      attr_accessor :phenotype_names

      # Phenotype(s) thought to associated with this call. NOT for clinical assertions (submit to ClinVar). (free text, enclose in double quotes)
      # List of keys
      # MeSH: [CD]\d{6} -> identifiers.org/mesh
      # HP: \d{7} -> identifiers.org/hp
      # MedGen: [CN]*\d{4,7} -> identifiers.org/medgen
      # Orphanet: Orphanet[_:]C?\d+ -> identifiers.org/orphanet.ordo
      # OMIM: \d+ -> identifiers.org/mim
      # DO: \d+ -> identifiers.org/doid (remember to add prefix DOID:)
      # MONDO: \d+ -> http://purl.obolibrary.org/obo/MONDO_{MONDO}
      # @return [Array<String>, nil]
      attr_accessor :phenotypes

      # Confidence interval around `start` for imprecise variants
      # @return [Array<Integer>, nil] two integers (or a '.' for unknown values) separated by a comma
      attr_accessor :cipos

      # Confidence interval around `end` for imprecise variants
      # @return [Array<Integer>, nil] two integers (or a '.' for unknown values) separated by a comma
      attr_accessor :ciend

      # @return [Integer, nil]
      attr_accessor :allele_count

      # @return [Integer, nil]
      attr_accessor :allele_number

      # @return [Float, nil]
      attr_accessor :allele_frequency

      validates :chromosome, :variation_class, :start, :end, :id, presence: true

      DBVAR_BASE        = ::RDF::URI.new(PREFIXES[:dbvar]).freeze
      VARIATION_BASE    = ::RDF::URI.new(PREFIXES[:dbvarv]).freeze
      VARIANT_CALL_BASE = ::RDF::URI.new(PREFIXES[:dbvarvc]).freeze

      CLINVAR_BASE  = ::RDF::URI.new(PREFIXES[:clinvar]).freeze
      DBSNP_BASE    = ::RDF::URI.new(PREFIXES[:dbsnp]).freeze
      GENBANK_BASE  = ::RDF::URI.new(PREFIXES[:genbank]).freeze
      GENE_BASE     = ::RDF::URI.new(PREFIXES[:ncbi_gene]).freeze
      INSDC_BASE    = ::RDF::URI.new(PREFIXES[:insdc]).freeze
      OMIM_BASE     = ::RDF::URI.new(PREFIXES[:omim]).freeze
      PUBMED_BASE   = ::RDF::URI.new(PREFIXES[:pubmed]).freeze
      REFSEQ_BASE   = ::RDF::URI.new(PREFIXES[:refseq]).freeze
      TAXONOMY_BASE = ::RDF::URI.new(PREFIXES[:tax]).freeze

      MESH_BASE   = ::RDF::URI.new(PREFIXES[:mesh]).freeze
      HP_BASE     = ::RDF::URI.new(PREFIXES[:hp]).freeze
      MEDGEN_BASE = ::RDF::URI.new(PREFIXES[:medgen]).freeze
      ORDO_BASE   = ::RDF::URI.new(PREFIXES[:ordo]).freeze
      DOID_BASE   = ::RDF::URI.new(PREFIXES[:doid]).freeze
      OBO_BASE    = ::RDF::URI.new(PREFIXES[:obo]).freeze

      TRACE_TEMPLATE       = 'https://www.ncbi.nlm.nih.gov/Traces/trace.cgi?cmd=retrieve&val=TEMPLATE_ID=%%27%s%%27'.freeze
      CLINGEN_TEMPLATE     = 'https://www.ncbi.nlm.nih.gov/projects/dbvar/clingen/clingen_region.cgi?id=%s'.freeze
      GENE_TEMPLATE        = 'https://www.ncbi.nlm.nih.gov/sites/entrez?Db=gene&Cmd=DetailsSearch&Term=%s[sym]+AND+txid9606[orgn]'.freeze
      GENEREVIEWS_TEMPLATE = 'https://www.ncbi.nlm.nih.gov/books/%s'.freeze

      UNKNOWN_VALUES = '.'.freeze

      def initialize(data)
        build_from_gvf(data) if data.is_a? Reader::GVF::ROW

        yield self if block_given?
      end

      private

      # @param [DbVar::RDF::Reader::GVF::ROW] row
      def build_from_gvf(row)
        @reference = row.header['genome-build'].match(/(GRCh\d+)/)&.[](1)
        @reference ||= row.header['assembly-name'].match(/(GRCh\d+)/)&.[](1)

        @chromosome      = row.seqid
        @variation_class = row.type
        @start           = row.start
        @end             = row.end

        @id                 = row.attributes[:Name]&.at(0)
        @cross_references   = row.attributes[:Dbxref]&.map { |x| x.split(':', 2) }
        @alternative_allele = row.attributes[:Variant_seq]&.at(0)
        @reference_allele   = row.attributes[:Reference_seq]&.at(0)
        @start_range        = row.attributes[:Start_range]&.map { |x| x == UNKNOWN_VALUES ? nil : Integer(x) }
        @end_range          = row.attributes[:End_range]&.map { |x| x == UNKNOWN_VALUES ? nil : Integer(x) }
        @zygosity           = (v = row.attributes[:Zygosity]&.at(0)) == UNKNOWN_VALUES ? nil : v

        @parents               = row.attributes[:parent]
        @clinical_significance = row.attributes[:clinical_int]
        @phenotype_names       = row.attributes[:phenotype]
        @phenotypes            = row.attributes[:phenotype_id]&.map { |x| x.split(':', 2) }
        @cipos                 = row.attributes[:cipos]&.map { |x| Integer(x) }
        @ciend                 = row.attributes[:ciend]&.map { |x| Integer(x) }
        @allele_count          = ((v = row.attributes[:allele_count]&.at(0)).present? ? Integer(v) : nil)
        @allele_number         = ((v = row.attributes[:allele_number]&.at(0)).present? ? Integer(v) : nil)
        @allele_frequency      = ((v = row.attributes[:allele_frequency]&.at(0)).present? ? Float(v) : nil)
      end

      def insert_cross_reference(subject, source, id)
        return if source == 'URL'

        if source == 'ClinVar' && (m = id.match(/(SCV\d+)/))
          @graph << [subject, ::RDF::Vocab::RDFS.seeAlso, CLINVAR_BASE / m[1]]
        elsif source == 'PubMed' && (m = id.match(/(\d+)/))
          @graph << [subject, ::RDF::Vocab::RDFS.seeAlso, PUBMED_BASE / m[1]]
        elsif source == 'OMIM' && (m = id.match(/(\d+)/))
          @graph << [subject, ::RDF::Vocab::RDFS.seeAlso, OMIM_BASE / m[1]]
        elsif source == 'GENBANK' && (m = id.match(/(((AC|AP|NC|NG|NM|NP|NR|NT|NW|XM|XP|XR|YP|ZP)_\d+|(NZ\_[A-Z]{4}\d+))(\.\d+)?)/))
          @graph << [subject, ::RDF::Vocab::RDFS.seeAlso, REFSEQ_BASE / m[1]]
        elsif source == 'GENBANK' && (m = id.match(/(([A-Z]\d{5}|[A-Z]{2}\d{6}|[A-Z]{4}\d{8}|[A-J][A-Z]{2}\d{5})(\.\d+)?)/))
          @graph << [subject, ::RDF::Vocab::RDFS.seeAlso, GENBANK_BASE / m[1]]
        elsif source == 'TRACE' && (m = id.match(/TEMPLATE_ID=([A-Z0-9]+)/))
          @graph << [subject, ::RDF::Vocab::RDFS.seeAlso, ::RDF::URI.new(TRACE_TEMPLATE % m[1])]
        elsif source == 'dbSNP' && (m = id.match(/(rs\d+)/))
          @graph << [subject, ::RDF::Vocab::RDFS.seeAlso, DBSNP_BASE / m[1]]
        elsif source == 'ClinGen' && (m = id.match(/([A-Z]+-\d+)/))
          @graph << [subject, ::RDF::Vocab::RDFS.seeAlso, ::RDF::URI.new(CLINGEN_TEMPLATE % m[1])]
        elsif source == 'GENE' && (m = id.match(/([A-Za-z0-9\-_]+)/))
          @graph << [subject, ::RDF::Vocab::RDFS.seeAlso, ::RDF::URI.new(GENE_TEMPLATE % m[1])]
        elsif source == 'GeneReviews' && (m = id.match(/(NBK\d+)/))
          @graph << [subject, ::RDF::Vocab::RDFS.seeAlso, ::RDF::URI.new(GENEREVIEWS_TEMPLATE % m[1])]
        elsif source == 'dbVar' && (m = id.match(/([en]sv\d+)/))
          @graph << [subject, ::RDF::Vocab::RDFS.seeAlso, VARIATION_BASE / m[1]]
        end
      end

      def insert_phenotype(subject, source, id)
        if source == 'MeSH' && (m = id.match(/([CD]\d{6})$/))
          @graph << [subject, M2R.disease, MESH_BASE / m[1]]
        elsif source == 'HP' && (m = id.match(/(\d{7})$/))
          @graph << [subject, M2R.disease, HP_BASE / m[1]]
        elsif source == 'MedGen' && (m = id.match(/([CN]*\d{4,7})$/))
          @graph << [subject, M2R.disease, MEDGEN_BASE / m[1]]
        elsif source == 'Orphanet' && (m = id.match(/(Orphanet[_:]C?\d+)/))
          @graph << [subject, M2R.disease, ORDO_BASE / m[1]]
        elsif source == 'OMIM' && (m = id.match(/(\d+)/))
          @graph << [subject, M2R.disease, OMIM_BASE / m[1]]
        elsif source == 'DO' && (m = id.match(/(\d+)/))
          @graph << [subject, M2R.disease, DOID_BASE + 'DOID:' + m[1]]
        elsif source == 'MONDO' && (m = id.match(/(\d+)/))
          @graph << [subject, M2R.disease, OBO_BASE / "MONDO_#{m[1]}"]
        end
      end

      def insert_faldo(parent_subject)
        @graph ||= ::RDF::Graph.new

        loc = parent_subject / 'position' / reference / chromosome
        @graph << [parent_subject, FALDO.location, loc]
        @graph << [loc, ::RDF.type, FALDO.Region]

        insert_faldo_begin(loc)
        insert_faldo_end(loc)
      end

      def insert_faldo_begin(parent_subject)
        pos = parent_subject / 'begin'
        @graph << [parent_subject, FALDO.begin, pos]

        # TODO: simplify
        if start_range
          @graph << [pos, ::RDF.type, FALDO.FuzzyPosition]
          if start_range[0]
            b = pos / '#begin'
            @graph << [pos, FALDO.begin, b]
            insert_exact_position(b, start_range[0])
          end
          if start_range[1]
            b = pos / '#end'
            @graph << [pos, FALDO.end, b]
            insert_exact_position(b, start_range[1])
          end
        elsif cipos
          if (offset = cipos[0])
            b = pos / '#begin'
            @graph << [pos, FALDO.begin, b]
            insert_exact_position(b, start + offset)
          end
          if (offset = cipos[1])
            b = pos / '#end'
            @graph << [pos, FALDO.end, b]
            insert_exact_position(b, start + offset)
          end
        else
          insert_exact_position(pos, start)
        end

        if (hco = refseq2hco(chromosome, reference))
          @graph << [pos, FALDO.reference, hco]
          @graph << [pos, FALDO.reference, REFSEQ_BASE / chromosome]
        else
          @graph << [pos, FALDO.reference, INSDC_BASE / chromosome]
        end
      end

      def insert_faldo_end(parent_subject)
        pos = parent_subject / 'end'
        @graph << [parent_subject, FALDO.end, pos]

        # TODO: simplify
        if end_range
          @graph << [pos, ::RDF.type, FALDO.FuzzyPosition]
          if end_range[0]
            b = pos / '#begin'
            @graph << [pos, FALDO.begin, b]
            insert_exact_position(b, end_range[0])
          end
          if end_range[1]
            b = pos / '#end'
            @graph << [pos, FALDO.end, b]
            insert_exact_position(b, end_range[1])
          end
        elsif ciend
          if (offset = ciend[0])
            b = pos / '#begin'
            @graph << [pos, FALDO.begin, b]
            insert_exact_position(b, self.end + offset)
          end
          if (offset = ciend[1])
            b = pos / '#end'
            @graph << [pos, FALDO.end, b]
            insert_exact_position(b, self.end + offset)
          end
        else
          insert_exact_position(pos, self.end)
        end

        if (hco = refseq2hco(chromosome, reference))
          @graph << [pos, FALDO.reference, hco]
          @graph << [pos, FALDO.reference, REFSEQ_BASE / chromosome]
        else
          @graph << [pos, FALDO.reference, INSDC_BASE / chromosome]
        end
      end

      def insert_exact_position(subject, position)
        @graph << [subject, ::RDF.type, FALDO.ExactPosition]
        @graph << [subject, FALDO.position, position]
      end

      def insert_frequency(subject, freq)
        frequency = subject / 'frequency'
        @graph << [subject, SIO['SIO_000216'], frequency]
        @graph << [frequency, ::RDF.type, DBVAR.Frequency]
        @graph << [frequency, ::RDF.value, freq]
      end

      def insert_allele_count(subject, freq)
        allele_count = subject / 'allele_count'
        @graph << [subject, SIO['SIO_000216'], allele_count]
        @graph << [allele_count, ::RDF.type, DBVAR.AlleleCount]
        @graph << [allele_count, ::RDF.value, freq]
      end

      def insert_allele_total(subject, freq)
        allele_total = subject / 'allele_total'
        @graph << [subject, SIO['SIO_000216'], allele_total]
        @graph << [allele_total, ::RDF.type, DBVAR.AlleleTotal]
        @graph << [allele_total, ::RDF.value, freq]
      end
    end
  end
end
