Yesterday [Ryan Cook](https://twitter.com/cookrn) and I hit one of those dreaded production only issues experienced developers know and hate on the soft launched [Moshi Moshi Co](http://gomoshimoshi.com/) product [Wall Space Finder](http://wallspacefinder.com/).

This one was a doozy, models would fail to save in staging only, not locally or in production.  Obviously this was *RAILS_ENV* related, or so I thought...

First we did the obvious, looked at the code locally in development mode.  Nothing, it totally worked.  No problems.

Then we used the awesome

```bash


  ~> cap staging db:suck 
  
  
  ### the inverse is, you guessed it, db:blow, because development needs to be moar funi...


```

to suck the remote staging db into the local db, thereby replicating code,
data, and the *RAILS_ENV* via

```bash

  ~> RAILS_ENV=production RAILS_STAGE=staging ./bin/rails server

```

A quick note on that: Dojo4 runs all staging deploys in *RAILS_ENV=production* and disambiguates staging vs. production via another environment variable (*RAILS_STAGE*) precisely for the reason that we like to exercise any and all production behaviors in staging/qa where possible - selectively guarding only _crazy_ behaviors like charging credit cards via *RAILS_STAGE*.

So rest assured the issue was *not* because we had _./config/environments/staging.rb_ setup differently than _./config/environments/production.rb_!

But still, we could not replicate. *#WTF*!?

Finally, I instrumented the staging deploy to use [#dieüberawesomesauce](https://twitter.com/search?f=realtime&q=%23die%C3%BCberawesomesauce&src=typd) [pry-remote](https://github.com/Mon-Ouie/pry-remote) and dropped right into the _BOOMing_ code on the staging node.

And there it was: a unique contraint was being violated in the database.  Yet no
unique indexes were defined in the model, or anywhere else.  Hrmmmmm...

Reviewing the git logs I found that, previously, a unique index _had_ been
defined on the offending model.  Problem solved I thought, a quick


```bash

  ~> rake db:mongoid:remove_indexes

```

and.  *The problem remained.*

Ok.  Code reading time.  3 minutes later the problem was discovered. In Mongoid 4 the _remove_indexes_ task uses this code


```ruby


      # Return the list of indexes by model that exist in the database but aren't
      # specified on the models.
      #
      # @example Return the list of unused indexes.
      #   Mongoid::Tasks::Database.undefined_indexes
      #
      # @return Hash{Class => Array(Hash)} The list of undefined indexes by model.
      def undefined_indexes(models = ::Mongoid.models)
        undefined_by_model = {}

```

ref: https://github.com/mongoid/mongoid/blob/master/lib/mongoid/tasks/database.rb#L40


but, in Mongoid 3.x, which we are using, it has no such logic.


ref: https://github.com/mongoid/mongoid/blob/3.1.0-stable/lib/rails/mongoid.rb

So there you have it: Mongoid 4 ensures that all indexes, even those no longer defined in the code/repo are nuked when indexes are dropped, while Mongoid 3 will leave those indexes lying around in the database!

I decided to write about this experience because:

- 20/20 hindsight I've hit it before myself.  /cc [@spikex](https://twitter.com/spikex)
- It underscores how development and dev-ops need to converge to debug real-world issues: not everything is stateless and lives in the repo, and not all state can be replicated.  Sometimes you gotta do it live.
- Someone will undoubtedly have the same issue and, I hope, find this post via the magic of teh googlez.
- [@modetojoy](https://twitter.com/modetojoy) might consider my current thinking, which is that we should backport the better Mongoid 4 behavior into 3.1.0.

And people wonder why we engineers can't estimate the time and effort to fix a simple bug.

P.S.  Some of you readers might be wondering how I fixed this.  I simply re-defined the index in the console, so Mongoid would be aware of it, and then used the model level methods to nuke it

```bash

[48] pry(#<My::SpacesConducer>)> model.save
Moped::Errors::OperationFailure: The operation: #<Moped::Protocol::Command
  @length=89
  @request_id=604
  @response_to=0
  @op_code=2004
  @flags=[]
  @full_collection_name="wall_space_finder-staging.$cmd"
  @skip=0
  @limit=-1
  @selector={:getlasterror=>1, :safe=>true}
  @fields=nil>
failed with error 11000: "E11000 duplicate key error index: wall_space_finder-staging.art_spaces.$profile.slug_1  dup key: { : null }"


[49] pry(#<My::SpacesConducer>)> ArtSpace.index({:slug => 1}, {:unique => true})
=> {:unique=>true}

[50] pry(#<My::SpacesConducer>)> ArtSpace.remove_indexes
=> true

[51] pry(#<My::SpacesConducer>)> model.save
=> true


```
