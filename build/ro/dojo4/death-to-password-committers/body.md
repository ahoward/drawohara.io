Recently an article came across my not-rss feed regarding the number of developers who've carelessly checked in sensitive credentials for the world to see:

- http://www.net-security.org/secworld.php?id=16566

A couple of things struck me about this article:

- How the fuck does any one run a website with 'security' *and* 'php' in its urls... ?

- How much lazier can the average developer be?

Seriously, laziness is generally considered to be a great virtue amongst programmers (http://c2.com/cgi/wiki?LazinessImpatienceHubris) but this has never applied to security, despite my own personal penchant for solving problems with 'chmod -R 0777'.  (temporarily Dave!)

There is an army of developers, listed as contributors to the offending repos, who will argue until they're red in the face about all sorts of things like editors, languages, frameworks, platforms, css grids, and testing frameworks.  These same developers will check sensitive passwords into a *repository*, to be preserved like amber in a icy cave, because they just can't be bothered to write 100 lines of code to properly encrypt stuff that *should never be in a repo*.

If you are one of those developers please stick an onion slice in you pee-hole and ponder this a bit.

If you're a company that practices this anti-pattern please use the entire onion.

If you write frameworks that encourage the use of 'config/hack-my-db-little-pony.yml' use the entire bag.

OpenSSl isn't that hard.  Encrypt your shit.  At least encrypt your client's shit.

Just *don't* leave the password your boss, client, or founders use for *everything else* (because you know they do) lying in the cryogenic freeze of a GitHub repo.  Public *or* private.

The design patterns to solve this are simple;

- https://github.com/ahoward/sekrets

is one.

If you're in Ruby, you can flat out *have* this one.

If not please write one in your language of choice.

But whatever you do, don't be lazy when it comes to checking in passwords.  It's just completely and totally - amateur hour #weaksauce.

