# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/ikura"

class TestBuilder < Minitest::Test
  def test_append_returns_turbo_stream_html
    result = Ikura::Builder.append("tasks", "<li>item</li>")
    assert_equal '<turbo-stream action="append" target="tasks"><template><li>item</li></template></turbo-stream>', result
  end

  def test_append_with_special_chars_in_content
    result = Ikura::Builder.append("list", '<li class="foo">a & b</li>')
    assert_includes result, '<li class="foo">a & b</li>'
  end

  def test_append_target_is_set_correctly
    result = Ikura::Builder.append("ikura-layer", "x")
    assert_match %r{target="ikura-layer"}, result
  end

  def test_append_action_is_append
    result = Ikura::Builder.append("x", "y")
    assert_match %r{action="append"}, result
  end
end
