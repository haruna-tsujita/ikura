# frozen_string_literal: true

require_relative "lib/ikura/version"

Gem::Specification.new do |spec|
  spec.name = "ikura"
  spec.version = Ikura::VERSION
  spec.authors = ["haruna-tsujita"]
  spec.email = ["snwxxx29@gmail.com"]

  spec.summary = "An interactive gunkan-maki sushi toy server powered by Ruby Wasm"
  spec.description = "Ikura is a tiny HTTP server that renders an interactive gunkan-maki sushi in the browser. Click anywhere on the sushi to place ikura (salmon roe) using Ruby running in WebAssembly."
  spec.homepage = "https://github.com/haruna-tsujita/ikura"
  spec.required_ruby_version = ">= 4.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/haruna-tsujita/ikura"
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
