In a recent project, we were tasked with building the mobile version of an existing website. The existing website really wasn't a good candidate for a responsive design, so we decided to create a completely new version of the site for mobile devices.

![5547851770_3598506559_z.jpg](assets/b.jpeg)
_(photo by [Johan Larsson](https://www.flickr.com/photos/johanl/5547851770/in/photolist-9sfc3J-63nmeT-3BAAy-dWUBhB-pAZUn-ccjB1w-st5Gc-7B2UEE-bbLNKX-8yTj9M-9e6jeJ-72jTj6-8RU8QS-5TNHyH-8FkSqy-5r7dgL-5A6ymJ-atHdpQ-7BbKMK-8P8X2-7bD7t6-2ViX1A-5E6qqL-6NDF76-9hBh7m-4bSRnn-sZomP-6VbEE-buapa2-5Kw5si-85KrwR-5kpSzg-bjEUUE-bV9J19-5GXRmg-6zbLPt-8yWpiA-akq64F-5n4ciA-9hmSj5-msHvhK-hZpPt-bFe25b-Bjwzo-mFYCVT-d3v8y-6wRQrs-f1p7uv-f8rrUJ-ebxiKS))_

At first we were thinking of using the m.example.com pattern, where the sites are entirely separate domains. However since we don't manage the infrastructure for this site, we wanted to go with an approach that would require as few infrastructure changes as possible. Supporting another domain on the same servers isn't very difficult, but it's just another task that's easy to mess up and not necessary in our case.

I've also released this technique for anyone to easily use in a rails app through a rails engine:

* https://github.com/milesmatthias/cdddn
* http://rubygems.org/gems/cdddn

## Intro to CloudFront

One huge advantage of this particular website is that it uses [CloudFront](http://aws.amazon.com/cloudfront/). CloudFront is a content delivery network (aka CDN), where static web pages are hosted at [52 data centers all around the world](http://aws.amazon.com/cloudfront/details/). This allows the page to be served to the browser as fast as possible because no matter where in the world you are, you won't be far from one of CloudFront's nodes so it will take less time for the website to be delivered to your device. CloudFront is part of Amazon's AWS offering and in addition to guaranteeing speed, they guarantee uptime. (As opposed to [S3](http://aws.amazon.com/s3/), where only uptime is guaranteed.)

When you use CloudFront, you tell it where your web server is so that CloudFront can get the latest version of the web pages it's serving for you. CloudFront also only asks your web server for new versions of your web pages every few minutes, or whatever time interval you configure in your CloudFront dashboard. Normally, it's somewhere around 24 hours. This allows CloudFront to focus on availability and speed, while greatly reducing the load on your web server. (It also takes time for CloudFront to take a new version of a page and update all 52 data centers.)

However, this introduces the issue of tracking state. For instance, if your site is entirely served by CloudFront, how do you support users logging into your site? If I'm a user named Bob and the page at `/my/account` says "Hi Bob!", CloudFront will think that everyone who requests the page at `/my/account` should see the version of the page that says "Hi Bob!". Users (except maybe people named Bob...) will be really confused. Not only that, but what if a user updates some value in their account and expects that change to display instantly? CloudFront doesn't get a new version of the page on every request (that would sort of defeat the purpose of CloudFront), it waits every few minutes to get a new version. CloudFront has addressed several of these questions with [new features](http://aws.amazon.com/cloudfront/dynamic-content/), but you need to be aware of these implications when using CloudFront.

In our case, the site we're working on doesn't have the concept of "users" and no one can log into the system. However, we still want CloudFront to show different versions of the site depending on what device you request the site from (mobile vs desktop).

CloudFront can do device detection for you and then send a special header to your web server to say "Give me the version of the page for a phone", however we wanted control over the method of device detection (answering the question - is this a phone or a desktop?) and we wanted the ability for end users and developers to override the device chosen for them. For example, end users on a tablet may just want to see the desktop version even though we initially show them the mobile version. Our developers will also find it a hassle to switch their device each time they want to switch between the versions when building the site.

## Our Solution

So here's the method we came up for having both a desktop and mobile version of a site be on the same domain and served by CloudFront. One required note is that CloudFront normally disables all cookies for your domain, but you can configure it to allow cookies you name. In our case, we told CloudFront to allow a cookie called 'device'. Also note that we're in the context of a rails 4 app, but this architecture can be replicated in any stack. The main point here is that the client needs to figure out what device the user is on, allow them to override that, and keep the server aware of the device type so the server can serve the right pages (this is done via cookies).

### On every page we need to do something like this (snippet from app/views/layout/application.html.erb)

```html+erb
<%= javascript_include_tag "mobile_detection" %>

<script>

  if (!window.location.href.match(/get_device|set_device/)){
    console.log('logging the window.location.href = ' + window.location.href);
    localStorage.setItem('referrer_href', window.location.href);
  }

  var device_cookie  = cookie.get('device'),
      cookiesEnabled = cookie.enabled();

  if (cookiesEnabled && device_cookie == undefined) {
    window.location = '/get_device.html'
  }

</script>
```

The above code simply remembers what page you landed on (usually the home page, but we want the client to be able to share links and have it work on mobile too), and then redirects you to the `/get_device` page to detect your device if we haven't done that yet. Note the use of `localStorage`, which means this will only work on IE8+ and won't work on Opera Mini.

Also note that the above snippet is placed in the `<head>` of the layout so that it will be executed as soon as possible and before any scripts the desktop version may have. In this case, the desktop version heavily uses javascript to load lots and lots of content, so we really didn't want all of that to happen on a phone before the site recognized the user should be seeing the mobile version of the site.

### On every mobile page we need to do this (from `app/views/layout/application.mobile.erb):

```js
    <script>
      var device_cookie  = cookie.get('device'),
          cookiesEnabled = cookie.enabled();
 
      if (cookiesEnabled && device_cookie == 'desktop') {
        window.location.reload(true);
      }
    </script>
```

This is because mobile devices cache the pages heavily (which makes sense) so if the user has changed the device they're on, we need to make sure we send that updated cookie to the server even though the url hasn't changed (and therefore the cache thinks it's the same page that needs to be served). The `true` in the `reload` function call tells the browser to ignore what's in the cache.

Note that we do the same exact thing on every desktop page as well, except checking to see if the user has changed their device to `'mobile'`.

### Device Detection at `/get_device` (app/views/home/get_device.html)

```js
  <script>
 
    function isMobile(){
      var MOBILE_USER_AGENTS = 'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                            'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                            'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                            'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                            'webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|' +
                            'mobile|zune',
          mobile_regex      = new RegExp(MOBILE_USER_AGENTS, "i");
 
      return navigator.userAgent.match(mobile_regex);
    }
 
    // setting the device cookie to what we detect
    var detected_device = isMobile() ? 'mobile' : 'desktop';
 
    cookie.set('device', detected_device, {
      domain: '<%= Rails.env.development? ? '' : Settings.host %>',
      path  : '/'
    });
 
    // window.location to whereever you came from
    window.location.assign(localStorage.getItem('referrer_href'));
 
  </script>
```

### Device Override at `/set_device` (app/views/home/set_device.html)

```html+erb
<body style="background-color:#f1f1f2">
 
  <h1>Which device do you want to see the site as?</h1>
 
  <form id="device_selection_form">
    <input type="radio" name="device_option" value="desktop">Desktop</input>
    <input type="radio" name="device_option" value="mobile">Mobile</input>
 
    <button id="set_device_btn">Set device</button>
  </form>
 
 
  <script>
 
    document.getElementById('set_device_btn').addEventListener('click', function(e){
 
      // setting the device cookie to your selection
      var options         = document.getElementsByName('device_option'),
          selected_device = '';
 
      for(var i=0; i < options.length; i++){
        if (options[i].checked) {
          selected_device = options[i].value;
        }
      }
 
      cookie.set('device', selected_device, {
        domain: '<%= Rails.env.development? ? '' : Settings.host %>',
        path  : '/'
      });
 
      // window.location to whereever you came from
      window.location.assign(localStorage.getItem('referrer_href'));
 
      alert('Okay, we set your device to be ' + selected_device);
 
      e.preventDefault();
      return false;
    });
 
 
  </script>
 
</body>
```

After you set up your CloudFront distribution to get web pages from your web server (aka origin in CloudFront terms), you can navigate to the cloudfront domain through your browser to verify that CloudFront is caching your web pages. In Chrome, this means navigating to the "Network" tab of the developer tools, clicking on the initial page request, and looking for a header called "X-Cache". The header's value will either be "Hit from CloudFront" or "Miss from CloudFront", depending on whether or not CloudFront had that particular page / cookie combination cached.

If you'd like to use this technique in your own rails app, I've created a Rails engine to easily incorporate. See:

* https://github.com/milesmatthias/cdddn
* http://rubygems.org/gems/cdddn
