when working on any non-hello-world rails application you invariably need teeny ajax helpers to communicate with the server - in order to perform client side logic.  i'm not talking an api per-se, but ad-hoc utilities like this:


```javascript

markdown.change(function(){

  generate_html_on_the_server( markdown.val(), function(html){
  
    preview.html(html);
  
  });

});

```

or


```javascript


reservation.change(function(){


  check_availibity_on_the_server( reservation.val(), function(data){
  
    if(!data['available']){
     
     alert('that time is not available - pick another!');
     
    };
  })

});


```

etc.


these types of functions aren't part of a server-to-server public api, they are just cooperating js/backend endpoints that are needed to make the view function.

most rails' applications will accumulate many of these and the question arises:

  "Where do you put them?"
  
in most teams you'll have three or four developers naming and organizing these functions differently, ensuring that the code base turns into a cowboy spaghetti mess in short order.

@dojo4 we've abstracted this with a teeny rpc design pattern:  first we have a teeny controller dsl that's included into our ApplicationController that allows declarative definitions of 'rpc' js helpers on a per-controller basis.

```ruby

class ApplicationController < ActionController::Base

  include(RPC)

end


```

check out the implementation here: https://gist.github.com/ahoward/7320900

in plain english this dsl just defined a single action on the controller that multi-plexes which method to employ based on params, and an easy way to define them.  it expects that all rpc actions will return a hash and give back json.

it's implementation boils down to

```ruby

  def rpc
    which = params['method']
    
    action = @rpc[which]
    
    result = action.call(params)
    
    render :json => result.to_json
  end


```

it's usage should be obvious from the code


```ruby

class GeoLocationController < ApplicationController

  rpc(:geo_location) do |params|
    geo_location = GeoLocation.geo_locate( params['address'] )
    geo_location.attributes
  end
  
  rpc(:lat_lng) do |params|
   geo_location = GeoLocation.geo_locate( params['address'] )
   { 'lat' => geo_location.lat, 'lng' => geo_location.lng }
  end
end


```

usage from js requires two things: a route, and a teeny js class.  first the route:

```ruby

  match ':controller#rpc', :action => 'rpc'
  

```

next, the js, also here -> https://gist.github.com/ahoward/7320900

reading over that you can see that using the backend rpc actions from js is as simpile as


```

  var rpc = new RPC(url);

  rpc.call('geo_location', params, callback);


```

normally, at the bottom of a view, we're just intantiating an rpc object for the page with a relative url

```erb
<script>
  jQuery(function(){
 

    var rpc = new RPC(<%= raw url_for(:action => :rpc).to_json %>);
    
  
  });
  
</script>

```


and we're off and running.

so, there you have it - a simple way to keep your rpc helper js from polluting your controllers and views with varied strategies and another example about how having *brutally consistent* interfaces makes abstraction possible and simple.



update: the entire approach can be summarized like this

```ruby

class BaseController
  RPC = Hash.new

  def self.rpc(method_name, &block)
    RPC[method_name] = block
  end

  def rpc
    method_name = params['method_name']

    block = RPC[method_name]

    result = block.call(params)

    render :json => result
  end
end


class Controller
  rpc :teh_method do
    {'K' => params['k'].upcase}
  end
end


# curl http://0.0.0.0:3000/foo/rpc?method_name=teh_method&k=v  #=> {'K' : 'V'}

```


    

