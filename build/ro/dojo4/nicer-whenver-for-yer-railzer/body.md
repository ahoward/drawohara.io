whenever.rb is a nice DSL for configuring cron tasks in ruby ( https://github.com/javan/whenever )

however, it has a major flaw: all the tasks it runs under cron use the *same unix priority*, and by 'priority' we mean *the one that takes yer boxen down*

fortunately, this is easy to fix

step one, replace // configure the job templates in your ./config/schedule.rb file to look something like this

```ruby

# Learn more: http://github.com/javan/whenever

job_type :rake, "cd :path && RAILS_ENV=:environment :environment_variable=:environment nice -n 19 bundle exec rake :task --silent :output"

job_type :runner, "cd :path && nice -n 19 ./bin/rails runner -e :environment ':task' :output"


```

step two: _profit_


for those of you that don't know what unix 'nice' is you might want to read http://en.wikipedia.org/wiki/Nice_(Unix).  TL;DR: it makes your background processes not eat all teh CPUz.