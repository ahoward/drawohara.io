Like every development shop, we get a lot of people coming to us wanting to create an app for both iOS and Android. They want to figure out a way to save time and money by not completely duplicating work on their app for each OS. So naturally we’ll talk with these potential clients about architecture options using HTML content and web views. (Our most recent client wanted to share functionality between an iOS app and a website as well, so we were especially directed toward using HTML in the mobile app.) Along this path, the thought of using Phonegap always comes up. We’ve been down this road a few times, and here are our conclusions.

Phonegap sucks. Here’s why:

* Learning a whole new framework when you should be learning Obj-C or Java.

* Depending on them to support OS features (cross your fingers it exists and works! cross your fingers they support new stuff quickly!)

* Mess of an organization&mdash;Phonegap? Cordova? Which is it?!?!?! (Just use Phonegap and you’ll be fine&mdash;Okay… oh wait, I have to use the cordova CLIto add plugins?!)

* Outdated, incorrect, and confusing documentation (partly due to the above point)

* The community around it is more concerned with supporting every device on the planet instead of helping a developer take some HTML content and publishing it effortlessly in one of the main 2 OSes. (Well that’s what Phonegap Cloud is for&mdash;tried to use it 3 times, it’s broken.)

In short, Phonegap is focused on making you 10% satisfied on 100% of the devices in the world. In our experience, clients care about being 100% satisfied on only 2 of the devices in the world—iOS and Android.

So what’s our solution? Embrace Obj-C and Java! HTML content in an app is a great way for simple apps to have a single code base on multiple platforms, but you need fine grain control over the entire app and you need to follow Apple and Google’s instructions on how to take advantage of their OS features. So we have frameworks (iOS nearly ready for open sourcing & Android still in early works) that contain one web view and then use small, open source libraries to create a bridge between that web view and the native application. This allows us to write our own Javascript API to call whatever native code we write. (For iOS, we use the awesome WebViewJavascriptBridge by Marcus Westin)

For example, when we have HTML content that wants to share a link to Facebook or Twitter, we wrote our own Javascript API to say:

bridge.callHandler(‘facebookShare’, ‘http://ducksarethebest.com’);
and then in Objective-C, we wrote the handler to take that URL and use the official Facebook iOS SDK to share that link:

[_bridge registerHandler:@”facebook_share” handler:^(id data, WVJBResponseCallback responseCallback) {
FBAppCall *appCall = [FBDialogs presentShareDialogWithLink:[NSURL URLWithString:data] handler:fbHandler];
}];
This is a dramatically better experience than letting the web view share that link because if the user already has the Facebook app and is signed into it, the Facebook SDK won’t require them to log in again, whereas the web view sharing method will.

It’s even better for solutions where there isn’t a web alternative, like in-app purchases. And especially something so vital to the success of your app&mdash;users paying you money&mdash;you want to make sure it’s done correctly in the most up-to-date and recommended way. The only way to do that is to follow Apple or Google’s guidelines in their official SDK.

This approach gives us the flexibility to write whatever JS API works best for us, the immediacy of taking advantage of any feature available in the iOS or Android SDKs, and it improves our development skills in a language and SDK that actually matter to our long term careers. Most importantly, the client is happy that we’re in full control of the app, we’re not relying on some 3rd party group to support features that Apple or Google released months ago, and the app can be as truly native or web-based as it takes to create the best user experience.