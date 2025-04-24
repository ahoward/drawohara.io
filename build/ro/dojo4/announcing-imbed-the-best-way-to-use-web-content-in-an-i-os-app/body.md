Lots of times it makes sense to do some development in HTML, JS, and CSS, and then use that content in a native app. Phonegap claims to be the best solution for that case, but in [my experience](http://dojo4.com/blog/why-phonegap-sucks) it's one of the worst.

In response to Phonegap, I've open sourced our company's starting repo for iOS apps that need to use some web content in a UIWebView, calling it [Imbed](https://github.com/dojo4/imbed).

Features:

* __Small & Open Source.__ One UIViewController, One HTML file, and the super small, 1 class, open source [WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge) project.

* __Support any iOS feature immediately.__ No waiting for some third party developer to create a plugin. You're writing native Objective-C code yourself. So as soon as Apple releases it, you can support it.

* __Follow Apple's guides, not someone else's.__ Apple does a great job of documenting how to use the features of iOS. Most third party developers do not. Which one would you rather follow?

* __Automate everything with Rake.__ Focus on writing your code, testing it in the browser, and then automate everything else in a clear, open source Rakefile. Heck, even archive, ship to Testflight, and notify Campfire.

It's your app. Don't rely on some third party tool to support features that iOS already offers. Take your code by the horns.

[Download Imbed](https://github.com/dojo4/imbed/archive/master.zip) now.