# Rogger

The easiest way to log your Rails apps to Graylog2!

- TCP support with siawyoung's fork of `gelf-rb`
- Highly recommened to be used in conjunction with Lograge
  - Allows you to log many other things (Rack, params, sessions, etc.)

## Installation

Add this line to your application's Gemfile:

```ruby
source 'https://repo.fury.io/davidchua/' do
  gem 'rogger'
end
```

And then execute:

    $ bundle

## Usage

To get started, run the generator:

```bash
$ rails g rogger:config
```

This generates two files; `config/initializers/rogger.rb` and the config file `config/rogger.yml`.

### Graylog server details

In `config/rogger.yml`, change:

- `host` to your Graylog2 server hostname or IP address
- `port` to the port of the Graylog2 input
- `app_name` to the name of the application
- `protocol` defaults to `udp`, but see below for `tcp` usage

Each of these details can be overriden in the respective environment hashes.

**Optional**

Add `disabled: true` to either the default hash to disable Rogger entirely, or to any of the environment hashes to disable Rogger for specific environments.

### Sending GELF over TCP

Rogger also supports sending logs over TCP, something the official `gelf-rb` repository doesn't officially support yet (14th October 2015). This is useful if your Graylog2 servers are load-balanced with HAProxy, which only supports TCP.

siawyoung forked v1.4.0 of `gelf-rb` and added TCP support, so in order to enable sending over TCP, you have to specify it as such in your Gemfile:

```ruby
gem 'gelf', github: 'siawyoung/gelf-rb'
```

Once `gelf-rb` updates with TCP support, this will no longer be necessary.

## Lograge

Rogger works perfectly well with Lograge. In fact, we highly recommend using Lograge, as default Rails logging is too verbose for production debugging. 

Lograge also comes with a Graylog2 formatter, which formats additional information in your payload in a way that presents very nicely in the Graylog2 web interface.

Official installation instructions [here](https://github.com/roidrage/lograge).

With Lograge, logging arbitrary information is super easy. For example, logging user IP addresses:

```ruby
# production.rb
config.lograge.enabled = true
config.lograge.formatter = Lograge::Formatters::Graylog2.new
config.lograge.custom_options = lambda do |event|
  {remote_ip: event.payload[:ip]}
end
```

```ruby
# application_controller.rb
def append_info_to_payload(payload)
  super
  payload[:ip] = request.headers['HTTP_X_REAL_IP'] || request.remote_ip
end
```

## Tips

Don't forget to increase your production `log_level` to at least `:info` to avoid being inundated by useless logs.

### Development

Rogger can be used in development as well. To turn off the verbose Active Record logging, simply add this line:

```ruby
# development.rb
config.active_record.logger = nil
```

Many more excellent tips [here](http://rubyjunky.com/cleaning-up-rails-4-production-logging.html).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rogger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
