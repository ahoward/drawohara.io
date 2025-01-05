Sometimes you have some boring repetitive online task or you need to automate some or all of a workflow on a website. Scripting these interactions can prevent us from wasting tons of man hours on mundanely clicking through the same pages on a site.

A lot of us will reach for [Mechanize](http://mechanize.rubyforge.org/) right off the bat. Then you find that the UI for the site you're trying to automate a task for is JavaScript heavy or AJAXy. Now what do you use?

[Phantomjs](http://http://phantomjs.org/) to the rescue. Phantomjs is a fast, easily scriptable, headless WebKit browser. When the job fails for whatever reason, you can snap a screenshot to review. For us this meant emailing it to an admin since the jobs are running on servers and not locally. We are also using [Phantomjs.rb](https://github.com/westoque/phantomjs.rb) to handle the path and output from Phantomjs.

Here's a bit of code from what we are doing.

```
class InvitationAcceptor
  attr_accessor :invitation, :tmpdir

  def initialize(invitation)
    self.invitation = invitation
  end

  def accept!
    fail_image_path = false

    Dir.mktmpdir(invitation.id.to_s) do |tmpdir|
      self.tmpdir = tmpdir

      Phantomjs.inline(js) do |line|
        puts line
        fail_image_path = line.gsub('FAIL:', '').chomp if line.starts_with?('FAIL')
      end

      if fail_image_path
        Mailer.invitaion_failed(invitation, fail_image_path).deliver
      else
        invitation.invitation_accepted!
      end
    end
  end

  private

    def js
      fail_image = "#{tmpdir}/failed.png"

      <<-JS
        // https://github.com/ariya/phantomjs/blob/master/examples/waitfor.js
        function waitFor(testFx, onReady, timeOutMillis) {
          var maxtimeOutMillis = timeOutMillis ? timeOutMillis : 10000,
            start = new Date().getTime(),
            condition = false
          var interval = setInterval(function() {
            if ((new Date().getTime() - start < maxtimeOutMillis) && !condition) {
              condition = (typeof(testFx) === "string" ? eval(testFx) : testFx());
            } else {
              if (! condition) {
                fail()
              } else {
                console.log("'waitFor()' waited " + (new Date().getTime() - start) + "ms.");
                typeof(onReady) === "string" ? eval(onReady) : onReady();
                clearInterval(interval);
              }
            }
          }, 250);
        };

        var page = require('webpage').create(),
          testindex = 0,
          loadInProgress = false,
          tries = 0;

        // this is important for our app because the site we're automating tries to block automation.
        page.settings.userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36'

        var fail = function() {
          // send the fail message and image path to the Ruby script
          console.log("FAIL:#{fail_image}");
          // save the screenshot to the file system so it can be emailed
          page.render("#{fail_image}");
          phantom.exit()
        }

        page.onConsoleMessage = function(msg) {
          console.log(msg);
        };

        page.onLoadStarted = function() {
          loadInProgress = true;
          console.log("load started");
        };

        page.onLoadFinished = function(status) {
          loadInProgress = false;
          console.log("load finished");
        };

        var steps = [
          function() {
            console.log("Load Login Page");

            page.open("#{invitation.invitation_received.subject}")
          },
          function() {
            console.log("Verify the invitation is still valid");

            success = page.evaluate(function() {
              if (null == document.getElementById('hasSomeElement')) {
                return false;
              }

              return true;
            })

            if (! success) {
              fail();
            }

          },
          function() {
            console.log("Enter Credentials");

            page.evaluate(function() {
              document.getElementById('hasSomeElement').checked;
              document.getElementById('hasSomeElement').checked;
              document.getElementById('email').value = '#{invitation.email}';
              document.getElementById('password').value = '#{invitation.password}';
              document.getElementById('login').click();
            });
          },
          function() {
            console.log("Accepting the terms");

            page.evaluate(function() {
              document.getElementById('accept').click()
            });
          },
          function() {
            console.log("Waiting for the JS craziness to complete");

            waitFor(function() {
              return page.evaluate(function() {
                return document.getElementsByClassName('someExpectedContent').length != 0
              });
            }, function() {
              phantom.exit();
            });
          }
        ]

        interval = setInterval(function() {
          if (!loadInProgress && typeof steps[testindex] == "function") {
            steps[testindex]();
            // useful for debugging
            page.render("#{tmpdir}/step" + (testindex + 1) + ".png");
            testindex++;
          }
        }, 250);
      JS
    end

end
```

You can also inject scripts into the page, with [injectJs](http://phantomjs.org/api/webpage/method/inject-js.html) or [includeJs](http://phantomjs.org/api/webpage/method/include-js.html) but I prefer to stick to what is already there or just use the basics to avoid any clashes with what may be in the page already.
