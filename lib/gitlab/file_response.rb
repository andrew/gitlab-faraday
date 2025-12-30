# frozen_string_literal: true

module Gitlab
  class FileResponse
    HEADER_CONTENT_DISPOSITION = 'content-disposition'

    attr_reader :filename

    def initialize(file)
      @file = file
    end

    def empty?
      false
    end

    def to_hash
      { filename: @filename, data: @file }
    end
    alias to_h to_hash

    def inspect
      "#<#{self.class}:#{object_id} {filename: #{filename.inspect}}>"
    end

    def method_missing(name, *, &)
      if @file.respond_to?(name)
        @file.send(name, *, &)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      super || @file.respond_to?(method_name, include_private)
    end

    def parse_headers!(headers)
      @filename = headers[HEADER_CONTENT_DISPOSITION].split('filename=')[1]
      @filename = @filename[1...-1] if @filename[0] == '"'
    end
  end
end
