# Ikura

A minimal Turbo Stream toy built on Ruby Wasm and raw TCP sockets — no Rails, no frontend framework, no external runtime dependencies.

Click anywhere on the gunkan-maki sushi in the browser to place ikura (salmon roe). Click handling runs entirely in Ruby via WebAssembly, and DOM updates are delivered as Turbo Streams. The server is built on Ruby's built-in `TCPServer`.

## Installation

```
gem install ikura
```

Or add to your Gemfile:

```
bundle add ikura
```

## Usage

Start the server:

```
ikura
```

Then open [http://localhost:8080](http://localhost:8080) in your browser.

To use a custom port:

```ruby
require "ikura"
Ikura::Server.start(port: 3000)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt.

To install this gem onto your local machine:

```
bundle exec rake install
```

To release a new version, update `lib/ikura/version.rb`, then run:

```
bundle exec rake release
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/haruna-tsujita/ikura.
