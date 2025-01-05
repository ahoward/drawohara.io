With any project, I'm running several programs at once during the development process. This usually results in several tabs in the Terminal app - one for my local server, one for my database, one for my client application, and one for git. (Right now I use a GUI editor (ST2), but I may be reverting to vim soon...) This multiple tab setup re-occurs for each project I'm working on, and I'm usually switching between multiple projects several times a day.

With this multi-tab setup, when I have to switch the project that I'm working on, I have to either open a new Terminal window with its own tabs for that project and deal with having a more than required number of windows open (not an option for a minimalist like myself) or close all of the tabs I have open, only to re-open them all when I switch back to that project.

Well like most days, I learned a clever solution to this problem from the dojo4 wise and all-powerful leader, [Ara](http://dojo4.com/team/ara-t-howard). He uses the GNU [Screen](https://www.gnu.org/software/screen/) program. Within a single Terminal tab, Screen allows you to open multiple "windows" (aka tabs) within the same Terminal tab. Here's how to use it:

```text
# creating and reattaching to a session
screen -S [name] = create a named screen
screen -D -R [name] = reattach to a named screen and detach other people if nec
screen -list = list screens

# (exiting all windows in a screen session will exit that session. However a screen session is a running process, so you can kill it manually.)

# within a screen session:
ctrl-A + ? = help
ctrl-A + " = list windows
ctrl-A + c = create new window
ctrl-A + n = next window
ctrl-A + p = previous window
ctrl-A + A = rename a window

# aliases we use
alias sl='screen -list '
alias sdr='screen -d -r '
alias s='screen -D -R '
alias ss='screen -S'

sdr [name] = reattach to a named screen and detach other people if nec
ss [name] = create a named screen
sl = list screens
```

Another really cool feature of screen is that when you detach from a screen session, all of your windows remain running, and when you re-attach to the screen session, you have all of your windows back at your disposal.

When we discussed this in our office, [Ryan Cook](http://dojo4.com/team/ryan-cook) created a [nice little Ruby helper](https://gist.github.com/cookrn/2711966) to create screen sessions that are named after your current directory.

So my workflow has changed from having multiple tabs in Terminal open to a single tab in Terminal where I re-connect to a screen session for each project I'm working on. That allows me to switch projects extremely quickly and to stop wasting time re-setting up and re-tearing down all of the Terminal tabs I'm using for a project.

Now I just have to convert more things to terminal usage (like my editor) in order to really make the most of screen...