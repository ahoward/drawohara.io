__Update:__ Redis creator [Salvatore Sanfilippo](https://github.com/antirez) responded to my pull request documenting this method of disabling `bgsave` with [this comment](https://github.com/antirez/redis/pull/1683#issuecomment-41163718). Since he agrees there should be a community design process around supporting the disabling of persistence in redis, I added a [new issue](https://github.com/antirez/redis/issues/1704) to allow that discussion to happen. Looking forward to seeing the design process and being a part of it.

__Update:__ Initial work on officially supporting a 'disable persistence' configuration has begun by [Matt Stancliff](https://twitter.com/mattsta). See Matt's work [here](https://github.com/antirez/redis/issues/1704#issuecomment-42575432). This is awesome to see. Thanks Matt!



I spent hours researching and scheming on how to prevent [redis](redis.io) from writing any database values to disk, since the redis instance will be handling sensitive information. (In our case we're storing cvv's for 60 minutes and due to PCI compliance regarding credit card usage, absolutely cannot write these values to disk - ever.)

Read the docs, the config file, googled, tested, and even tried telling it to write to `/dev/null`.

Finally the answer came from 'TheRealBill_here' on the `#redis` irc channel:

```
dbfilename ""
```

in the config file.


Here's [a link to our whole conversation](http://irclogger.com/.redis/2014-04-14#1397514047) if you're interested.

I also submitted [a pull request](https://github.com/antirez/redis/pull/1683) to add a note in the config file for redis.

This answer came to me after I had already made a couple of other decisions about configuring redis to store credit card information:

* `loglevel` has a default of info, which won't print each read/write, so we're good there. Although for our use case we would probably feel comfortable just disabling logging altogether.
* `save` directive is set at `save ""` so that snapshotting is definitely disabled.
* `replication` not in play. When using replication, the master initializes a slave by writing its own database contents to disk, sending the slave that file, and the slave loading the database dump into its database. Obviously, we can't do that. (Also note that if we did add a slave at some point, it wouldn't be able to sync with our current config of `dbfilename ""`. See the log for the error when you call `bgsave` from `redis-cli` yourself.)