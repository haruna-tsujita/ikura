# frozen_string_literal: true

require "socket"
require "uri"
require "erb"

module Ikura
  class Server
    TEMPLATE_PATH = File.join(__dir__, "templates", "ikura.html.erb")

    def self.start(port: 8080)
      new(port:).run
    end

    IKURA_POINTS = [
      [50, 50], [35, 50], [65, 50], [20, 50], [80, 50],
      [50, 15], [35, 22], [65, 22], [20, 35], [80, 35],
      [50, 8], [42, 12], [58, 12], [28, 18], [72, 18],
      [12, 28], [88, 28], [50, 85], [35, 78], [65, 78],
      [20, 65], [80, 65], [10, 50], [90, 50], [72, 62],
      [50, 30], [50, 70], [28, 38], [72, 38], [28, 62],
    ].freeze

    def initialize(port: 8080)
      @port = port
      @ikura_count = 0
    end

    def run
      server = TCPServer.new(@port)
      $stdout.sync = true
      url = "http://localhost:#{@port}"
      puts "🍣  #{terminal_link(url)}"
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

    def terminal_link(url, label = url)
      return label unless $stdout.tty?

      "\e]8;;#{url}\a#{label}\e]8;;\a"
    end

    def handle(client, req)
      case [req[:method], req[:path]]
      in ["GET", "/"]
        respond(client, type: "text/html; charset=utf-8", body: html_page)
      in ["POST", "/ikura"]
        ikura_point_idx = parse_form(req[:body])["ikura_point"]&.to_i || 0
        x, y = IKURA_POINTS[ikura_point_idx] || [50, 50]
        id = @ikura_count
        @ikura_count += 1

        jx = (x + rand(-8..8)).clamp(5, 95)
        jy = (y + rand(-8..8)).clamp(5, 95)

        respond(client,
          type: "text/vnd.turbo-stream.html; charset=utf-8",
          body: Ikura::Builder.append("ikura-layer",
            "<li id='ikura_#{id}' class='ikura' style='left:#{jx}%;top:#{jy}%'></li>"))

        puts "  → append ikura_#{id} at (#{jx}%, #{jy}%)"
      else
        respond(client, status: "404 Not Found", type: "text/plain", body: "Not found")
      end
    end

    def html_page

      ikura_points_html = IKURA_POINTS.each_with_index.map { |(x, y), i|
        "<div class='ikura_point' style='left:#{x}%;top:#{y}%'></div>"
      }.join("\n")

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

      body = nil
      if (len = headers["content-length"]&.to_i)&.positive?
        body = client.read(len)
      end

      { method:, path:, headers:, body: }
    end

    def parse_form(body)
      URI.decode_www_form(body.to_s).to_h
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
