# frozen_string_literal: true

require "minitest/autorun"
require "stringio"
require_relative "../lib/ikura"

class TestServer < Minitest::Test
  def setup
    @server = Ikura::Server.new
  end

  # parse_request

  def test_parse_request_get_root
    input = "GET / HTTP/1.1\r\nHost: localhost\r\n\r\n"
    io = StringIO.new(input)
    req = @server.send(:parse_request, io)

    assert_equal "GET", req[:method]
    assert_equal "/", req[:path]
    assert_equal "localhost", req[:headers]["host"]
  end

  def test_parse_request_returns_nil_on_empty
    io = StringIO.new("")
    assert_nil @server.send(:parse_request, io)
  end

  # handle

  def test_handle_get_root_returns_html
    out = StringIO.new(String.new(encoding: "UTF-8"))
    req = { method: "GET", path: "/", headers: {} }
    @server.send(:handle, out, req)

    assert_match %r{HTTP/1.1 200 OK}, out.string
    assert_match %r{Content-Type: text/html}, out.string
  end

  def test_handle_unknown_path_returns_404
    out = StringIO.new(String.new(encoding: "UTF-8"))
    req = { method: "GET", path: "/notfound", headers: {} }
    @server.send(:handle, out, req)

    assert_match %r{HTTP/1.1 404 Not Found}, out.string
  end
end
