todo
----
- the nerd blog
- auto-translation!

next
----

- ontology

  /home
  /more
  /nerd
  /dojo4
  /projects
  /drivel
  /essays
  /now
  /music

  /pbr
    ... indexes slowly

  /io/1
    - short-codes ala hugo

- paginattion?  na

  /drivel/
  /drivel/:id


- bin/dev
  - raw tmux from mtf
  - server
  - tunnel
  - editor

- extra gem 'fabula'

- named routes...
  - site.url_for(:page, id: '/about')

- cleaner cmd structure
  - consolidate script/cmd pattern

- silly stupid reloading in dev
  - support for APP_ENV, etc.
  - support env + senv

- photos / galleries
  - basic pages
    - index
    - now
    - about
  - import old dojo4 site
  - way to import a google-photos album
    - rclone -> gcs -> cloudinary

- cloudinary for images and shares
  - https://cloudinary.com/documentation/solution_overview#storage

- quick share cmd
  - drawohara
    - drwhr share ./path/to/file
    - upload to gcs
    - pull url through cloudinary
    - all shares are uuid
    - add to list?
    - migrate lazily into site

- htmx stuff
- alpinejs
- import content from gh-issues

- short-codes // purls that share well
  ```txt

    https://gohugo.io/content-management/urls/#aliases

    <!DOCTYPE html>
    <html lang="en-us">
      <head>
        <title>https://example.org/posts/new-file-name/</title>
        <link rel="canonical" href="https://example.org/posts/new-file-name/">
        <meta name="robots" content="noindex">
        <meta charset="utf-8">
        <meta http-equiv="refresh" content="0; url=https://example.org/posts/new-file-name/">
      </head>
    </html>

  ```

- integrate short form content
  - cli
  - gh-issues
  - socials?


done
----
- purls...
- a model layer
  - Page.home
  - Page.toplevel
  - Page.other
- robots.txt
- humans.txt
- ai.txt
- google analytics
- ssl-proxy w/caddy
- feedback
  - if pending
    - tell me why i shoudln't write this
  - else
    - tell me why you hate this
