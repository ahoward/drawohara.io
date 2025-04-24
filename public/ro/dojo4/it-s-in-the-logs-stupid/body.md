(This post originally appeared on Spike's [Stuff... And Things... blog](http://www.stuff-things.net/))

Yesterday, I was involved in a fire drill around the launch of a new Rails site on a very tight time frame. The site worked fine in development/staging, but the index was taking upwards of 10 seconds to render in production.

Because it worked outside of production we leapt to the conclusion it was related to the hosting infrastructure. We checked Apache, Passenger, server load, network configuration, and so on. Nothing.

Finally, I thought to check ```log/production.log```, and there is was:

```
Processing by BlahController#index as */*
  Rendered blah/_carousel.html.erb (5795.2ms)
  Rendered blah/index.html.erb within layouts/site (5801.5ms)
```

We quickly tracked it down some image processing that wasn't being cached. It didn't show outside of production because the image assets were different. I won't bore you with the details.

However, I will ~~bore~~ enlighten you as to my point. When debugging a problem, start with the simple things. The Rails logs aren't very detailed, but they provide more than enough information to quickly drill down to problems in your code.
