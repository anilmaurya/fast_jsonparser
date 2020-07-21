# frozen_string_literal: true

require "fast_jsonparser/version"

module FastJsonparser
  Error = Class.new(StandardError)
  ParseError = Class.new(Error)
  UnknownError = Class.new(Error)
  BatchSizeTooSmall = Class.new(Error)

  DEFAULT_BATCH_SIZE = 1_000_000 # from include/simdjson/dom/parser.h

  class << self
    def parse(source, symbolize_names: true)
      _parse(source, symbolize_names)
    end

    def load(source, symbolize_names: true)
      _load(source, symbolize_names)
    end

    def load_many(source, symbolize_names: true, batch_size: DEFAULT_BATCH_SIZE, &block)
      _load_many(source, symbolize_names, batch_size, &block)
    rescue UnknownError => error
      case error.message
      when "This parser can't support a document that big"
        raise BatchSizeTooSmall, "One of the documents was bigger than the batch size (#{batch_size}B), try increasing it."
      else
        raise
      end
    end

    require "fast_jsonparser/fast_jsonparser" # loads cpp extension
    private :_parse, :_load, :_load_many
  end
end
