As CTO of a technology agency I'm constantly evaluating new tools, processes, and services.

Recently I've been looking at the DigitalOcean platform as part of an ultra-high-availability strategy we've been developing for those times when AWS/S3 isn't enough: when you want to weather a massive outage of an entire cloud provider.

All of Dojo4's deploys start out as AWS ones for the obvious reason: it is the standard by which all other cloud services are judged.  It has the additional benefit to an agency in that we can point to it as a 'sane default' for software we deliver to customers; as the 800 pound gorilla its use is defensible.  However, some rare clients have voiced concerns about AWS outages affecting their sites and applications, in particular monitoring applications which are supposed to report errors about such outages: a recursive problem.  For these cases we've been looking at static deploys balanced across cloud providers with DNS, and DigitalOcean has been on the short list of contenders to create and deploy simple static sites hosted by Apache for this purpose as a failsafe for our normal AWS hosted sites.

Recently DigitalOcean (DO) had a wee issue related to it's security practices: https://github.com/fog/fog/issues/2525.  

One could summarize this issue as: when you boot up a new cloud box it may or may not have some previous user's sensitive data lying around on the disk and, when you shut your own cloud box down, you may expose your own sensitive data to some random 3rd party.  Their service provides a way to wipe things clean but it is *not the default* - the default is to leave *whatever was on the disk* exposed for the next customer to dig around in.  

*This is a really bad default strategy.*

On twitter I suggested that I wasn't surprised by this lax strategy, but that I was disappointed at the way DO handled themselves during the disclosure.   During a brief exchange on twitter I was asked to summarize the source of my non-surprise:

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/drawohara">@drawohara</a> If you wanted to take the time to put it into an email, I&#39;d read and share it with the whole team, and appreciate it greatly. :)</p>&mdash; John Edgar (@jedgar) <a href="https://twitter.com/jedgar/statuses/417579347302944768">December 30, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

So, here with 20/20 hindsight and actually trying to be helpful, I'm fulfilling my promise and explaining why I've been dragging my feet moving any of our stuff to DigitalOcean's platform. (Please note that this list compromises feelings and impressions only, but that they've been somewhat validated and strengthened by the recent disk scrubbing fiasco):

- Visting DO's home page one is greeted with a blaring marketing message that screams 'cheap and fast'

![](http://cl.ly/T8K9/Screen%20Shot%202013-12-30%20at%201.00.09%20PM.png)

given that the platform is 'built for developers' I personally find it strange that the team apparently didn't anticipate developers getting the clear message that of 'good, fast, and cheap' one is picking the latter *two* with DO.

- Next, one gets a nice confirmation message that, as start-up, DO is motivated to demonstrate very, very fast growth

![](http://cl.ly/T8pL/Screen%20Shot%202013-12-30%20at%201.05.20%20PM.png)

this should give any operations engineer a sick in the stomach feeling.

- Poking around the site one finds consistent beating of the 'fast and cheap' drum, for instance in the referral program

![](http://cl.ly/T8ww/Screen%20Shot%202013-12-30%20at%201.09.52%20PM.png)

which hammers the message home and suggests devs sell their buddies on fast and cheap without even a shred of information about robustness, consistency, or security.

- Reading through the blog it was very clear that DO follows a lean, user driven, development cycle:

https://www.digitalocean.com/blog_posts/a-lean-start-for-digital-ocean

and while I admire, approve of, and recommend this kind of approach to software in general, building security and robustness iteratively doesn't seem like the sweet spot for this kind of business - despite how awesome VCs (who have never fought a security breach in the wild) must think it is. Some things require massive experience and top-down planning: a stack that lets its users store data and execute code on, be it a browser or cloud, fall into the category of 'I want someone extracting real code from real systems with a history of attack' and not 'We listen to users and iterate quickly, learning as we go.'

So, don't get me wrong, I am still evaluating DigitalOcean as a nice programmable stack on which to deploy simple static sites and I certainly want to see them succeed, but  I have concerns about their culture and if it is the kind of culture that practices defensive vs. reactive security practices and if they'll be able to maintain their growth, price point, and ultimately funding when, and if, they catch up with the other cloud players in this regard.  Reading through their attitudes and beliefs in the context of the recent debacle (https://github.com/fog/fog/issues/2525) gives me some reason to doubt it.