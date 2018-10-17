require 'dbvar/rdf/version'

module DbVar
  module RDF
    require 'dbvar/rdf/vocabularies'

    ROOT_DIR = File.expand_path('../../', File.dirname(__FILE__)).freeze

    module CLI
      autoload :Convert, 'dbvar/rdf/cli/convert'
      autoload :Ontology, 'dbvar/rdf/cli/ontology'
      autoload :Runner, 'dbvar/rdf/cli/runner'
    end

    module Helpers
      autoload :Mappings, 'dbvar/rdf/helpers/mappings'
    end

    module Models
      autoload :Base, 'dbvar/rdf/models/base'
      autoload :VariantCall, 'dbvar/rdf/models/variant_call'
      autoload :VariantRegion, 'dbvar/rdf/models/variant_region'
    end

    module Reader
      autoload :GVF, 'dbvar/rdf/reader/gvf'
    end

    module Writer
      autoload :Turtle, 'dbvar/rdf/writer/turtle'
    end
  end
end


