require 'rdf'
require 'rdf/vocab'

module DbVar::RDF
  PREFIXES = {
    owl:       ::RDF::OWL.to_s,
    dc:        ::RDF::Vocab::DC.to_s,
    rdfs:      ::RDF::Vocab::RDFS.to_s,
    xsd:       ::RDF::Vocab::XSD.to_s,
    dbvar:     'http://purl.jp/bio/10/dbvar/',
    dbvarv:    'http://med2rdf.org/dbvar/variation/',
    dbvarvc:   'http://med2rdf.org/dbvar/variant_call/',
    m2r:       'http://med2rdf.org/ontology/med2rdf#',
    clinvar:   'http://identifiers.org/clinvar.submission/',
    dbsnp:     'http://identifiers.org/dbsnp/',
    doid:      'http://identifiers.org/doid/',
    faldo:     'http://biohackathon.org/resource/faldo#',
    genbank:   'http://identifiers.org/insdc/',
    hco:       'http://identifiers.org/hco/',
    insdc:     'http://identifiers.org/insdc/',
    medgen:    'http://identifiers.org/medgen/',
    mesh:      'http://identifiers.org/mesh/',
    ncbi_gene: 'http://identifiers.org/ncbigene/',
    obo:       'http://purl.obolibrary.org/obo/',
    omim:      'http://identifiers.org/mim/',
    ordo:      'http://identifiers.org/orphanet/',
    pubmed:    'http://identifiers.org/pubmed/',
    refseq:    'http://identifiers.org/refseq/',
    sio:       'http://semanticscience.org/resource/',
    tax:       'http://identifiers.org/taxonomy/',
    hp:        'http://identifiers.org/hp/',
  }.freeze

  FALDO = RDF::Vocabulary.new(PREFIXES[:faldo])
  HCO   = RDF::Vocabulary.new(PREFIXES[:hco])
  M2R   = RDF::Vocabulary.new(PREFIXES[:m2r])
  OBO   = RDF::Vocabulary.new(PREFIXES[:obo])
  SIO   = RDF::Vocabulary.new(PREFIXES[:sio])

  class DBVAR < RDF::StrictVocabulary(PREFIXES[:dbvar])

    # Ontology definition
    ontology to_uri.freeze,
             type:             ::RDF::OWL.Ontology,
             :'dc:title'       => 'dbVar Ontology',
             :'dc:description' => 'dbVar Ontology describes classes and properties which is used in dbVar RDF',
             :'owl:imports'    => [::RDF::Vocab::DC.to_s,
                                   FALDO.to_s,
                                   OBO.to_s,
                                   M2R.to_s].freeze

    # Class definitions
    term :VariantCall,
         type:        ::RDF::OWL.Class,
         subClassOf:  M2R.Variation.freeze,
         isDefinedBy: to_s.freeze,
         label:       'VariantCall'.freeze

    term :Frequency,
         type:        ::RDF::OWL.Class,
         isDefinedBy: to_s.freeze,
         label:       'Frequency'.freeze

    term :AlleleCount,
         type:        ::RDF::OWL.Class,
         isDefinedBy: to_s.freeze,
         label:       'AlleleCount'.freeze

    term :AlleleTotal,
         type:        ::RDF::OWL.Class,
         isDefinedBy: to_s.freeze,
         label:       'AlleleTotal'.freeze

    # Property definitions
    property(:clinical_significance,
             type:        ::RDF::OWL.DatatypeProperty,
             label:       'clinical_significance'.freeze,
             domain:      M2R.Variation,
             isDefinedBy: to_s.freeze,
             range:       ::RDF::XSD.string
    )

    property(:phenotype,
             type:        ::RDF::OWL.DatatypeProperty,
             label:       'phenotype'.freeze,
             isDefinedBy: to_s.freeze,
             domain:      M2R.Variation,
             range:       ::RDF::XSD.string,
    )

    property(:zygosity,
             type:        ::RDF::OWL.DatatypeProperty,
             label:       'zygosity'.freeze,
             isDefinedBy: to_s.freeze,
             domain:      M2R.Variation,
             range:       ::RDF::XSD.string,
             comment:     'The zygosity of this locus where zygosity is heterozygous, homozygous or hemizygous.'
    )
  end
end
