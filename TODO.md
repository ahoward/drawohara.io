todo
----

- better fb survey!
  - ask questsions individually
  - better likert
  - design a panel
  - group subreddits appropriately
  - ensure to use compact tldr
  - better prompt lib

- diabetes, ar15s, and tractors

- fortune 500 survery

- more writing
  - /io/analytical-idealism
    - time, matter etc...
      https://www.linkedin.com/feed/update/urn:li:activity:7283916702977769472/?commentUrn=urn%3Ali%3Acomment%3A(activity%3A7283916702977769472%2C7283940187804483585)&dashCommentUrn=urn%3Ali%3Afsd_comment%3A(7283940187804483585%2Curn%3Ali%3Aactivity%3A7283916702977769472)
  - /nerd/ro
  - /nerd/langs
- arbitary nubmers make meaning



- /stream
  - tumblr-esc
  - needs to be super fast
  - for ppl not seo so, js?
  - https://www.youtube.com/watch?app=desktop&v=hgCqz3l33kU


- autolinks in ro?  gah
  - hardwraps
   - gfm tool






- dotenv
  - encrypt
  - decrypt


- /io
  - basic blog shit
  - meta-bullshit
https://www.linkedin.com/feed/?highlightedUpdateType=COMMENTS_BY_YOUR_NETWORK&highlightedUpdateUrn=urn%3Ali%3Aactivity%3A7283605163066408960

  - la fires
  - https://docs.google.com/document/d/1XHMOcsVu-PPPsAzao0hXKEBp_vL7AbdqC4PpuYJHm1w/edit?tab=t.0


- site.helpers -> Context
  - gsub(/\B(?=(...)*\b)/, ',')
  - fmt

- site.url_for
  - url_for(route, params)
  - url_for(path_info | *args, **kws)

- prototypes


- /nerd
  - /one -> this site
  - /map-dot-rb -> map.rb


- site.helpers in context...

- better ogs
  - random but deterministic ogs
    - md5sum url
    - can i export og?

- cv

- ro/prototypes for content creation



```ruby
  require 'digest'

  def md5_to_integer(input_string)
    # 1. Calculate the MD5 hash
    md5_hash = Digest::MD5.hexdigest(input_string)

    # 2. Convert the hexadecimal hash to an integer.
    #    We use base 16 (hexadecimal) for the conversion.
    md5_integer = md5_hash.to_i(16)

    return md5_integer
  end

  # Example usage:
  test_string1 = "This is a test string."
  test_string2 = "This is another test string."
  test_string3 = "This is a test string." # Same as test_string1

  integer1 = md5_to_integer(test_string1)
  integer2 = md5_to_integer(test_string2)
  integer3 = md5_to_integer(test_string3)

  puts "String 1: #{test_string1}"
  puts "MD5 Integer 1: #{integer1}"

  puts "\nString 2: #{test_string2}"
  puts "MD5 Integer 2: #{integer2}"

  puts "\nString 3 (same as String 1): #{test_string3}"
  puts "MD5 Integer 3: #{integer3}"

  puts "\nAre integer1 and integer3 equal? #{integer1 == integer3}" # Should be
  true

  # Example demonstrating a potential issue with large integers
  very_long_string = "a" * 10000 # create a very long string
  long_string_int = md5_to_integer(very_long_string)
  puts "\nVery Long String MD5 Integer: #{long_string_int}"
  puts "Class of Integer: #{long_string_int.class}" # Bignum in Ruby if the
  number is too big to fit in a Fixnum

  puts "\nDemonstrating Modulo to get a smaller integer:"
  smaller_int = md5_to_integer(test_string1) % 1000 # Modulo 1000 gets the last
  3 digits in decimal
  puts "Smaller Integer (modulo 1000): #{smaller_int}"

  smaller_int_large_mod = md5_to_integer(very_long_string) % (2**32) # Modulo
  2^32 to get a 32-bit integer
  puts "Smaller Integer (modulo 2^32): #{smaller_int_large_mod}"
  puts "Class of Smaller Integer (modulo 2^32): #{smaller_int_large_mod.class}"
```

- /now

- /music


- extract fabula
  - site.url_for

- utf8ify


- auto-translation!
  - centralize lang config via site.data.langs, or similar


next
----
- Site.root (ro, dato)... etc.
- re-org site lib
- site uses map.rb througout?
- custom reloader for ./bin/serve


- purl model
  - purl as shortcode?
  - /[0-9]+ -> shortcode === purl










- better reloader, pure listen
- reorg lib

- paginattion?

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


done
----
- https://search.google.com/search-console/sitemaps?resource_id=sc-domain%3Adrawohara.io
- nothing but ctx + data in views...
- fix translations!
- clean up goto
  - sitemap.txt
  - sitemap/
    - https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap#text
- /rubygems
  - export og:
- mygems
  - https://rubygems.org/dashboard
  - gem search --remote "^.*$" --details | tee gem-details.oe
- /now
  - ro.page
  - promote threat.ceo
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
