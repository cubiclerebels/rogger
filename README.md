# Rogger

The easiest way to log your Rails apps to Graylog2!

- TCP support with siawyoung's fork of `gelf-rb`
- Highly recommened to be used in conjunction with Lograge
  - Allows you to log many other things (Rack, params, sessions, etc.)

**Updated!** Now supports seamless logging, even in Rake tasks! (in a Rails environment) See below for details.

## Installation

Add the following to your application's Gemfile:

```ruby
gem 'rogger', source: 'https://repo.fury.io/davidchua/'
gem 'gelf', github: 'siawyoung/gelf-rb'
```

And then execute:

```
$ bundle
```

As of v0.1.2, Rogger now has a hard dependency on `siawyoung`'s branch of `gelf`, instead of the officially maintained repo, as `siawyoung` fixes some outstanding bugs to allow for seamless logging. Until the maintainer of the official repo becomes responsive again, this hard dependency will continue to be enforced.

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

The following example disables Rogger entirely:

```yaml
default: &base
  host: 123.123.123.123
  port: 12200
  app_name: <%= Rails.application.class.parent if defined?(Rails) %>
  protocol: tcp
  disabled: true

development:
  <<: *base

staging:
  <<: *base

production:
  <<: *base
```

This disables Rogger for the development environment:

```yaml
default: &base
  host: 123.123.123.123
  port: 12200
  app_name: <%= Rails.application.class.parent if defined?(Rails) %>
  protocol: tcp

development:
  <<: *base
  disabled: true

staging:
  <<: *base

production:
  <<: *base
```

### Sending GELF over TCP

Rogger also supports sending logs over TCP, something the official `gelf-rb` repository doesn't officially support yet (14th October 2015). This is useful if your Graylog2 servers are load-balanced with HAProxy, which only supports TCP.

siawyoung forked v1.4.0 of `gelf-rb` and added TCP support, so in order to enable sending over TCP, you have to specify it as such in your Gemfile (EDIT: see above - `siawyoung`'s fork is now enforced):

```ruby
gem 'gelf', github: 'siawyoung/gelf-rb'
```

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

## Arbitrary logging / Rake task logging

Rogger v0.1.2 introduces arbitrary logging, which also works in Rake tasks. The only additional requirement is that your task should run the special `environment` task to load Rogger in, something you may likely already be familiar with / or are already doing.

The following code example is a comprehensive look at what Rogger can do in your Rake task.

```ruby
# lib/my_tasks.rake
namespace :my_tasks do
  task :first_task => :environment do
    Rogger.debug "This is a debug message"
    Rogger.info  "This is a info message"
    Rogger.warn  "This is a warn message"
    Rogger.error "This is an error message"
    Rogger.fatal "This is a fatal message"

    Rogger.info do
      { short_message: "Don't forget to include a short message as required by GELF", custom_key: "This is a custom key-value pair that will be parsed by Graylog2", custom_key2: "This is a another one" }
    end

    Rogger.log_exceptions do
      x = 1/0 # will raise a ZeroDivisionError that will be logged
    end

    Rogger.log_exceptions! do
      x = 1/0 # will log the exception but will rethrow the exception
    end
  end
end
```

Following the code example above, you can do it in your Rails application:

```ruby
# some_controller.rb
def index
  Rogger.debug "Running the index action in some_controller"
  @some_items
end
```

and of course, you can also do it in ERB as well (if you really want to):

```ruby
# index.html.erb
<% Rogger.debug "This is the index view" %>
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
