One of our favorite clients, [Gnip](http://gnip.com) (recently [acquired by Twitter](https://blog.gnip.com/gnip-twitter-join-forces/)), leans on us for all of their marketing design and websites, including [gnip.com](http://gnip.com), [blog.gnip.com](https://blog.gnip.com), and [engineering.gnip.com](https://engineering.gnip.com).

Their two blogs are WordPress instances (remnants of a pre-dojo4 legacy) that never seemed to be worth the effort to migrate out of WordPress at the time.

[Gnip.com](http://gnip.com) however is a fully static website built with Middleman and hosted on S3 and CloudFront. We made this recommendation after building and hosting a full-fledged Rails application for their site and noticing that their site would be a perfect candidate for a simple static site. The factors that tipped us off to this are the same for any other static site: no user accounts, speed and uptime are the highest priority, and so few updates that an admin interface is overkill (although with our static site, dojo4.com, we built [a webhook to listen for blog post publishes](http://dojo4.com/blog/static-is-the-new-black)).

We had one interesting question though - since we're training the marketing team how to use this website, not developers, what kind of reactions would they have in experiencing both the admin-heavy side of WordPress (for their blogs) versus updating code in the middleman site (for gnip.com) and deploying via the command line?

Turns out they love the middleman setup and wish we would have switched their blogs over to middleman instead of WordPress years ago.

WordPress has one feature - an interface to draft and publish content that people are familiar with. Ignoring the [emotional turmoil](http://dojo4.com/blog/irish-dance-and-wordpress-the-soul-destroyer) of WordPress for a second, the maintenance cost and effort for a WordPress site are astounding for a medium to large company. 

Plugins seem like a good shortcut to add functionality to your site until you have to modify or update one because it hasn't been updated in 2 years. When Gnip was acquired by Twitter, the security team at Twitter wanted the blogs to ensure all content was over HTTPS. It's a simple request, but when you have 25 WordPress plugins that are including their own resources, many of which don't even support HTTPS, it's a monster headache. Whereas with our static, Middleman approach, we do a quick search and replace in the code (and from the beginning, only using local resources or ones from reputable sources that do support HTTPS, like Google), deploy, and we're done.

When you take the time to help people learn simple skills like HTML, CSS, and Javascript (which are nearly required skills to learn if you're involved in tech at all - regardless of your job title), the drawbacks of WordPress become way more than is acceptable when there's such a simple and powerful option in static web content and hosting.
