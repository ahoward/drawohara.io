It's pretty easy to configure apache on a single system. It gets a little more interesting if you have multiple vhosts in the configuration. It gets even more fun when you have a complex configuration that includes proxying, URL rewriting and some text substitution.

But still, nothing that an experience system administrator can't handle with a little care.

Until, well, you have to do it again.

This is where tools like [Chef](http://www.opscode.com) and [Puppet](http://puppetlabs.com) come into play. Both tools allow you to declare and define what systems should look like and how they should be configured. Both are powerful and both are being actively used to configure anything from [developer](https://github.com/boxen/boxen) [workstations](https://github.com/atmos/cinderella) to [large deployments of hundred of thousand of machines](http://www.opscode.com/press-releases/facebook-likes-opscode-and-private-chef/).

Just like software, you still need to build and test the configuration that you are building. Your options to do so range from the really expensive (buy one or more servers), to the moderately expensive (run a few instances on EC2) to the really, really cheap. The really, really cheap option would be to build and test your recipies on virtual machine(s) running on your system. This is where [Vagrant](http://www.vagrantup.com/) comes into play.

Vagrant is a wrapper around Oracle's [VirtualBox](https://www.virtualbox.org/) desktop virtualization platform. Vagrant's configuration revolves around a few simple concepts. You have a configuration file named ```Vagrantfile``` at the root of the project. That file holds some basic configuration such as what base box to use for the project and what ports to expose to the host system. And just as important, it can describe how to provision the virtual machine so it fits the needs of your project. While Vagrant supports both Puppet and Chef, I chose to use Chef-Solo to provision this project.

Getting started with Vagrant is simple. The first step is simply to install the ```vagrant``` gem. Just like any other Ruby project, I chose to install ```vagrant``` and a few other gems through Bundler. Here is the resulting ```Gemfile```:

```ruby
source 'https://rubygems.org'

gem 'vagrant'
gem 'librarian'
```

Running ```bundle install``` installed the necessary gems in the project directory. A quick ```rbenv rehash``` made the vagrant executable available to my shell.

The next step was to setup the most basic of Vagrant configuration. I ran ```vagrant init``` and then edited the resulting Vagrantfile to look like this:

```ruby
Vagrant::Config.run do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu-precise-64"
  
  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
end
```

This achieves 2 things. First, it declares the name of the box we are going to build upon and where to find that box. A quick ```vagrant up``` will initially download the base box, import it into the project and boot up the VM. It takes a while to download the box, but it is cached on your system so you do not need to download it again. You can also reuse the same base box if you choose to do so on other projects. Calling ```vagrant halt``` stops the VM and calling ```vagrant destroy```, well, destroys the VM itself.

We still haven't done much to provision our VM though. The next step is to tell Vagrant how to do so.

[Librarian](https://github.com/applicationsonline/librarian) is another nice gem in the lines of Bundler and CocoaPods that allows you to declare what Chef recipes you are using. In our case, a redacted copy of the project's ```Cheffile``` looks like so:

```ruby
#!/usr/bin/env ruby
#^syntax detection

site 'http://community.opscode.com/api/v1'

cookbook 'apt'
cookbook 'apache2', '>= 1.0.0'
cookbook 'rbenv', :git => 'git://github.com/fnichol/chef-rbenv.git', :ref => 'v0.7.2'
cookbook 'ruby_build'
cookbook 'openssh', :git => 'git://github.com/fnichol/chef-openssh.git'
cookbook 'git'
cookbook 'build-essential'
cookbook 'vim'
cookbook 'user'
cookbook 'sudo'
```

The biggest benefit is that you do not need to vendor the cookbooks into your projects. Running ```librarian-chef install``` will pull down the cookbooks and install them under the ```cookbooks``` directory. This also generated a ```Cheffile.lock``` to document which version of the cookbooks were installed.

I was then at a point where I could tell Vagrant to use Chef-Solo to provision the box by updating the ```Vagrantfile```:

```ruby
Vagrant::Config.run do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu-precise-64"
  
  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  
  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding 
  # some recipes and/or roles.
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["cookbooks", "site-cookbooks"]
    chef.add_recipe "apt"
    chef.add_recipe "build-essential"
    chef.add_recipe "ruby_build"
    chef.add_recipe "rbenv::system"
    chef.add_recipe "rbenv::vagrant"
    chef.add_recipe "git"
    chef.add_recipe "user"
    chef.add_recipe "vim"
    chef.add_recipe "sudo"
    chef.add_recipe "openssh"
    chef.add_recipe "apache2"
    
    chef.json = {
      authorization: {
        sudo: {
          passwordless: true,
          groups: ["admin", "sudo"]
        }
      },
      openssh: {
        permit_root_login: "no",
        password_authentication: "yes"
      },
      rbenv: {
        rubies: [ "1.9.3-p327" ],
        upgrade: true,
        global: "1.9.3-p327",
        gems: {
          "1.9.3-p327" => [
            { name: "bundler" },
            { name: "main" },
            { name: "map" },
            { name: "open4" },
            { name: "multi_json" },
            { name: "net-ssh", version: "~> 2.2.0" },
            { name: "aws-sdk" },
            { name: "chef" },
            { name: "ohai" }
          ]
        }
      },
      apache: {
        default_site_enabled: false
      }
    }
  end
end
```

I quickly created a ```site-cookbooks``` directory and started to build the recipes necessary to configure and provision the software required for this part of the project. I was able to quickly apply updated configuration using ```vagrant provision``` or ```vagrant reload``` (if I needed a reboot). I even destroyed the VM that I was working on and reprovisioned it from scratch to make sure that everything was working.

The reward for this effort was to quickly use the same recipes and configuration to configure the actual servers that support this project. I was confident of the result having succesfully built and tested it locally first, just like the code I write. Hence the expression: infrastructure as code.