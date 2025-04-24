(This this is a condensed version of [Yes, Virginia, You Can Use SNI](http://www.stuff-things.net/2014/11/14/yes-virginia-you-can-use-sni/) which originally appeared on Spike's [Stuff... And Things... blog](http://www.stuff-things.net/))

When you connect to a web server securely using HTTPS the security is negotiated using [TLS](http://en.wikipedia.org/wiki/Transport_Layer_Security). Two things happen, the identity of the server is verified and the connection is encrypted.

The verification is important, it doesn't matter if the connection is encrypted if you've somehow been redirect to an evildoer's server. However, that verification can be problematic if a web server is serving more than one hostname.

You can read the [gory details](http://en.wikipedia.org/wiki/Transport_Layer_Security#TLS_handshake), but the simplified version of the process is the server sends a signed [Public key certificate](http://en.wikipedia.org/wiki/Public_key_certificate) that has to match the hostname in the URL. If a client browses to dojo4.com then the cert must be for dojo4.com, if it's not the browser throws up a big scary warning.

Technically, it's possible to have multiple hostname on a certificate, in fact it's common to have, say both "dojo4.com" and "www.dojo.com", for completeness. However, it's a tremendous pain in the ass to add and remove hostnames from a cert. You have to have the issuer generate a new one and revoke the old. And, if you are working with a Content Delivery Network, they are pretty unlikely to add your hostnames to their certificate.

Originally, TLS supported on one certificate per web server (or more correctly, per IP address attached to the web server) [Server Name Indication (SNI)](http://en.wikipedia.org/wiki/Server_Name_Indication) was added to TLS to solve this problem. At the start of the TLS negotiation, the client tells the server the name of the host it's trying to connect to and the server can then select and send a correct certificate file. Problem solved!

Except... Not all browsers support SNI. Everyone *knows* this, and as a result, tend to skip SNI and go straight to per site dedicated IPs or even multiple servers. This is an expensive option, especially when working with CDNs like CloudFront. When this came up for me, I decided to see what "not all browsers" really meant.

Turns out, SNI is widely supported, with the big issues being IE8 and below and any version of IE running on Windows XP (because the underlying OS library doesn't support SNI). There are also some old version of Android out there that lack support as well.

So, most visitors won't have any issues with SNI and the group that do is small enough that we can handle them as a special case.

For those browser without SNI support the workaround is to redirect them to a certificate that will work or a snarky "upgrade your browser" page. If you google, you'll find a bunch of solutions around building whitelists of good browsers and/or blacklists of bad ones and then using those lists in server side redirect rules. Ugly. The lists have to be maintained and depending on the server breaks caching.

There's a smarter way. While wading through a sea of sample Apache redirect configurations, I found it in this [post](https://www.ebower.com/wiki/Detecting_SNI_with_Apache). The post's core idea can be distilled down to this, if a browser that doesn’t support SNI tries to load SNI content, it will get an error. If we test this in the background and differentiate between error and success, then we can redirect the visitor accordingly. And the simplest way to do that is to try an add a one pixel image to the page.

In code it looks like:

```javascript
function secure_redirect() {
   var img=document.createElement('img'); // create an img element.
   // Set the src to an SNI URL of a one pixel image
   img.src='https://www.example.org/pixel.gif';
   // This executes if SNI works.
   img.onload = function() {
      // Redirect to the secure page.
      window.location.href = "https://example.org/";
   };
   // This executes if SNI doesn't work.
   img.onerror = function(e) {
      // Redirect elsewhere
      window.location.href = "http://example.org/snarky-old-browser-message";
   };
   // Don't actually display the image
   img.style.display='none';
   // but append it to the pages so it gets loaded.
   document.body.appendChild(img);
  }
```

Here I'm leveraging two HTML callbacks on the *img* tag, 'OnLoad' which fires when an image finishes loading, and 'OnError' which fires if the image can't be loaded. If a browser doesn't support SNI then the image will fail to load because of a certificate error, firing 'OnError'. However, because we are adding the image to an already loaded page, it won't raise in error in the browser.

Now we can test for SNI and handle lack of support gracefully. Christmas is saved!

However, what we're really arrived at is something more clever. Notice that the code isn't actually testing for SNI, just the ability to securely load the image. If the HTTPS URL in question doesn't actually require SNI, there's only one cert or the first cert matches the requested domain, it still works. The problem has been reduced to "Can this visitor's browser display the secure site or not?" and at the end of the day, that's all that actually care about.
