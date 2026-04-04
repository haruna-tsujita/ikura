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

  def test_parse_request_post_with_body
    body = "coord=3"
    input = "POST /ikura HTTP/1.1\r\nContent-Length: #{body.bytesize}\r\n\r\n#{body}"
    io = StringIO.new(input)
    req = @server.send(:parse_request, io)

    assert_equal "POST", req[:method]
    assert_equal "/ikura", req[:path]
    assert_equal body, req[:body]
  end

  def test_parse_request_without_content_length_has_nil_body
    input = "POST /ikura HTTP/1.1\r\n\r\n"
    io = StringIO.new(input)
    req = @server.send(:parse_request, io)

    assert_nil req[:body]
  end

  # parse_form

  def test_parse_form_parses_coord
    result = @server.send(:parse_form, "coord=3")
    assert_equal "3", result["coord"]
  end

  def test_parse_form_empty_string
    result = @server.send(:parse_form, "")
    assert_equal({}, result)
  end

  def test_parse_form_nil
    result = @server.send(:parse_form, nil)
    assert_equal({}, result)
  end

  # respond

  def test_respond_writes_status_line
    out = StringIO.new
    @server.send(:respond, out, type: "text/plain", body: "hello")
    assert_match %r{HTTP/1.1 200 OK}, out.string
  end

  def test_respond_writes_content_type
    out = StringIO.new
    @server.send(:respond, out, type: "text/plain", body: "hello")
    assert_match %r{Content-Type: text/plain}, out.string
  end

  def test_respond_writes_content_length
    out = StringIO.new
    @server.send(:respond, out, type: "text/plain", body: "hello")
    assert_match %r{Content-Length: 5}, out.string
  end

  def test_respond_writes_cors_header
    out = StringIO.new
    @server.send(:respond, out, type: "text/plain", body: "hello")
    assert_match %r{Access-Control-Allow-Origin: \*}, out.string
  end

  def test_respond_custom_status
    out = StringIO.new
    @server.send(:respond, out, status: "404 Not Found", type: "text/plain", body: "nope")
    assert_match %r{HTTP/1.1 404 Not Found}, out.string
  end

  def test_respond_writes_body
    out = StringIO.new
    @server.send(:respond, out, type: "text/plain", body: "hello")
    assert_match "hello", out.string
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

  def test_handle_post_ikura_returns_turbo_stream
    out = StringIO.new(String.new(encoding: "UTF-8"))
    req = { method: "POST", path: "/ikura", headers: {}, body: "coord=0" }
    @server.send(:handle, out, req)

    assert_match %r{text/vnd.turbo-stream.html}, out.string
    assert_match %r{action="append"}, out.string
    assert_match %r{target="ikura-layer"}, out.string
  end

  def test_handle_post_ikura_increments_id
    out1 = StringIO.new(String.new(encoding: "UTF-8"))
    out2 = StringIO.new(String.new(encoding: "UTF-8"))
    req = { method: "POST", path: "/ikura", headers: {}, body: "coord=0" }
    @server.send(:handle, out1, req)
    @server.send(:handle, out2, req)

    assert_match %r{ikura_0}, out1.string
    assert_match %r{ikura_1}, out2.string
  end

  def test_handle_post_ikura_out_of_range_coord_falls_back
    out = StringIO.new(String.new(encoding: "UTF-8"))
    req = { method: "POST", path: "/ikura", headers: {}, body: "coord=999" }
    @server.send(:handle, out, req)

    assert_match %r{HTTP/1.1 200 OK}, out.string
    assert_match %r{action="append"}, out.string
  end
end
