# frozen_string_literal: true

module Gitlab
  module Error
    class Error < StandardError; end

    class MissingCredentials < Error; end

    class Parsing < Error; end

    class ResponseError < Error
      POSSIBLE_MESSAGE_KEYS = %i[message error_description error].freeze

      def initialize(response)
        @response = response
        super(build_error_message)
      end

      def response_status
        @response.status
      end

      def response_message
        parsed = parsed_response
        parsed.respond_to?(:message) ? parsed.message : parsed.to_s
      end

      def error_code
        ''
      end

      def build_error_message
        parsed = parsed_response
        message = check_error_keys(parsed)
        "Server responded with code #{@response.status}, message: " \
          "#{handle_message(message)}. " \
          "Request URI: #{@response.env.url}"
      end

      def check_error_keys(resp)
        return resp unless resp.is_a?(Gitlab::ObjectifiedHash)

        key = POSSIBLE_MESSAGE_KEYS.find { |k| resp.respond_to?(k) }
        key ? resp.send(key) : resp
      end

      def parsed_response
        return @parsed_response if defined?(@parsed_response)

        body = @response.body
        return {} if body.nil? || body.empty?

        parsed = JSON.parse(body)
        @parsed_response = if parsed.is_a?(Hash)
                             Gitlab::ObjectifiedHash.new(parsed)
                           else
                             parsed
                           end
      rescue JSON::ParserError
        @parsed_response = @response.body
      end

      def handle_message(message)
        case message
        when Gitlab::ObjectifiedHash
          message.to_h.sort.map do |key, val|
            "'#{key}' #{(val.is_a?(Hash) ? val.sort.map { |k, v| "(#{k}: #{v.join(' ')})" } : [val].flatten).join(' ')}"
          end.join(', ')
        when Array
          message.join(' ')
        else
          message
        end
      end
    end

    class BadRequest < ResponseError; end
    class Unauthorized < ResponseError; end
    class Forbidden < ResponseError; end
    class NotFound < ResponseError; end
    class MethodNotAllowed < ResponseError; end
    class NotAcceptable < ResponseError; end
    class Conflict < ResponseError; end
    class Unprocessable < ResponseError; end
    class TooManyRequests < ResponseError; end
    class InternalServerError < ResponseError; end
    class BadGateway < ResponseError; end
    class ServiceUnavailable < ResponseError; end
    class ConnectionTimedOut < ResponseError; end

    STATUS_MAPPINGS = {
      400 => BadRequest,
      401 => Unauthorized,
      403 => Forbidden,
      404 => NotFound,
      405 => MethodNotAllowed,
      406 => NotAcceptable,
      409 => Conflict,
      422 => Unprocessable,
      429 => TooManyRequests,
      500 => InternalServerError,
      502 => BadGateway,
      503 => ServiceUnavailable,
      522 => ConnectionTimedOut
    }.freeze

    def self.klass(response)
      error_klass = STATUS_MAPPINGS[response.status]
      return error_klass if error_klass

      ResponseError if response.status >= 400
    end
  end
end
