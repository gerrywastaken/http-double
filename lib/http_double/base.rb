require 'sinatra/base'

module HttpDouble
  class Base < Sinatra::Base

    class << self

      def background(addr, port, log_path: '/dev/null', logger: nil)
        server_class = self
        thread = Thread.new do

          # Even if we use /dev/null, we need a logger to suppress warnings
          # generated by Thin::Logging#trace_logger being undefined
          log_stream = File.open(log_path, 'a')
          Thin::Logging.trace_logger = logger || Logger.new(log_stream)

          Thin::Server.start(addr, port) do
            use RequestLogger, server_class.log
            run server_class
          end

        end
        thread.abort_on_exception = true
        thread
      end

      def log
        @log ||= []
      end

    end

    not_found { [404, ''] }

  end
end
