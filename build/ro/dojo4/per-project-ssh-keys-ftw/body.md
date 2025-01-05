With Rails + Capistrano deployments this setting

```ruby

ssh_options[:forward_agent] = true

```

is pretty much the de-facto and sane default.  It uses all your ssh key goodness for all commands, making most remote actions 'Just Work ™'

However, there are times when this can be confusing, for instance, when you have two keys loaded in ssh-agent that map to different github or bitbucket accounts.  Which account you get will be a fun little game to figure out ;-/

The following very simple strategy lets you check in *per project* ssh keys in a very natural way, and then to  have capistrano respect those keys for all 'cap XXX' operations.

First, you'll want to create an .ssh/ directory in your project, them dump any relevant keys in there.  You can have many pairs, just be sure they are named using the normal *.id_rsa convention.

```bash

a:~/git/dojo4/rails_app_m $ ls .ssh
id_rsa.dojo4            id_rsa.dojo4.pub

```

Next you'll want something like this in your Capfile, which detects these local keys, if present, and uses them via a temporary ssh-agent - otherwise falling back to your global ssh-agent loaded keys.

```ruby

# if this project has an .ssh/ directory, use those keys for deployment.
# otherwise use the global ones.  local keys are utilized by firing up
# a temporary ssh-agent and adding those local keys to it.
#
# likely you'd have a key(s) that allowed access to a particular host and repo
# (github, bitbucket, etc) in your local .ssh directory.
#
# prolly you want to .gitignore .ssh/ !
#
  dot_ssh = File.expand_path("#{ rails_root }/.ssh", __FILE__)

  globs = [
    File.join(dot_ssh, "*id_rsa"),
    File.join(dot_ssh, "id_rsa*"),
  ]

  ssh_keys = [
    ENV['SSH_KEYS'], globs.map{|glob| Dir.glob(glob)}
  ].join(' ').scan(/[^\s]+/).delete_if{|ssh_key| ssh_key =~ /\.pub$/}

  unless ssh_keys.empty?
    require 'session'

    sh = Session::Sh.new
    at_exit{ sh.close }
    sh.execute 'eval `ssh-agent -s -t 3600`'

    ssh_auth_sock = sh.execute('echo $SSH_AUTH_SOCK').first.to_s.strip
    ssh_agent_pid = sh.execute('echo $SSH_AGENT_PID').first.to_s.strip

    ENV['SSH_AUTH_SOCK'] = ssh_auth_sock
    ENV['SSH_AGENT_PID'] = ssh_agent_pid

    ssh_keys.each do |ssh_key|
      if system "SSH_AUTH_SOCK=#{ ssh_auth_sock } ssh-add #{ ssh_key.inspect } >/dev/null 2>&1"
        Say.say("Using ssh-key #{ ssh_key.inspect }", :color => :green)
      else
        Say.say("Cound not add  ssh-key #{ ssh_key.inspect }", :color => :red)
      end
    end
  end

# the only sane thing is to always forward your local, or global, agent
#
  ssh_options[:forward_agent] = true

```

You'll need the session gem in you Gemfile of course

```ruby

# file: Gemfile

gem 'session'


```

And don't forget to .gitignore you fancy new .ssh setup

```bash

# file: .gitignore

.ssh/*


```


There really isn't that much more to it: now you can setup *per project* ssh keys, knowing any *cap deploy xxx* commands will use these project local keys, and still be able to pollute your normal ssh-agent to your heart's content.
