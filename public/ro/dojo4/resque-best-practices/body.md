











Introduction
------------

Resque ( https://github.com/defunkt/resque ) is a really nice, robust,
production quality background job facility for rails.  However, it leaves alot
of thinking for the developer to do regarding best practices for modeling your jobs, managing
deployments, and managing worker processes.  Following is a set of best
practices for using resque/redis as your background job system.

Managing The Background Processes
---------------------------------

Resque has some facilities for managing background processes, but they are
cruftly and buggy.  We use this simple wrapper script to manage a single
instance of the background job daemon:

<br />
<br />

<script src="https://gist.github.com/3123756.js?file=jobs.rb"></script>

<br />
<br />


Modeling Your Jobs
------------------

One of the first thing to do is to determine how to model your jobs.  Resque
makes is pretty simple to submit arbitrary methods on modules, but we prefer
doing something a little more sanitary.  In particular we like having ids on
jobs, being able to query them easily, and making them uber durable in the
face of system or process failures.  By simply consolodating all job logic
into a single model that shadows the resque job this is quite possible.  Here
is our base job class.

<br />
<br />

<script src="https://gist.github.com/3123839.js?file=job.rb"></script>

<br />
<br />

As you can probably see, this class (which could easily be ported to ActiveRecord) allows submission of arbitrary jobs,
mailer or otherwise, and each job leaves a turd in the main database that ties
it to the resque/redis entry.  It makes working with jobs objects extremely natural  - for instance having a polling loop check the status of a particular job by id, or getting a quick count of how may jobs have succeeded in the last week.  It also keeps our resque install super vanilla - we don't use any plugins - and makes it possible to drop in another background processing system in a matter of minutes.
About the only management it needs is a periodic task to to clean out the job
collection/table.  We use whenever( https://github.com/javan/whenever/ ) plus a rake
task to accomplish this:

<br />
<br />

<script src="https://gist.github.com/3123860.js?file=jobs.rake"></script>

<br />
<br />

<script src="https://gist.github.com/3123860.js?file=schedule.rb"></script>

<br />
<br />


Deployment
----------

Finally, your deployment needs to keep things going:

<br />
<br />

<script src="https://gist.github.com/3123860.js?file=Capfile.rb"></script>

<br />
