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

following are some sample answers, grouped roughly by category, and feedback to them



fubar doctype
-------------

sample reponses

* No doctype. It makes it difficult to figure out what flavor of HTML it is, which should lead to interesting responses...
* Mixes xhtml style empty tags with HTML tags.




* Inconsistent quoting. Both work, pick one already...


* line 1: DELETE is not an action supported in HTML forms:
* method=delete isn't directly supported in most/any? browsers.o
* forms don't support delete in older browsers
* Method delete
* form method='DELETE' -- that's not allowed

* enctype="multipart/form-data" not enctype="multipart/file-upload"
* enc-type="multipart/file-upload makes no sense if our intention is to DELETE

* text input tags in the first fieldset have the name
* duplicate "" tags. Or two tags with the same name again
* 2 text fields named "tags" only the last one will be used.
* Two inputs with same 'tags' name. Second one would overwrite value of 1st.
* Two inputs with name 'foo' (not self closed)
* text inputs with the same name would override re: inputs w/ name tags
* duplicate assignments to input name='tags'
* duplicate assignments to input name='vehicle'


* No for on the 'Bar:' label.
* unbound label: <label>Bar:...</label> (label for what?)


* readonly input with no value is pointless


* action="./" seems like bad practice to me
* form action is invalid as a unix filepath descriptor -- to submit to the current url remove the action entirely as that is the default


* file upload can't have a value attribute (bad security)
* Fieldset nesting
* file inputs don't take default values -- user must select
* it automatically selects your ~/.bashrc file for upload

* disabled should have quotes around it (also a bad mix of single and double quotes throughout)
* Unclosed options for select dropdown and no text included
* missing quotes around disabled attribute in improper password input declaration


* No type on the password field (nor on email field, but less important there)
* password input should be of type password
* should be <input type='email' name='email' ...>

* disabled=disabled should be disabled


* No text for female option, nor radio button for 'Sex' radio buttons, radio buttons not setup properly for value submission / toggle in group. Its just all bad in that area.
* fieldset "sex" radio buttons are not constructed correctly. should be Male -- tags are used with select lists not radio buttons. All radio buttons in a group need the same name attribute
* radio inputs don't take options, but should instead have the same name w/ different values


* buttons need to be opened and closed -- the submit should be an input instead
* checkboxes with the same name would override re: checkbox inputs w/ name vehicle




