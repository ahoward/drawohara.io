A cool tool called [Chrome Logger](http://craig.is/writing/chrome-logger) has been around for awhile that allows, through a known specification, client side logging from the server. It seemed to have undergone a complete rewrite recently but only had PHP and Python implementations.

After some quick work last night, I was able to release an early version of a Ruby implementation. It's a Rack middleware packaged as a gem that exposes `env['console']` from which you can create log messages.

It also comes with easy Rails integration: `require 'chrome_logger/railtie'`

You can check out [an example](https://github.com/cookrn/chrome_logger/blob/master/example/config.ru), read [the code](https://github.com/cookrn/chrome_logger), or just install it!

`gem install chrome_logger`

Ryan