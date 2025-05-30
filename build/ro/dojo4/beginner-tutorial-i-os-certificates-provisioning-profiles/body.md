For a new iOS developer, they can be really confusing. You have an app that you simply want other people to be able to test on their device, and you get directed to the Apple developer portal with certificates, devices, and provisioning profiles. Before your body goes into shock, read the rest of this post for a simple explanation of it all.

![](https://draftin.com:443/images/2623?token=JlOjG8C7kRhUxTp9Bba_TPBP4jRCn0dL-2ugH03kEATD52BLmxZYEnY4Vynx55mzHS9ub3I5QR29W1MVWjkBA0k) 

The combination of certificates, devices, and provisioning profiles is Apple's answer to some difficult questions:

Q: How do you guarantee the app you're downloading hasn't been modified by some hacker and it's actually from the developer/company that it says it's from?

A: **Certificates.** Ever learned about PGP encrypted email? That whole business where there's a public key and a private key? That's what's going on here, except you're abstracted from having to worry about that because of the Mac app "Keychain Access". When you add a new certificate in the portal and follow the instructions to use "Keychain Access" to upload a certificate request, "Keychain Access" uses your private key to create a public key, which is then embedded into the certificate request that gets sent to Apple. Apple hands you back a certificate that you then put into your keychain (now you can download and add it through Xcode automatically).

_(Update: it looks like you can have Xcode manage your certificates/"Signing identities" in preferences as well.)_

![](https://draftin.com:443/images/2624?token=w3b1zrNeBBqC2WRMbEvt7BKrWA0U5A_FhTLXE9Uvex6mYA5pxwSfYG5M1GGWhYd0TkzxxiD8UUIyN7GA34d8NHQ) 

Note that there are different certificates for different scenarios too. Developer certificates are used when you're just getting any old app (app id: *) to work and you're developing locally and on your development device that's tethered to your computer. An AdHoc certificate is used when you want to allow a few testers to install your app on their device before the public AppStore release. AppStore and AdHoc certificates are tied to a specific app (app id), and they usually use an organization's certificate, since the certificate is how Apple knows what to show on the "Developed By" line in the App Store listing.

Q: How can we allow a handful of testers to install the app on their phone and try it out before we release it to the whole world through the App Store?

A: **Devices & Provisioning Profiles.** Apple only allows its users to install apps through the App Store. But when you're a developer and you want some people to try it out before it goes to the App Store, you need to use provisioning profiles and devices.

First, you get someone to give you their device UUID (universally unique identifier), which usually is done through a service like [Testflight](http://www.testflight.com) or [HockeyApp](http://hockeyapp.net/) where a person can sign up to be one of your testers and the service will automatically email you their UUID. In order to prevent you from circumventing the App Store, Apple restricts you to only adding 100 devices in a year to your iOS developer account.

![](https://draftin.com:443/images/2625?token=vjMPdsPjLmPKBD1DOANNeAD_QkMIQO7y8jE7HvP0sZCej5dwCQjQYVwVdReo7bJE6iZX53ZFBOeVrd5jtElccdU) 

Then you create a provisioning profile. Each provisioning profile incorporates a certificate in order to sign the app securely from a specific person/organization. Provisioning profiles also declare who is able to install the build of the app. In the case of an App Store provisioning profile, it's saying that that build of the app can be installed by anyone as long as it's downloaded through the App Store.

![](https://draftin.com:443/images/2626?token=9C_AJjhMWZQw2pe-0cdxMSUfRssZ-8gogKWU21qGyDaXl7G41hC7-eD8eCQ6rjq6oUtrZqdN_Yo-LvXyI13txqg) 

When you're getting some testers on board, you'll want to use an Ad Hoc provisioning profile (and certificate). In the "Edit" screen of the provisioning profile, you'll be able to select any of the devices listed in "Devices" in your developer portal. Check the box next to the ones you want to include (Note: you can always check or uncheck more or less later).

Generate this profile, download it manually or through the Xcode preferences, select it when archiving your app, and then you'll be able to upload that .ipa file to a service like Testflight for your testers to install.

Some more guiding images:

* Having Xcode automatically download provisioning profiles and certificates for you:

![](https://draftin.com:443/images/2627?token=0uiybrTmNZrs-1G5S3pUkV_02FcnA2PPVTNOPkIa7ugiQP8QMHhfk6swlm_kFIBOIUyv8GpmP3bATsCZylUkf20) 

* Updating certificate ("Signing identity") selected in the project's build settings in Xcode:

![](https://draftin.com:443/images/2628?token=_yRFxLYAdihsFQWVEXwJVQi1JRH16YWIS-BHD0_NmLxyPzqnFg2HwgZknb_DDSBh93Bk1mHAOaOm3ZS5ug4r5bM) 