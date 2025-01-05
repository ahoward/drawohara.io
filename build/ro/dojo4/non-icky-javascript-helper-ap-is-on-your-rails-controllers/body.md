ref: https://gist.github.com/ahoward/5752290

web apps nearly always end up needing a plethora of little javascript helper methods: you know, auto-complete forms, populating defaults, validations, etc.  these aren't API calls properly, just little tidbits of functionality needed to make the views work.

there is always a question of which controller to hang these methods off of.  do you make a global helper controller for all this stuff?  do you hang them off the controller in question?  how to do share the backend of javascript helper methods across controllers?


<h2>step one</h2>

include the RPC module in your ApplicationController

````ruby

  class ApplicationController < ::ActionController::Base
    include RPC
  end

````

<h2>step two</h2>

in controllers, declare rpc helper methods

````ruby

  class PostsController < ApplicationController
    rpc(:defaults) do |params|
      post = Post.new(params)
      post.set_defaults!
      post.as_json
    end
  end

````

<h2>step three</h2>

setup js to be able to call rpc methods *relative* to the current controller

````javascript

  // in file: app/views/layouts/application.html.erb
  //
  // notice the *relative* url rpc endpoint
  //

  // <script>
  
    jQuery(function(){

        var rpc = function(){
        // parse args
        //
          var args = Array.prototype.slice.call(arguments);
          var ajax;
          var method;

          if(args.length == 1 && typeof(args[0]) == 'object'){
            ajax = args.shift();
          } else {
            ajax = {};

            for(var i = 0; i < args.length; i++){
              var arg = args[i];

              switch (typeof(arg)) {
                case 'object':
                  ajax['data'] = arg;
                  break;
                case 'function':
                  ajax['success'] = arg;
                  break;
                case 'string':
                  method = arg;
                  break;
              };
            }
          };

        // normalize ajax options
        //
          ajax['url'] = ajax['url'] || rpc['url'];

          method = method || ajax['method'];
          delete ajax['method'];

          ajax['data'] = ajax['data'] || {};
          ajax['data']['method'] = method;

          ajax['async']          = true;
          ajax['type']           = 'GET';
          ajax['dataType']       = 'json';
          ajax['cache']          = false;
          ajax['contentType']    = 'application/json; charset = utf-8';

          var result = ajax;

        // ajax request - using callback or returning the result sync style
        //
          if(!ajax['success']){
            ajax['async'] = false;
            ajax['success'] = function(response){ result = response };
          };

          jQuery.ajax(ajax);

          return(result);
        };
        
        
        rpc['url'] = <%= raw url_for(:action => :rpc).to_json %>;
        
        
        window.rpc = rpc;



    });
  
  // </script>

````

<h2>step four</h2>

enable the rpc endpoints in config/routes.rb

````ruby

  resources :posts do
    collection do
      get 'rpc'
    end
  end

````


<h2>step five</h2>

now you can use relative js rpc helpers at will in your views

````ruby

  var title = $('#title');
  var slug = $('#slug');

  title.change(function(){
    var value = title.val();
    
    var data = {'title' : value};
    
    var success = function(defaults){
      slug.val(defaults['slug']);
    };
        
    rpc('defaults', data, success);
  });
  
````

this organization keeps your code clean by avoiding a proliferation of controllers and prevents the need to litter clean resourceful controllers with loads of fugly js helper actions

  

here is the code in it's entirety

````ruby

  # file : ./lib/rpc.rb

  module RPC
    Actions =
      Hash.new{|hash, controller| hash[controller] = Hash.new}

    module ClassMethods
      def rpc(method = nil, &block)
        case
          when method.nil? && block.nil?
            Actions

          else
            controller = self
            method     = method.to_s

            Actions[controller][method] = block
        end
      end
    end

    module InstanceMethods
      def rpc
        method  = params.delete(:method) || params.delete(:call)

        if method
          controllers = self.class.ancestors.select{|controller| controller <= ::ApplicationController}

          controllers.each do |controller|
            action = Actions[controller][method]

            if action
              result = action.call(params)
              render(:json => result.to_json)
              return
            end
          end

          render(:nothing => true, :status => :not_found, :layout => false)
        else
          render(:json => RPC.index)
        end
      end
    end

    def RPC.index
      Hash.new.tap do |methods|
        Actions.each do |controller, actions|
          controller = controller.name.underscore
          methods[controller] = []

          actions.each do |method, block|
            methods[controller].push(method)
          end
        end
      end
    end

    def RPC.included(other)
      super
    ensure
      other.send(:extend, ClassMethods)
      other.send(:include, InstanceMethods)
    end
  end


````
