ref: https://github.com/ahoward/sekrets

<pre>

NAME
  sekrets.rb

SYNOPSIS
  sekrets is a command line tool and library used to securely manage encrypted
  files and settings in your rails' applications and git repositories.

INSTALL
  gem install sekrets
  gem 'sekrets'

DESCRIPTION
  TL;DR
    # create an encrypted config file
    
      ruby -r yaml -e'puts({:api_key => 1234}.to_yaml)' | sekrets write config/settings.yml.enc --key 42

    # display it

      sekrets read config/settings.yml.enc --key 42

    # edit it

      sekrets edit config/settings.yml.enc --key 42

    # see that it's encrypted

      cat config/settings.yml.enc

    # commit it

      git add config/settings.yml.enc

    # put the decryption key in a file
      
      echo 42 > .sekrets.key

    # ignore this file in git

      echo .sekrets.key >> .gitgnore

    # you now no longer need to provide the --key argument to commands

      sekrets read config/settings.yml.enc

      sekrets edit config/settings.yml.enc

    # make sure this file gets deployed on your server

      echo " require 'sekrets/capistrano' " >> Capfile

    # commit and deploy

      git add config/settings.yml.enc
      git commit -am'encrypted settings yo'
      git pull && git push && cap staging deploy

    # access these settings in your application code

      settings = Sekrets.settings_for('./config/settings.yml.enc')
      

  DESCRIPTION
    sekrets provides commandline tools and a library to manage and access
    encrypted files in your code base.

    it allows one to check encrypted infomation into a repository and to manage
    it alongside the rest of the code base.  it elimnates the need to check in
    unencrypted information, keys, or other sensitive infomation.

    sekrets provides both a general mechanism for managing arbitrary encrypted
    files and a specific mechanism for managing encrypted config files.


  KEY LOOKUP
    for *all* operations, from the command line or otherwise, sekrets uses the
    following algorithm to search for a decryption key:

    - any key passed directly as a parameter to a library call will be preferred

    - otherwise the code looks for a companion key file.  for example, given the
      file 'config/sekrets.yml.enc' sekrets will look for a key at
      
        config/.sekrets.yml.enc.key
        
      if either of these is found to be non-empty the contents of the file will
      be used as the decryption key for that file.  you should *never* commit
      these key files and also add them to your .gitignore - or similar.

    - next a project key file is looked for.  the path of this file is
      
        ./.sekrets.key
        
      normally and, in a rails' application

        RAILS_ROOT/.sekrets.key

    - if that is not found sekrets looks for the key in the environment under
      the env var

        SEKRETS_KEY

      the env var used is configurable in the library

    - next the global key file is search for, the path of this file is

        ~/.sekrets.key

    - finally, if no key has yet been specified or found, the user is prompted
      to input the key.  prompt only occurs if the user us attached to a tty.
      so, for example, no prompt will hang and application being started in the
      background such as a rails' application being managed by passenger.
   

    see Sekrets.key_for for more details

  KEY DISTRIBUTION
    sekrets does *not* attempt to solve the key distribution problem for you,
    with one exception:
    
    if you are using capistrano to do a 'vanilla' ssh based deploy a simple
    recipe is provided which will detect a local keyfile and scp it onto the
    remote server(s) on deploy.

    sekrets assumes that the local keyfile, if it exists, is correct.

    in plain english the capistrano recipe does:

      scp ./sekrets.key deploy@remote.host.com:/rails_root/current/sekrets.key

    it goes without saying that the local keyfile should *never* be checked in
    and also should be in .gitignore

    distribution of this key among developers is outside the scope of the
    library.  likely unencrypted email is the best mechanism for distribution
    ;-/

</pre>