So we like trying out random front end frameworks here at dojo4 on projects, and the latest one we've tried is [SpineJS](http://spinejs.com/). Here are my thoughts after using it on a couple of projects:

*Pros:*

**1. Short, open source code.** Anytime I had a question about how the framework was interpreting my code, it was incredibly simple to open the source files and read the code for myself.

**2. Solid web server tool in Hem** Everything you need to get a front-end app up and running is provided to you with hem and SpineJS. Tests are automatically setup and easy to modify. Hem also has a nice `-d` flag, which won't minify your application to make it easier to debug in development.

**3. Built in data persistence layer** SpineJS ships with Ajax and LocalStorage adaptors for your models which are really easy to use and subclass. It's also easy to write your own since you have the source code for the Ajax and LocalStorage adaptors and they're pretty short.

**4. Active Google Group and github community** Whenever I had questions along the way there was always someone in the community able to lend an idea. They have a [Google Group](https://groups.google.com/forum/#!forum/spinejs) and an active [github organization](https://github.com/spine).

**4. Coffeescript is awesome.** This point is less about SpineJS, but SpineJS was my first use of Coffeescript and it rules. I should write a blog post all about Coffeescript but it rules for its ease of reading without all of those cluttering parentheses and semi-colons, scoping functions with the fat arrow, and the question mark to prevent me from having to do tons of existential conditionals. And oh yea -- classes.

*Cons:*

**Docs aren't totally complete.** I guess this point isn't exactly fair because their documentation is more like a collection of explained examples instead of a true API documentation, but the point remains that [there are functions](https://github.com/spine/spine.site/issues/52) within the framework that aren't addressed in the docs. However, with point #1 above, it's super easy to read the source code yourself.

*Overall:*

Overall I'd recommend this framework and am highly likely to use it again. Between the simplicity and ease of use of Coffeescript and SpineJS, they seem like a match made in web heaven.