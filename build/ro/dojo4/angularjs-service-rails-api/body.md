Recently I had to dive into AngularJS on a Rails site we were building for a client. In addition to page content, the client has certain pages which display headlines that link to external sources but are pulled into our Rails stack through a rake task that's run periodically. The site is to be cached heavily through use of a CDN, like [CloudFront](http://aws.amazon.com/cloudfront/), but to keep the headlines fresh, we used [AngularJS](https://angularjs.org/) (because the client was familiar with it so easier maintenance for them) to query the rails stack directly for the latest headlines.

This required doing things in a cross domain fashion since the site's domain would be pointed to CloudFront. I hadn't written a Rails API that returned JSONP or an AngularJS service before, so I had to do some exploring and this is what worked for me. _(You can also [read the gist](https://gist.github.com/milesmatthias/fb88c9f066f1c3ab7fae).)_

_Note: If you're not familiar with JSONP, this won't make much sense. [Read this](http://en.wikipedia.org/wiki/JSONP)._

## AngularJS Service

AngularJS has the concept of [services](https://docs.angularjs.org/guide/services), which are just singletons that can be used where ever you need. In our case, you can think of our headlines service as the headlines API client that wraps our JSONP calls in a simpler and centralized syntax. AngularJS provides some services by default, but you can write your own. In fact, we could have used the built-in [`$resource` service](https://docs.angularjs.org/api/ngResource/service/$resource) instead of writing our own, however I had some trouble getting JSONP to work and I wanted to understand the lower level AngularJS components better, so I wrote my own:

```html+erb
angular.module('app')
  .factory('HeadlineService', ['$http',
    function($http) {
      'use strict';
 
      var BASE_URL = "<%= [App.settings.api_base_url, '/services/headlines'].join %>",
          CALLBACK_STRING = "?callback=JSON_CALLBACK";
 
      return {
        getHeadlines: function(){
          return $http.jsonp(BASE_URL + CALLBACK_STRING)
        },
        getHeadlineForId: function(id){
          return $http.jsonp(BASE_URL + "/" + id + ".json" + CALLBACK_STRING)
        }
      }
 
    }
  ]);
```

The service above uses the built-in [`$http` service](https://docs.angularjs.org/api/ng/service/$http), which simply provides an AJAX wrapper, to make requests to our rails backend to get headlines. A couple things to note:

* __It returns an object with 2 functions: `getHeadlines` and `getHeadlineForId`.__ We can then use these functions as shorthands to talk to the Rails API in our AngularJS controllers.
* __It uses JSONP.__ Notice we're using `$http.jsonp` and we're passing a query string `?callback=JSON_CALLBACK`. AngularJS replaces the string `JSON_CALLBACK` with the name of a callback function that it creates for you.
* __It uses a different domain.__ Well that's expected since we're doing JSONP, but we're achieving that by adding an `.erb` extension to the file and using whatever we set for `App.settings.api_base_url` in the Rails app as the domain that AngularJS should talk to. Remember that this is to circumvent the CDN caching layer so our headlines are always the most recent.


## AngularJS Controller

With our `HeadlinesService` built, we can now use the 2 functions it returns in our AngularJS app:

```js
angular.module('app')
  .controller('HeadlinesCtrl', ['$scope', 'HeadlineService',
    function($scope, HeadlineService) {
      'use strict';
 
      HeadlineService.getHeadlines().success(function(data, status, headers, config){
        $scope.headlines = data;
        
        HeadlineService.getHeadlineForId(data[0].id).success(function(data){
          $scope.single_headline = data;
        }).error(function(error, status, headers, config){
          alert('something went wrong getting a headline');
        });
      }).error(function(error, status, headers, config){
        alert('something went wrong getting all the headlines');
      });
    }
  ]);
```

For example purposes, I simply get the full headlines object for the first headline returned in the `getHeadlines` success callback.

The `$scope` object is exposed to the views in AngularJS, so we can display the headlines on the page by having a view like:

```html+erb
<section class="headline_section" ng-controller="HeadlinesCtrl">
 
  <h3>Here are some headlines...</h3>
 
  <div class="headlines">
 
    <ul>
      <li ng-repeat="headline in headlines">
        <a href="{{ headline.url }}" target="_none">{{ headline.title }}</a>
      </li>
    <ul>
 
  </div>
 
  <div class="headline">
    <a href="{{ single_headline.url }}" target="_none">{{ single_headline.title }}</a>
  </div>
 
</section>
```


## Rails Backend

Now that we've got AngularJS calling our Rails backend, we need to write the Rails backend! The following controller is pretty basic ruby on rails, however to return JSONP instead of regular old JSON, we use the `callback` option in the `render` method. That tells Rails that we're using JSONP and to wrap the JSON data we gave it in that callback and set the `Content-Type` header correctly so that everything conforms to the JSONP standard and our AngularJS client can process the data.

```ruby
class Services::HeadlinesController < ApplicationController
 
  def index
    page   = (params[:page] || 1).to_i
    per    = (params[:per]  || 5).to_i
    offset = (page - 1) * per
 
    @headlines = Headline.where(:disabled => false).offset(offset).limit(per).to_a
    render :json => @headlines.to_json, :callback => params[:callback]
  end
 
  def show
    @headline = Headline.find(params[:id])
    if @headline.present?
      render :json => @headline.to_json, :callback => params[:callback]
    else
      render :json => {error: 'no headline found'}.to_json, :callback => params[:callback], :status => 404
    end
  end
 
end
```

And there we have it! A working JSONP-based AngularJS app with a Rails backend. 

[Here's the full gist](https://gist.github.com/milesmatthias/fb88c9f066f1c3ab7fae) if you'd like to read it that way too. If this helped you or you have any questions, let us know on Twitter at [@dojo4](https://twitter.com/intent/tweet?text=@dojo4).

