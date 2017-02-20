# Sinatra Logger

For those who dealt with Sinatra Logging, and tried to configure it correctly (i.e. have Access logs, Error logs, and the normal `logger` functionality), they know how messy that is. Sinatra logging configuration is painful. To get a better understanding, refer to:
* http://recipes.sinatrarb.com/p/middleware/rack_commonlogger (Just logs the access logs)
* https://spin.atomicobject.com/2013/11/12/production-logging-sinatra/ (This goes further to add Errors to the logs as well. However, this breaks with modular Sinatra applications)
* http://stackoverflow.com/questions/5995854/logging-in-sinatra (Or, just outdated answers)
* https://github.com/kematzy/sinatra-logger (Or, outdated libraries)

If you come from a Rails background, you are probably used to the simplicity of:
```
logger.info "some info"
logger.debug "some debugging"
...
```

We offer a slightly "better looking" option using our library.

### Dependency
This library is an interface for `SemanticLogger` library (found here: https://github.com/rocketjob/semantic_logger). It just does the wiring for your `Sinatra` app, and gets you up and running with a simple line of code.

Please, check the `SemanticLogger` (http://rocketjob.github.io/semantic_logger/) to get a glimpse of their pretty neat logging solution.

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'sinatra-logger', '>= 0.2.6'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sinatra-logger -v '>= 0.2.6'

### Usage

We assume that you use either: `Sinatra::Base` or `Sinatra::Application`.
#### One-layer Applications
```
class MyApp < Sinatra::Base
  logger filename: "log/#{settings.environment}.log", level: :trace

  # ... remaining code ...
end
```

#### Multi-layered Applications (Modular Applications)
```
class App1 < Sinatra::Application
  # ... some App1 routes/code ...
end

class App2 < Sinatra::Application
  # ... some App1 routes/code ...
end

class ContainerApp < Sinatra::Application
  logger filename: "log/#{settings.environment}.log", level: :trace

  use App1
  use App2

  # ... remaining code ...
end
```

**NOTE**: You need to only use `logger filename: "", level: :trace` only once (precisely in the container app).


#### Requiring The Logger
```
require 'sinatra/logger' # not 'sinatra-logger'
```

### Development

This gem is still in its beta phase. If you spot any errors, or propose some improvements, contact us: github [at] minodes [dot] com

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/minodes/sinatra-logger. We would love to see your suggestions, fixes or improvements.

## Version Updates
* 0.3.2
  - Add the ability to configure SemanticLogger to write logs in different formats (through Sinatra Logger configuration)– @rabidscorpio pull request.
.
* 0.3.1
  - BUG FIX: Make support for ActiveRecord logging optional (Check if ActiveRecord exists before handling it— @substars pull request).
* 0.3.0
  - Add support for ActiveRecord logging
* 0.2.6
  - Sinatra Access Logging
  - Sinatra Error Logging
  - Normal Logging functionality (`logger.info`, ...)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
