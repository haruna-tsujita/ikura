# frozen_string_literal: true

require_relative "lib/ikura/version"

Gem::Specification.new do |spec|
  spec.name = "ikura"
  spec.version = Ikura::VERSION
  spec.authors = ["haruna-tsujita"]
  spec.email = ["snwxxx29@gmail.com"]

  spec.summary = "A minimal Turbo Stream toy built on Ruby Wasm and raw TCP sockets."
  spec.description = "Ikura is a minimal Turbo Stream implementation built from scratch using Ruby Wasm and Ruby's built-in TCPServer — no Rails, no frontend framework, no external runtime dependencies. Click anywhere on the gunkan-maki sushi in the browser to place ikura (salmon roe); click events run in Ruby via WebAssembly and DOM updates arrive as Turbo Streams."
  spec.homepage = "https://github.com/haruna-tsujita/ikura"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 4.0.2"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/haruna-tsujita/ikura/tree/master"
  spec.metadata["changelog_uri"] = "https://github.com/haruna-tsujita/ikura/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
