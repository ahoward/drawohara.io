### TL; DR;

> 99.9% of the web developer world believes that the correct usage of an RDBMS, along with transactions, prevents their applications from seeing bad data and introducing serious data quality errors.  They are *DEAD* *WRONG*.

I read with great interest [Kyle Kingsbury's](https://github.com/aphyr) excellent article about Mongo's consistency model at https://aphyr.com/posts/322-call-me-maybe-mongodb-stale-reads

Obviously this guy is super switched on and knows his stuff.  He's doing the work and everything about this article is insightful and well put together.

What I found astonishing, however, were the comments and what they reveal about the average professional developer:

> Developers think using and RDBMS makes their data safe and they are *absolutely wrong*

I cannot tell you how many times I've gotten into arguments with 'professional' developers and especially silly sysadmins that actually believe that, by simply saying the word RDBMS, spinning a chicken around their head 3 times, and connecting to the magical unicorn of DBs their data will be safe and sound like, you know, ... (something something about) .... banking transaction and all that (nonsense) dither about transactions and fsync.  And a bunch of other stuff no developer I've ever met actually understands or has considered in the context of an HTTP (hint: stateless) application.

Before I proceed I'm going to issue a challenge: 

- Send me your github handle
- Let me pick a MySQL or PostgreSQL backed application you've written (so you can't prep it)
- And I will find code paths that supply both read-uncommitted and dirty-reads in your app within 1 day
- If there are none I will pay you *$1000 bucks*
- If there are any I get to post any picture I choose of you as an addendum to this article.  Photoshop *is* allowed.

Find me @ [/contact](/contact) or [/team/ara-t-howard](/team/ara-t-howard).  Now on with it...

Riddle me this developer: what's wrong with this code path:

```ruby

  @db.transaction do

    if no_user_exists_with_conditions?

      @user = make_that_user_exists_with_those_conditions!

      deliver_an_activation_email_to!(@user)
    end

  end


```

Let me reveal something earth shattering to you:

**THIS CODE IS TOTALLY BROKEN ON EVERY MAJOR _RDBMS_, AND VIRTUALLY EVERY
APPLICATION, IN THE WORLD**

I assure you that the email will go out *twice*.

Explaining transactions is beyond the scope of this article, but let me introduce you to 'phantom reads'

http://en.wikipedia.org/wiki/Isolation_%28database_systems%29#Phantom_reads

In the above code a 2nd, concurrent, transaction can cause the following to happen:

```ruby

  @db.transaction do

    if no_user_exists_with_conditions?

      # meanwhile, a 2nd transaction has created a duplicate user...

      # the following will will succeed, in __both__ transactions

      @user = make_that_user_exists_with_those_conditions!

      # both transaction will deliver the email

      deliver_an_activation_email_to!(@user)
    end

  end

  # one of the transactions will fail to commit, and go *BOOM* but, by then,
  # it is too late: the email has been sent twice and the error has been  made


```

I know I know, you can't believe it.  But that's just because you never bothered to RTFM when it comes to what 'transaction' means.  Start here:

http://www.postgresql.org/docs/9.1/static/transaction-iso.html

Note that little table.  Let me translate it for you:

- Because *you* don't have every *single* sequence of *read&write* wrapped in a transaction, and sometimes just sling code against your ORM objects directly, you suffer from the 'scary' reality of 'read-uncommitted' mentioned in the article

- Because *you* rely on the default isolation level you suffer from both non-repeatable-reads and phantom reads. (Do you even know what the default isolation is for your db and what that means????)

- Because *you* didn't set your transaction level to 'serializable' you falsely believe your database is fast and safe.  You've wrongly relied on the database to provide data integrity as an abstraction that does not require critical thinking and application code at least 10 times better than yours.  You have all the scary features of Kyle's article in your RDBMS backed apps - and, not only do you *not know this* you are *pretty sure your data is 'safe'*


And so I ask you which is a worse engineering decision:

- Pick a standards based tool that everyone is *very* confident they understand and know how to use safely but, in it's common usage, virtually never guarantees that which believe it promises and, furthermore, has been widely [critized as having ambiguous and inaccurate semantics](http://en.wikipedia.org/wiki/Isolation_%28database_systems%29#Default_isolation_level) ?

- Or to accept what has always been true: that by themselves, databases cannot provide abstractions that mean non-extremely-clever developers can't trivally screw things up. And that data integrity is a domain specific concept that must be implemented at the application layer, with only a small part of that integrity being aided by the choice of database.


ps.  I've worked on large scale financial, realtime, and HA systems that use both Mongo and PostgreSQL.  It's damn hard either way.

pss.  I tried to comment on your blog Kyle, but comments were blowing up ;-)

<img src='https://s3.amazonaws.com/ss.dojo4.com/JKeSPdp46a4R3paZkp6oo7X1b7QNhI6hQN4kp1QPx3ZYqn3exRzqht0.png' style='max-width:200px;'>
