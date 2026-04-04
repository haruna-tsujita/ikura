# frozen_string_literal: true

require "socket"
require "erb"

module Ikura
  class Server
    TEMPLATE_PATH = File.join(__dir__, "templates", "ikura.html.erb")

    def self.start(port: 8080)
      new(port:).run
    end

    def initialize(port: 8080)
      @port = port
    end

    def run
      server = TCPServer.new(@port)
      $stdout.sync = true
      puts "🍣  http://localhost:#{@port}"
      puts "    (Ctrl+C to stop)\n\n"

      loop do
        client = server.accept
        req = parse_request(client)
        next unless req

        puts "#{req[:method]} #{req[:path]}"
        handle(client, req)
        client.close
      rescue => e
        STDERR.puts "Error: #{e}"
        client&.close
      end
    end

    private

    def handle(client, req)
      case [req[:method], req[:path]]
      in ["GET", "/"]
        respond(client, type: "text/html; charset=utf-8", body: html_page)
      else
        respond(client, status: "404 Not Found", type: "text/plain", body: "Not found")
      end
    end

    def html_page
      ERB.new(File.read(TEMPLATE_PATH)).result(binding)
    end

    def parse_request(client)
      line = client.gets
      return nil unless line

      method, path, _ = line.split(" ")

      headers = {}
      while (l = client.gets) && l.chomp != ""
        key, val = l.split(": ", 2)
        headers[key.strip.downcase] = val&.strip
      end

      { method:, path:, headers: }
    end

    def respond(client, status: "200 OK", type:, body:)
      client.print "HTTP/1.1 #{status}\r\n"
      client.print "Content-Type: #{type}\r\n"
      client.print "Content-Length: #{body.bytesize}\r\n"
      client.print "Access-Control-Allow-Origin: *\r\n"
      client.print "Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS\r\n"
      client.print "Access-Control-Allow-Headers: Content-Type, Accept\r\n"
      client.print "Connection: close\r\n"
      client.print "\r\n"
      client.print body
    end
  end
end
