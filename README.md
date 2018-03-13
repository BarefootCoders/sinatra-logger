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
  logger appender: :file, filename: "log/#{settings.environment}.log", level: :trace

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
  logger appender: :stdout, level: :trace

  use App1
  use App2

  # ... remaining code ...
end
```

**NOTE**: You need to only use `logger appender: ...` only once (precisely in the container app).


#### Requiring The Logger
```
require 'sinatra/logger' # not 'sinatra-logger'
```

#### Using the logger in external classes/libraries
Sinatra Logger is an interface/wrapper for the SemanticLogger. If you want to log from external classes, you can simply include an instance of the SemanticLogger as follows.

```
require 'sinatra/base'
require 'sinatra/logger'

class ExternalClass
  include ::SemanticLogger::Loggable

  def foo
    logger.info "Foo"
  end

  def self.bar
    logger.info "Bar"
  end
end

class App < Sinatra::Base
  logger appender: :file, filename: "test.#{settings.environment}.log", level: :trace

  get '/' do
    logger.info "GET / REQUESTED :D"

    # Encapsulated Method
    obj = ::ExternalClass.new
    obj.foo

    # Static Method
    ::ExternalClass.bar
  end

  run! if app_file == $0
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/BarefootCoders/sinatra-logger. We would love to see your suggestions, fixes or improvements.

## Version Updates
* 0.4.0
  - Add appender flexibility, allowing for more than just `file` output.
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
