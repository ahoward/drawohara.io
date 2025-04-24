(This post originally appears on Spike's [Stuff... And Things... blog](http://stuff-things.net/))

I occasionally write about encryption in Ruby, yet somehow I haven't managed to cover the Dojo's own [Ara's](https://github.com/ahoward) [Sekrets](https://github.com/ahoward/sekrets) gem.

Sekrets provides a simple interface to create and manage encrypted files in Ruby. It's raison d'&ecirc;tre is to make it reasonably painless to store sensitive data, API keys and the like, in Git repos and then access that data inside your Rails app, both in development and production.  <!-- more --> Like all good gems, it just need to be added to your Gemfile:

```ruby
gem 'sekrets'
```

And followed up with `bundle install`. This will add a couple of *rake* tasks, start with:

```
rake sekrets:generate:key
```

This creates a `.sekrets.key` file in application's root directory. It contains a randomly generated password and is what will allow us to automatically decrypt the encrypted configuration file. If you work with a team, you might want to replace that password with something more easily communicated, just do so before you run the next step.

We want this file to exist in development, and to be available to our deploy, but putting it in the Git repo would defeat the purpose, so this step also adds `.sekrets.key` to your `.gitignore`.

To reiterate, `.sekrets.key` should not be committed to your repo.

Next run:

```
rake sekrets:generate:config
```

This creates `config/sekrets.yml.enc`, encrypted with the key in `.sekrets.key` and sets up `config/initializers/sekrets.rb`.

`config/sekrets.yml.enc` is an encrypted YAML file. This is where you store whatever data we wish to keep secret:

```yaml
---
api_key: 42
aws:
  access_key_id: XXXXXXXXXXXXXXXXXXXX
  secret_access_key: YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
the_list_of_my_enemies: ['Bob','Kevin','Stuart']
winter_is_coming: true
```

You can edit the file with:

```
sekrets edit config/sekrets.yml.enc
```

Or view it with:

```
sekrets read config/sekrets.yml.enc
```


The initializer sets up a global constant `SEKRETS`. If the `.sekrets.key` file exists, then it's populated with the values from `config/sekrets.yml.enc`:

```ruby
SEKRETS[:aws]
=> {"access_key_id"=>"XXXXXXXXXXXXXXXXXXXX",
    "secret_access_key"=>"YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"}
```

(SEKRETS is actually a [Map](https://github.com/ahoward/map), a kind of smart Hash, so you can also get values by method `SEKRETS.aws` or `SEKRETS.winter_is_coming?`)

Now all that sensitive data your app needs is in the repo and moves around with it. However, if someone gets access to the repo, without the key, they still don't have access to your secrets. All you need do when bringing on a new developer is have them put the key in the `.sekrets.key` file on their local machine.

That takes care of development, what about production? Sekrets gives you two options. First, you can set `SEKRETS_KEY` in your web servers environment, in much the same way people typically make sensitive information available outside of their code base. Alternatively, if you use Capistrano, you can add `require 'sekrets/capistrano'` to your `Capfile`. This adds a task that copies the `.sekrets.key` to the server on deploy.

With either method, when the App boots, Sekrets will find it's key, decrypt the config file and set up the `SEKRETS` constant.

It should be obvious, that your sekrets, sorry, secrets are only as secure as your server. Someone with access to the server can recover the `SEKRETS_KEY` environmental variable or `.sekrets.key` file and use it to decrypt the sekrets.

However, this is really no different than the common approach of putting sensitive things, like API keys, in the web server environment and accessing them through `ENV` in the app. In fact, setting `SEKRETS_KEY` in environment is exactly the same approach.

Ultimately, if sensitive data is on the server and in a form that can be accessed by your software, then it's only as secure as the server. Sekrets doens't solve that problem. What it does do is get that data under revision control in a secure way and simplify sharing that data between developers. And that's a big win.
