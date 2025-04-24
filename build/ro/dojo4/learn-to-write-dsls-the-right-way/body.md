I was working with a certain popular ruby testing library today to prepare a pull request and hit an issue with it i've hit many times: passing and/or failing tests due to the testing framework itself polluting the hell out of the global namespaces.  Don't believe it?  Check this out:

<br>
<script src="https://gist.github.com/4039805.js?file=polluted.rb.txt"></script>
<br>

the results were produced using this script

<br>
<script src="https://gist.github.com/4039805.js?file=polluted.rb"></script>
<br>

some people have claimed that this will always be a side effect of having nice DSLs, but this is simply not true:


<br>
<script src="https://gist.github.com/4040698.js?file=dsl.rb"></script>
<br>

so, learn how to write DSLs the right way people.  the right way is any way that doesn't dump methods all over ever object and namespace without an *extremely* good reason.

<br>
<br>
"it should read nice" is *not* a good reason.
