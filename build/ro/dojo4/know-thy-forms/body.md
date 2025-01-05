i stood up a little quiz about html forms today.

ref: https://gist.github.com/ahoward/98591ebc9113bea1cf02

````html

  <!--

    fork this. do not use the internet. take < 10 minutes to find at least 10
    distinct errors on this form. submit your answer in the comments field of
    your fork and email me (ara[at]dojo4.com) the url.

  -->

  <form method='DELETE' ACTION='./' enctype="multipart/file-upload">

    
    <fieldset>
      <legend> tags </legend>

      <input type='text' name='tags' value='foo'/>
      <input type='text' name='tags' value='bar'/>
    </fieldset>

    <label for='foo'>Foo: </label> <input name='foo'> <input name='foo'>

    <label>
      Bar: <input name='bar'>
    </label>




    <input name='email' readonly/>
    <input name='password' disabled=disabled/>

    <input type='file' name='file' value='.bashrc'/>


    <fieldset>
      <legend>Sex</legend>
        <input type="radio" name="sex">
          <option value='male'>Male</option>
          <option value='female'/>
        </input>

      <fieldset>
        <legend>Transportation</legend>
          <input type="checkbox" name="vehicle" value="Bike">I have a bike<br>
          <input type="checkbox" name="vehicle" value="Car">I have a car 
      </fieldset>
    </fieldset>


    <select name='web-develop-skilz'>
      <option value='A'>
      <option value='B'>
      <option value='C'>
      <option value='D'>
      <option value='F'>
    </select>
    

    <hr>
    <button type='submit'>
  </form>

````


the goal of having people skim this completely broken html form was just to
see people's line of thinking with this: the backbone of html interfaces

following are some sample answers, grouped roughly by category, and commentary on each of them


---
### fubar doctype
---

* No doctype. It makes it difficult to figure out what flavor of HTML it is, which should lead to interesting responses...
* Mixes xhtml style empty tags with HTML tags.

for sure most people missed that many errors depended on the doctype
declaration.  what style of tags you may use depends entirely on the doctype.



---
### method=delete
---

* line 1: DELETE is not an action supported in HTML forms:
* method=delete isn't directly supported in most/any? browsers.o
* forms don't support delete in older browsers
* Method delete
* form method='DELETE' -- that's not allowed

although we think about http verbs with client apis, including javascript.
for a majority of browsers you get GET and POST.   this is important if you've
been considering an xhtml based api.



---
### enctype=bunk
---

* enctype="multipart/form-data" not enctype="multipart/file-upload"
* enc-type="multipart/file-upload makes no sense if our intention is to DELETE

enctype bugs always waste a day.  get it wrong and you'll waste the day
posting the name of your file as a string, instead of the actual encoded file
contents.  also important to note is that the enctype merely dictates how the
form is encoded and is fully orthogonal to the http verb used.



---
### input=foo && input=foo
---

* text input tags in the first fieldset have the name
* duplicate "" tags. Or two tags with the same name again
* 2 text fields named "tags" only the last one will be used.
* Two inputs with same 'tags' name. Second one would overwrite value of 1st.
* Two inputs with name 'foo' (not self closed)
* text inputs with the same name would override re: inputs w/ name tags
* duplicate assignments to input name='tags'
* duplicate assignments to input name='vehicle'


lot's of misperceptions on this one.  it is *totally legit* to post the same
parameter > 1 times in a form.  the spec supports it and even ancient cgi
support the notion of posting multiple values under the same key.  it is
merely convention that many controllers dump these into a hash where 'last in
wins'

you can prove this easily to yourself.  post this from a form


````html

  <input name='answer' value='40'>
  <input name='answer' value='2'>
      
  
````

and you'll see the following in the browser console

<img
style ='max-height:420px;' src='http://cl.ly/image/3I2Q2v0D1B1G/Screen%20Shot%202013-06-17%20at%204.09.23%20PM.png'
>


if you handle the form post like so

````ruby

  def form
    return if request.get?
    
    parsed = Parser.new(env).parse
    
    render :json => parsed.as_json, :layout => true
  end


