FROM ruby:2.5

ADD . /dbvar-rdf/

COPY docker-entrypoint.sh /

WORKDIR /dbvar-rdf

RUN rm -rf .bundle && \
    bundle install

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dbvar-rdf", "--help"]
