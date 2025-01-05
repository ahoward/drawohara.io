We use [capistrano](http://www.capistranorb.com/) for our deployments and recently I came across the sweet [terminal-notifier](https://github.com/alloy/terminal-notifier) gem that uses the user notifications in OS X 10.8 and above to show a nice notification from the command line. Whenever I deploy I'm always manually checking if the deploy has finished yet, and this is a nice solution to avoid that. One problem that I ran into though when adding it to one of our projects is that some people on our team are using a version of Mac OS X _before_ 10.8 (I know!), so the `terminal-notifier` command would fail and their deployment would have errors in it. So here's the code I use now to ensure errors don't show up if you can't use the cool user notifications in newer os x's:

```ruby
desc 'use terminal notifier if in > osx 10.8 to use a user alert'
task :terminal do
	begin
		require 'terminal-notifier'
        url         = fetch(:url)
        application = fetch(:application)
        system "terminal-notifier -title #{ application } -message 'Deploy completed successfully to #{ url }.' -sound default"
	rescue LoadError
        warn "You're probably not on os x 10.8, so not using terminal notifier. If you are, use gem install terminal-notifier to use some sweet user notifications."
	end
end
```

Obviously we also include `gem terminal-notifier` in our Gemfile. See [my SO question](http://stackoverflow.com/questions/20885606/dangers-of-putting-a-gem-into-a-gemfile-is-someone-trying-to-install-it-doesnt) about including this gem in your gemfile for an explanation of why I'm using the simple gem include statement.