# hack the rack parser to show that http DOES post multiple values
# and that, if we want, we could accumulate them
#
  class Parser < Rack::Multipart::Parser
    def setup_parse
      super
    ensure
      @params = KeyList.new
    end

    class KeyList
      def initialize(*args, &block)
        @params = {}
      end
      
      def [](key)
        @params[key]
      end
      
      def []=(key, value)
        (@params[key] ||= []).push(value)
      end
      
      def key?(key)
        @params.key?(key)
      end
      
      def to_params_hash()
        self
      end
    end
  end


````

then you will get a response that looks like


````javascript


  {"params":{"answer":["40","2"]}}



````

#### TL:DR;

your web stack may drop multiple values on the floor by loading a hash,
but ruby's cgi.rb library, and http generally does *not*.  this applies to
inputs, checkboxen, etc - anything with name can pass multiple values.

in particular ruby's cgi.rb does *not* limit posting multiple values under a key

while rails *does*



---
### labels are blargh
---

* No for on the 'Bar:' label.
* unbound label: <label>Bar:...</label> (label for what?)

labels without a for are *totally legit*.  when you wrap an input with a label the 'for' is implied as being the contained input. these are equivalent


````html

<label for='foo'>Foo</label> <input name='foo'>

<label for='foo'>Foo <input name='foo'></label>


````


with the former being *much* simpler to deal with in js ( $label.find('input') )


````javascript

 $label.find('input')
 

````

vs.


````javascript
 
  var name = $label.attr('for');
  
  $input = $('name[' + name ']');
 

````



---
### readonly and disabled are the hardz
---

* readonly input with no value is pointless
* disabled should have quotes around it (also a bad mix of single and double quotes throughout)
* missing quotes around disabled attribute in improper password input declaration
* disabled=disabled should be disabled
* missing quotes around disabled attribute

readonly and disabled are both *boolean* attributes and, as such, have both
quoted/non-quoted and valued/non-valued permutations

all these are fine


````html

  <input readonly>
  <input readonly=readonly>
  <input readonly="readonly">


````

although being consistent and using quotes is more widely handled in text editors


refs:

* http://www.whatwg.org/specs/web-apps/current-work/multipage/common-input-element-attributes.html#the-readonly-attribute
* http://www.whatwg.org/specs/web-apps/current-work/multipage/common-microsyntaxes.html#boolean-attribute



---
### form[action]
---

* action="./" seems like bad practice to me
* form action is invalid as a unix filepath descriptor -- to submit to the current url remove the action entirely as that is the default

relative actions are not only totally legit, but useful.  consider a login form
used both for general users under /login that's also used under /admin/login:
in this case it may be quite useful for a form to post back relative to it's
controller



---
### file[value=]
---

* file upload can't have a value attribute (bad security)
* file inputs don't take default values -- user must select
* it automatically selects your ~/.bashrc file for upload

file inputs cannot have deafult values, and must be posted via form with the proper enctype



---
### input[type=]
---

* improper password input declaration
* No type on the password field (nor on email field, but less important there)
* password input should be of type password
* should be input type='email' name='email'

yup, gotta have the correct type on those inputs to mask passwords, pop up
email keyboard, all sorts of goodies.  html5 introduces many new types.  now
'em!




---
### radio/select/options/checkboxes are teh hardz
---

* No text for female option, nor radio button for 'Sex' radio buttons, radio buttons not setup properly for value submission / toggle in group. Its just all bad in that area.
* fieldset "sex" radio buttons are not constructed correctly. should be Male -- tags are used with select lists not radio buttons. All radio buttons in a group need the same name attribute
* radio inputs don't take options, but should instead have the same name w/ different values
* checkboxes with the same name would override re: checkbox inputs w/ name vehicle


checkboxes pass values *only if* the box is checked and, like other form
elements, case easily pass in multiple values under the same name.  it's only
because rails' stuff them into a hash that this appears not to be true.

in general, don't rely on helpers to generate the correct html for you. learn
how radio buttons, checkboxen, and selects work under the hood.


---
### chickens
---


![img](assets/chickens.jpeg)

