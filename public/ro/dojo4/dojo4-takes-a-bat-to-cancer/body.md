[dojo4's last project with Stand Up to Cancer](http://dojo4.com/blog/dojo4-stands-up-to-cancer) (SU2C) [helped them raise over $100 million in one telethon](http://dojo4.com/blog/su2c-live-telethon-rawked). A month later we're working with SU2C again; this time they are partnering with Major League Baseball to raise funds at the World Series!

SU2C came to us with an issue - MLB is featuring SU2C and the fight against cancer during [Game 3 of the World Series](http://mlb.mlb.com/mlb/gameday/index.jsp?gid=2014_10_24_kcamlb_sfnmlb_1) (tomorrow - Friday, Oct 24th)! They wanted to improve upon an app that we built them a few months ago that allows people to make a tribute to a loved one affected by cancer: [#istandupfor](http://istandupfor.su2c.org).

We originally built the app as a responsive website where people could upload an image, type in a dedication, share their tribute on social media, and be featured in the SU2C gallery. With the new visibility of Major League Baseball, SU2C wanted to take the app to a whole 'nother level. So we went back to the drawing board.

Here were the requirements:

* __handle tons of traffic!__ The MLB World Series is an international event with millions of people watching. When they mention the #istandupfor movement, we're gonna see a major spike in traffic.
* __have a native app presence!__ There was an older version of #istandupfor in the iOS app store, but it needed updating and there wasn't an Android application. We needed to allow people to honor loved ones and share their tribute on their mobile devices as well.
* __keep maintenance to a minimum__ SU2C's goal is to raise money for cancer research, not have 3 different apps to maintain for the same #istandupfor movement.

So here's what we did:

## leave scaling to the experts

Attempting to handle the load of a huge amount of traffic directly on our servers is a straight ticket to stressed out developers frantically fixing bugs and leaving users hanging when they're trying to contribute to the awesome SU2C community. You know who's good at handling massive amounts of uploads? Amazon S3.

So instead of requiring that one of our EC2 web servers is up and working, the apps directly upload images and all of the required information about a tribute (dedication, email, etc in a little json file) to AWS S3. The web version of #istandupfor already uploaded images to S3, so the refactor was minimal. Amazon also has native mobile app support for S3 uploads with SDKs for iOS and Android.

Then our EC2 servers just periodically check S3 for new tribute uploads and process them in our central database for viewing individual tributes online (think social media sharing) and for SU2C to approve and add to the gallery. Our users will always be able to create tributes no matter which platform they're using (web, iOS, or android), thanks to S3 & CloudFront.

We had a conference call with AWS (shout out to David and Nathaniel!) to ensure our plan was solid and they agreed it was the best approach. The engineers over at AWS know exactly how to handle thousands of requests per second without breaking anything, so we let them.

## hybrid native apps

SU2C wanted a native app presence, but also really wanted to avoid a lot of maintenance going forward. App stores are great distribution mechanisms, but do contain a lot of hoops to jump through. Going through those hoops once is a lot easier to handle than having to go through them every time a change is required in the applications.

So we used my iOS & Android starting points, [Imbed](http://imbed.github.io/), to create native iOS and Android applications that use a web view to load the application. The native wrappers provide javascript handlers that trigger native code, so we can create whatever native code we need (for this case the majority of the native code was picking an image from the device and uploading it to AWS S3 via the AWS SDKs) and then call that native code via a web page loaded within the app. That web page is still a web page, so we can make updates to it, push it live, and the app will be updated without ever having to jump through app store hoops again.

Check out the [Android App on Google Play](https://play.google.com/store/apps/details?id=com.eifoundation.su2c) and the [iOS app on the Apple App Store](https://itunes.apple.com/us/app/stand-up-to-cancer/id669692145?mt=8)!

We love working with SU2C. Not only do they raise bajillions to fight cancer, they are super nice and awesome to work with.  We can't wait to see the results of tomorrow's game - download the app and donate!

