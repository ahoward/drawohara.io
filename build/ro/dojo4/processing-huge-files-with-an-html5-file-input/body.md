I was playing with some code that required processing a huge file (> 600 mb) with an html5 file input type.  It took some playing before I discovered how to process a huge file without crashing the browser.  Here's the gist of it:

````html

  <!--

  doing a large chunked upload of content using html5's file input feature is tricky.
  
  this simple example should help you out.

-->

<br>
<br>
<br>
<hr>

<center>
  <blink>
    <input type='file' name='file' id='file' />
    <br>
    <div id='progress' />
  </blink>
</center>

<script>
  jQuery('#file').change(function(){
    var file = document.getElementById('file').files[0];
    var progress = jQuery('#progress');

    if(file){
      var reader = new FileReader();
      var size = file.size;
      var chunk_size = Math.pow(2, 13);
      var chunks = [];

      var offset = 0;
      var bytes = 0;


      reader.onloadend = function(e){
        if (e.target.readyState == FileReader.DONE){
          var chunk = e.target.result;
          bytes += chunk.length;

          chunks.push(chunk);

          progress.html(chunks.length + ' chunks // ' + bytes + ' bytes...');

          if((offset < size)){
            offset += chunk_size;
            var blob = file.slice(offset, offset + chunk_size);

            reader.readAsText(blob);

          } else {
            progress.html("processing teh content...");

            var content = chunks.join("");

            alert("content is ready!");
            debugger;
          };
        }



      };

      var blob = file.slice(offset, offset + chunk_size);
      reader.readAsText(blob);
    }
  });
</script>



````

ref: https://gist.github.com/4394394