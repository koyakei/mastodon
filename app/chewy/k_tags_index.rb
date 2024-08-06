# frozen_string_literal: true

class KTagsIndex < Chewy::Index
  include DatetimeClampingConcern

  settings index: index_preset(refresh_interval: '30s'), analysis: {
    analyzer: {
      content: {
        tokenizer: 'keyword',
        filter: %w(
          word_delimiter_graph
          lowercase
          asciifolding
          cjk_width
        ),
      },

      edge_ngram: {
        tokenizer: 'edge_ngram',
        filter: %w(
          lowercase
          asciifolding
          cjk_width
        ),
      },
    },

    tokenizer: {
      edge_ngram: {
        type: 'edge_ngram',
        min_gram: 2,
        max_gram: 15,
      },
    },
  }

  index_scope KTag


  field :name

  
end