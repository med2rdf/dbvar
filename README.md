# DbVar::RDF

## Usage

- Input: dbVar GVF (Genome Variation Format)

  - GRCh37
    ftp://ftp.ncbi.nlm.nih.gov/pub/dbVar/data/Homo_sapiens/by_assembly/GRCh37/gvf/GRCh37.variant_call.gvf.gz
    ftp://ftp.ncbi.nlm.nih.gov/pub/dbVar/data/Homo_sapiens/by_assembly/GRCh37/gvf/GRCh37.variant_region.gvf.gz

  - GRCh38
    ftp://ftp.ncbi.nlm.nih.gov/pub/dbVar/data/Homo_sapiens/by_assembly/GRCh38/gvf/GRCh38.variant_call.gvf.gz
    ftp://ftp.ncbi.nlm.nih.gov/pub/dbVar/data/Homo_sapiens/by_assembly/GRCh38/gvf/GRCh38.variant_region.gvf.gz

- Output: Turtle formatted RDF

### With docker

```
$ docker build --tag dbvar-rdf .
$ zcat GRCh38.variant_call.gvf.gz | docker run --rm -i dbvar-rdf convert variant_call 2> dbVar.variant_call.GRCh38.log | gzip -c > dbVar.variant_call.GRCh38.ttl.gz
$ zcat GRCh38.variant_region.gvf.gz | docker run --rm -i dbvar-rdf convert variant_region 2> dbVar.variant_region.GRCh38.log | gzip -c > dbVar.variant_region.GRCh38.ttl.gz
```

### In your code

```ruby
require 'dbvar/rdf'

DbVar::RDF::Writer::Turtle.new do |writer| # to standard output
  DbVar::RDF::Reader::GVF.new.each do |data| # from standard input
    writer << data.to_rdf(DbVar::RDF::Models::VariantCall) # or DbVar::RDF::Models::VariantRegion
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/med2rdf/dbvar-rdf. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DbVar::RDF project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/med2rdf/dbvar-rdf/blob/master/CODE_OF_CONDUCT.md).
