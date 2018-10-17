lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dbvar/rdf/version'

Gem::Specification.new do |spec|
  spec.name    = 'dbvar-rdf'
  spec.version = DbVar::RDF::VERSION
  spec.authors = ['Daisuke Satoh', 'Shota Matsumoto']
  spec.email   = ['med2rdf@googlegroups.com']

  spec.description = 'RDF converter for dbVar'
  spec.summary     = spec.description
  spec.homepage    = 'http://med2rdf.org'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 2.5.0'

  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.files.reject! { |fn| fn.include? 'CVS' }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'yard'

  spec.add_dependency 'activesupport', '~> 5.2', '>= 5.2.1'
  spec.add_dependency 'activemodel', '~> 5.2', '>= 5.2.1'
  spec.add_dependency 'rdf', '~> 3.0', '>= 3.0.4'
  spec.add_dependency 'rdf-turtle', '~> 3.0', '>= 3.0.3'
  spec.add_dependency 'rdf-vocab', '~> 3.0', '>= 3.0.3'
  spec.add_dependency 'rdf-xsd', '~> 3.0', '>= 3.0.1'
end
