

github recently switched to an https scheme as the default for cloning repos.  as a side effect you may suddenly be prompted for a 'Username' and 'Password' when you push where, previously, you were able to do so without typing in credentials.  the solution is to cause git to cache https credentials which is easy, since git uses curl under the covers

in your home directory create a file called '.netrc', for example

/Users/ahoward/.netrc


in it put these contents

<pre>
machine github.com
login YOUR_GITHUB_USERNAME
password YOUR_GITHUB_PASSWORD

</pre>

fixed!

ref: https://gist.github.com/2885020