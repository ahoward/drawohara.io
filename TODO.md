now
---

- write!
- /about
- /contact

- short-codes ala hugo

- feedback
  - if pending
    - tell me why i shoudln't write this
  - else
    - tell me why you hate this

- nuke thrust?


- re-org + model layer // pages

- bin/dev
  - raw tmux from mtf


- start gem 'fabula'
- insta page

- named routes...
  - site.url_for(:page, id: '/about')

- cleaner cmd structure

- fix ruby install / ssl / thrust



- consolidate script/cmd pattern
- analytics
- silly reloading in dev
- support for APP_ENV, etc.
- support env + senv

- site has domain, not name
- page globs
- pages can be nested.... page.page
- model

- ./site/views
- ./site/models
- support for adding

- content
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

next
----
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
- robots.txt
- humans.txt
- ai.txt
- google analytics
