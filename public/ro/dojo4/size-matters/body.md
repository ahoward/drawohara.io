multiplexing which images to send to which devices is a sticky problem.

some people use device detection (user-agents) to determine who wants big
images.  sometimes media queries/screen width is used as a proxy.  

both are poor choices.

these days one can easily desire hi-res images to be displayed using a retina
screened tablet on local wifi.  with 'normal' image enhancement approaches
some devices, with good connections and amazingly pixel density, will receive
low quality images.  

a tablet on a slow connection in landscape orientation might have a screen
with pushing some arbitrary (768px) threshold and be delivered massive images
designed for broadband connected desktop machines.

compounding the problem is that device and/or screen width enhancement can
easily result in sending a small image to a device with a high density display
that causes real layout issues: a 320px image might take up the full screen on
some iphones, while on others it will either occupy 1/2 the screen or become
streched to fill all 640 and look poorly.

what if, instead, we simply always tried to deliver the highest quality images
to all devices and provied lower quality ones if we determined that this was a
bad plan at runtime?  

the approach of jquery.bires is exactly this.

the content intially comes down with low quality images, making page load time
as fast as possible and giving the user the full content.  after all low
quality images are loaded jquery.bires begins replacing low quality images
with hi quality ones *serially*, timing the speed of each replacement.  if any
replacement seems to be taking too long enhancement simply stops.  because
jquery.bires loades the larger images one at the time the ui remains
responsive to user clicks and interactions.

the key here is that, with today's high density mobile displays, it's actually
*bandwith* and *not screen size* that should determine who gets hi quality
images.

this approach results in the fancy tablet on local wifi getting the best
possible experience while, at the same time, keeps pages viewed on a desktop
tethered through a 3G connect from killing a data plan and loading very
slowly.

best of all, instead of manging lists of user agents, guessing about various
breakpoints, etc - the code simply always uses the same strategy of trying
hard to make pages load fast and become as good as possible later.


refs:

* https://github.com/bjankord/Categorizr
* http://www.brettjankord.com/2013/01/10/active-development-on-categorizr-has-come-to-an-end/
* https://gist.github.com/paulirish/268257
* https://github.com/desandro/imagesloaded
* http://www.youtube.com/watch?v=Tj0lmwg27EY
* http://dojo4.com

note:

* jquery.bires *depends on* https://github.com/desandro/imagesloaded


repo:

* https://github.com/ahoward/jquery.bires

<br>
usage:


````html

<li>

  <a href="#!scott-jurek" title="Scott Jurek">
    <img class="bires" 
    data-hires="assets/banner.png"
    src="assets/banner.png" />
  </a>
  
</li>


<li>

  <a href="#!robert-sinskey-vinyards" name="42" title="Robert Sinskey Vinyards">
    <img class="bires" 
    data-hires="assets/banner.png"
    src="assets/banner.png" />
  </a>
</li>


````

<br>


````javascript

  jQuery(function(){
  
    bires.download({'selector' : 'img.bires'});
  
  });

````

<br>
source:



````javascript

(function(namespace){


  // the hi-res image downloader object
  //
    var bires = {};

    bires.selector      = 'img.bires';
    bires.too_damn_slow = 420;
    bires.debug         = false;
    bires.debug_delay   = 420;


  // downloader class and factory method
  //
    bires.downloader = new Function();

    bires.download = function(){
      var args = Array.prototype.slice.apply(arguments);

      var downloader = new bires.downloader;

      downloader.initialize.apply(downloader, args);

      jQuery(function(){
        jQuery('body').imagesLoaded(
          function(){ downloader.download() }
        );
      });

      return(downloader);
    };

    bires.downloader.prototype.initialize = function(){
      var downloader = this;

      var args = Array.prototype.slice.apply(arguments);
      var options = {};

      var opts = ['selector', 'too_damn_slow', 'debug', 'debug_delay'];

      if(args.length == 1 && typeof(args[0]) == 'object'){
        options = args[0];
      } else {
        for(var i = 0; i < opts.length; i++){
          options[opts[i]] = args[i];
        }
      }

      jQuery.map(
        opts,
        function(o){ downloader[o] = options[o] || bires[o]; }
      );

      this.imgs = jQuery(this.selector);
      this.queue = jQuery.map(this.imgs, function(img){ return jQuery(img) });

      this.timer = new bires.timer();

      this.downloading = false;
    };

  // download images serially one at the time, timing each one, bail if things start looking slow
  //
    bires.downloader.prototype.download = function(){
      var downloader = this;

      var img = this.queue.shift();

      if(!img){
        this.downloading = false;
        return(false);
      } else {
        if(!this.downloading){
          if(this.debug) this.imgs.css({'opacity' : 0.42});
          this.downloading = true;
        }
      }

      img.data('lores', img.attr('src'));

      var src = img.data('hires');

      this.timer.start();

      img.imagesLoaded(function(){ downloader.success(img) }); // via: https://github.com/desandro/imagesloaded

      this.log('downloading: ' + src);

      img.attr('src', src);
    };


    bires.downloader.prototype.success = function(img){
      var downloader = this;

      this.timer.stop();

      var src = img.attr('src');

      this.log('downloaded: ' + src);
      this.log('elapsed: ' + this.timer.elapsed());

      if(this.debug) img.css({'opacity' : 42});

      var not_too_damn_slow = this.timer.avg() < this.too_damn_slow;

      var more_images_to_load = this.queue.length > 0;

      var keep_downloading = (this.debug || (more_images_to_load && not_too_damn_slow));

      if(keep_downloading){
        if(this.debug){
          setTimeout( function(){ downloader.download() }, this.debug_delay);
        } else {
          this.download();
        }
      }
    };

    bires.downloader.prototype.log = function(string){
      if(this.debug){
        try{ console.log(string) } catch(e){};
      }
    };


  // simple interval timer class
  //
    bires.timer = function(){
      this.time = null;
      this.samples = [];
    };

    bires.timer.prototype.start = function(){
      this.time = (new Date()).getTime();
    };

    bires.timer.prototype.stop = function(){
      var now = (new Date()).getTime();

      var elapsed = now - this.time;
      this.samples.push(elapsed);

      this.time = null;
    };

    bires.timer.prototype.avg = function(){
      var total = 0;

      for(var i = 0; i < this.samples.length; i++){
        total += this.samples[i];
      }

      return(total / this.samples.length);
    };

    bires.timer.prototype.elapsed = function(){
      return(this.samples[this.samples.length - 1]);
    };


  // export bires into the provided namespace
  //
    (namespace || window).bires = bires;

})();

````

<br>
demo:

<div class="flex-video youtube">
<iframe width="640" height="480" src="http://www.youtube.com/embed/Tj0lmwg27EY" frameborder="0" allowfullscreen></iframe>
</div>

