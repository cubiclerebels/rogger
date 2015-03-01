# Rogger

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rogger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rogger

## Usage

To get started

```bash
$ rails g rogger:config
```

## Disable application-level logging

To disallow Rogger from logging Rails application level messages, in your
generated config/rogger.yml, set

```
  app_logging: false
```

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rogger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
