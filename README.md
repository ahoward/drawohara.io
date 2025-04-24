TL;DR;
------
clearly, this is the repo for https://drawohara.io

however, it's also the basis for my ultra fast, ultra shiny, new ruby static
site builder named [fabula](https://github.com/ahoward/fabular) ... more on
that soon but, in a few weeks, you too will be able to build sites in ruby
that

* build fast AF (see demo below)
* are ultra, [ultra * clean](https://github.com/ahoward/drawohara.io/blob/main/config/site.rb)
* have a sa-weet ass repl
* a *killer* content layer that lets you keep all your content in git [as god * intended](https://github.com/ahoward/ro)

OH HAI REPL
-----------
```sh
drawohara@drawohara.dev:drawohara.io[main] #=> ./script/console 
drawohara.io:001:0> site.name => "drawohara.io"
drawohara.io:002:0> site.ro.pages.first => pages/about
drawohara.io:003:0> site.ro.pages.first.body.to_s.slice(0..42) => "<div class=\"ro markdown\">\n  <p>this is the "
drawohara.io:004:0> site.get('/about').slice(0..42) => "<html color-mode=\"user\" lang=\"en\">\n  <head>"
```

DID I MENTION FAST #AF?
-----------------------
building *this* site looks like this.  it's really, really fast.  way faster than
[rails_build](https://github.com/ahoward/rails_build) which still has its use
cases... rails is back, in case you didn't notice...

it isn't as fast as [hugo](https://gohugo.io/), but it is _very_ fast and so, so, so much nicer to work in.  thank you [matz](https://github.com/matz)!

anyhow, here is the pudding-proof:

```sh
~> ./script/build
```

see [./script/build/](https://github.com/ahoward/drawohara.io/blob/main/script/build)

```txt
==========================================
BUILD ./tmp/019438e5-f406-7e73-b97d-a05bc948bd1e
------------------------------------------
/contact -> /contact.html
/home -> /home.html
/ -> /index.html
/about -> /about.html
/dojo4/archive/30-years-ago-i-said-pager-first-but-no-one-listened -> /dojo4/archive/30-years-ago-i-said-pager-first-but-no-one-listened.html
/dojo4/archive/5-ways-to-make-owning-a-smartphone-less-stupid -> /dojo4/archive/5-ways-to-make-owning-a-smartphone-less-stupid.html
/dojo4/archive/a-bow-and-a-clap -> /dojo4/archive/a-bow-and-a-clap.html
/dojo4/archive/5-benefits-to-becoming-a-b-corp -> /dojo4/archive/5-benefits-to-becoming-a-b-corp.html
/dojo4/archive/a-simple-backup-strategy-for-amazon-cloud-hosts -> /dojo4/archive/a-simple-backup-strategy-for-amazon-cloud-hosts.html
/dojo4/archive/2015-complete-boulder-voter-guide -> /dojo4/archive/2015-complete-boulder-voter-guide.html
/dojo4/archive/a-foray-into-the-edu-domain -> /dojo4/archive/a-foray-into-the-edu-domain.html
/dojo4/archive/4-critical-tools-for-creating-benefit-through-biz -> /dojo4/archive/4-critical-tools-for-creating-benefit-through-biz.html
/dojo4/archive/a-sequel -> /dojo4/archive/a-sequel.html
/dojo4/archive/a-simple-strategy-for-managing-complex-deployments-of-web-applications -> /dojo4/archive/a-simple-strategy-for-managing-complex-deployments-of-web-applications.html
/dojo4/archive/a-splash-of-whimsy-with-your-redesign -> /dojo4/archive/a-splash-of-whimsy-with-your-redesign.html
/dojo4/archive/a-tablet-for-the-future -> /dojo4/archive/a-tablet-for-the-future.html
/dojo4/archive/a-year-of-vinyl-please -> /dojo4/archive/a-year-of-vinyl-please.html
/dojo4/archive/a-sane-image-magick-configuration-for-your-rails-apps -> /dojo4/archive/a-sane-image-magick-configuration-for-your-rails-apps.html
/dojo4/archive/all-in-every-person-is-welcome-here -> /dojo4/archive/all-in-every-person-is-welcome-here.html
/dojo4/archive/2019-dojo4-guide-to-a-better-year-42-tips -> /dojo4/archive/2019-dojo4-guide-to-a-better-year-42-tips.html
/dojo4/archive/all-software-contains-bugs -> /dojo4/archive/all-software-contains-bugs.html
/dojo4/archive/announcing-imbed-the-best-way-to-use-web-content-in-an-i-os-app -> /dojo4/archive/announcing-imbed-the-best-way-to-use-web-content-in-an-i-os-app.html
/dojo4/archive/ann-sekrets-rb-easily-managed-encrypted-data-in-your-rails-applications -> /dojo4/archive/ann-sekrets-rb-easily-managed-encrypted-data-in-your-rails-applications.html
/dojo4/archive/aras-impact-roots-run-deep -> /dojo4/archive/aras-impact-roots-run-deep.html
/dojo4/archive/announcing-lockpick -> /dojo4/archive/announcing-lockpick.html
/dojo4/archive/28-days-of-kindness -> /dojo4/archive/28-days-of-kindness.html
/dojo4/archive/aws-dns-https-doj4-hosting -> /dojo4/archive/aws-dns-https-doj4-hosting.html
/dojo4/archive/assessing-the-b-corp-assessment -> /dojo4/archive/assessing-the-b-corp-assessment.html
/dojo4/archive/aws-ebs-backups-we-rewrote-drebs -> /dojo4/archive/aws-ebs-backups-we-rewrote-drebs.html
/dojo4/archive/awesomesauce-and-awesome-sounds-at-awesome-boulder-party -> /dojo4/archive/awesomesauce-and-awesome-sounds-at-awesome-boulder-party.html
/dojo4/archive/another-quiz -> /dojo4/archive/another-quiz.html
/dojo4/archive/angularjs-service-rails-api -> /dojo4/archive/angularjs-service-rails-api.html
/dojo4/archive/beginning-and-ending-properly -> /dojo4/archive/beginning-and-ending-properly.html
/dojo4/archive/because-we-all-love-to-bicycle -> /dojo4/archive/because-we-all-love-to-bicycle.html
/dojo4/archive/being-open-with-competitors-is-valuable-for-everyone -> /dojo4/archive/being-open-with-competitors-is-valuable-for-everyone.html
/dojo4/archive/a-week-of-commuting-at-dojo4 -> /dojo4/archive/a-week-of-commuting-at-dojo4.html
/dojo4/archive/b-the-certifiable-change -> /dojo4/archive/b-the-certifiable-change.html
/dojo4/archive/be-yourself--or-else -> /dojo4/archive/be-yourself--or-else.html
/dojo4/archive/bigger-paychecks-better-impact -> /dojo4/archive/bigger-paychecks-better-impact.html
/dojo4/archive/bring-the-noise-or-not -> /dojo4/archive/bring-the-noise-or-not.html
/dojo4/archive/better-errors -> /dojo4/archive/better-errors.html
/dojo4/archive/big-boulder-rolling -> /dojo4/archive/big-boulder-rolling.html
/dojo4/archive/brand-new -> /dojo4/archive/brand-new.html
/dojo4/archive/business-advice-from-the-movie-hitch -> /dojo4/archive/business-advice-from-the-movie-hitch.html
/dojo4/archive/buy-some-dojo4-merch -> /dojo4/archive/buy-some-dojo4-merch.html
/dojo4/archive/beginner-tutorial-i-os-certificates-provisioning-profiles -> /dojo4/archive/beginner-tutorial-i-os-certificates-provisioning-profiles.html
/dojo4/archive/chrome-performance-profiling -> /dojo4/archive/chrome-performance-profiling.html
/dojo4/archive/boulder-voter-guide -> /dojo4/archive/boulder-voter-guide.html
/dojo4/archive/chrome-logger -> /dojo4/archive/chrome-logger.html
/dojo4/archive/cheering-for-our-friend-scott-jurek -> /dojo4/archive/cheering-for-our-friend-scott-jurek.html
/dojo4/archive/combine-mongoid-and-resque-for-background-job-pleasure -> /dojo4/archive/combine-mongoid-and-resque-for-background-job-pleasure.html
/dojo4/archive/can-you-build-me-an-app -> /dojo4/archive/can-you-build-me-an-app.html
/dojo4/archive/competition-at-its-best -> /dojo4/archive/competition-at-its-best.html
/dojo4/archive/chop-dojo4-re-envisions-a-calligraphic-element -> /dojo4/archive/chop-dojo4-re-envisions-a-calligraphic-element.html
/dojo4/archive/community-happy-hours-have-begun -> /dojo4/archive/community-happy-hours-have-begun.html
/dojo4/archive/code-and-and-coffee-at-dojo4 -> /dojo4/archive/code-and-and-coffee-at-dojo4.html
/dojo4/archive/contract-this -> /dojo4/archive/contract-this.html
/dojo4/archive/css3-horizontal-rules -> /dojo4/archive/css3-horizontal-rules.html
/dojo4/archive/configuring-the-default-virtual-host-in-apache2 -> /dojo4/archive/configuring-the-default-virtual-host-in-apache2.html
/dojo4/archive/community--dojo4--com -> /dojo4/archive/community--dojo4--com.html
/dojo4/archive/controlling-html5-audio-on-mobile-devices -> /dojo4/archive/controlling-html5-audio-on-mobile-devices.html
/dojo4/archive/culture-at-dojo4 -> /dojo4/archive/culture-at-dojo4.html
/dojo4/archive/death-to-password-committers -> /dojo4/archive/death-to-password-committers.html
/dojo4/archive/disaster -> /dojo4/archive/disaster.html
/dojo4/archive/cooking-up-a-storm-with-vagrant-librarian-and-chef-solo -> /dojo4/archive/cooking-up-a-storm-with-vagrant-librarian-and-chef-solo.html
/dojo4/archive/data-visualization-with-google-sheets-and-d3--js -> /dojo4/archive/data-visualization-with-google-sheets-and-d3--js.html
/dojo4/archive/crap-developers-fear-mongo-and-worship-the-rdbms -> /dojo4/archive/crap-developers-fear-mongo-and-worship-the-rdbms.html
/dojo4/archive/digital-ocean-fast-and-cheap-but-good -> /dojo4/archive/digital-ocean-fast-and-cheap-but-good.html
/dojo4/archive/distraction -> /dojo4/archive/distraction.html
/dojo4/archive/dangling-rpc-fruit-off-of-your-rails-controllers -> /dojo4/archive/dangling-rpc-fruit-off-of-your-rails-controllers.html
/dojo4/archive/dojo4-brands-the-big-boulder-conference -> /dojo4/archive/dojo4-brands-the-big-boulder-conference.html
/dojo4/archive/diy-impact -> /dojo4/archive/diy-impact.html
/dojo4/archive/does-your-company-care-about-the-environment -> /dojo4/archive/does-your-company-care-about-the-environment.html
/dojo4/archive/defeating-the-sticky-wicket-of-api-limits-with-a-javascript-worker-army -> /dojo4/archive/defeating-the-sticky-wicket-of-api-limits-with-a-javascript-worker-army.html
/dojo4/archive/doing-a-good-job -> /dojo4/archive/doing-a-good-job.html
/dojo4/archive/dojo4-hosts-inaugural-diy-coding-101-class -> /dojo4/archive/dojo4-hosts-inaugural-diy-coding-101-class.html
/dojo4/archive/dojo4-ignite-corey-and-giving-a-fuck -> /dojo4/archive/dojo4-ignite-corey-and-giving-a-fuck.html
/dojo4/archive/dojo4-designs-help-make-boulder-the-foodiest-town-in-america -> /dojo4/archive/dojo4-designs-help-make-boulder-the-foodiest-town-in-america.html
/dojo4/archive/dojo4-hosts-young-changemakers-from-around-the-world -> /dojo4/archive/dojo4-hosts-young-changemakers-from-around-the-world.html
/dojo4/archive/dojo4-quiz-2-have-a-go -> /dojo4/archive/dojo4-quiz-2-have-a-go.html
/dojo4/archive/dojo4-supports-boulder-being-even-more-awesome -> /dojo4/archive/dojo4-supports-boulder-being-even-more-awesome.html
/dojo4/archive/dojo4-owns-it-ip-contracts-and-why-we-all-benefit-when-programmers-own-their-ip -> /dojo4/archive/dojo4-owns-it-ip-contracts-and-why-we-all-benefit-when-programmers-own-their-ip.html
/dojo4/archive/dojo4-helps-big-boulder-shine-in-lil-ol-boulder -> /dojo4/archive/dojo4-helps-big-boulder-shine-in-lil-ol-boulder.html
/dojo4/archive/dojo4-takes-a-bat-to-cancer -> /dojo4/archive/dojo4-takes-a-bat-to-cancer.html
/dojo4/archive/driving-user-behavior-with-game-dynamics -> /dojo4/archive/driving-user-behavior-with-game-dynamics.html
/dojo4/archive/dojo4-stands-up-to-cancer -> /dojo4/archive/dojo4-stands-up-to-cancer.html
/dojo4/archive/easy-cheasy-log-rolling-for-teh-rails-appz -> /dojo4/archive/easy-cheasy-log-rolling-for-teh-rails-appz.html
/dojo4/archive/easy-cheasy-realtime-log-tailing-in-a-rails-admin-view -> /dojo4/archive/easy-cheasy-realtime-log-tailing-in-a-rails-admin-view.html
/dojo4/archive/empathy-in-f-oss -> /dojo4/archive/empathy-in-f-oss.html
/dojo4/archive/entrepreneurial-by-nature -> /dojo4/archive/entrepreneurial-by-nature.html
/dojo4/archive/dojo4-s-got-answers -> /dojo4/archive/dojo4-s-got-answers.html
/dojo4/archive/fabrication-illustrated-infographics-and-eli-who-elihuu -> /dojo4/archive/fabrication-illustrated-infographics-and-eli-who-elihuu.html
/dojo4/archive/dojo4-ninja-rescues-boulders-food -> /dojo4/archive/dojo4-ninja-rescues-boulders-food.html
/dojo4/archive/emailadore-on-producthunt -> /dojo4/archive/emailadore-on-producthunt.html
/dojo4/archive/family-friendly-workplace-manifesto-now-more-than-ever -> /dojo4/archive/family-friendly-workplace-manifesto-now-more-than-ever.html
/dojo4/archive/eventually-all-products-merge-into-one-and-a-list-runs-through-it -> /dojo4/archive/eventually-all-products-merge-into-one-and-a-list-runs-through-it.html
/dojo4/archive/dojo4-hosts-the-denver-ad-club-kegs-with-legs-party-on-nov-29-2012 -> /dojo4/archive/dojo4-hosts-the-denver-ad-club-kegs-with-legs-party-on-nov-29-2012.html
/dojo4/archive/filing-cabinets-are-for-suckers -> /dojo4/archive/filing-cabinets-are-for-suckers.html
/dojo4/archive/fancy-shops-harm-start-ups -> /dojo4/archive/fancy-shops-harm-start-ups.html
/dojo4/archive/fix-for-caching-credentials-on-https-github-repos -> /dojo4/archive/fix-for-caching-credentials-on-https-github-repos.html
/dojo4/archive/family-friendly-workplace-manifesto -> /dojo4/archive/family-friendly-workplace-manifesto.html
/dojo4/archive/family-friendly-equals-business-friendly-or-how-to-find-good-people -> /dojo4/archive/family-friendly-equals-business-friendly-or-how-to-find-good-people.html
/dojo4/archive/five-tips-for-obtaining-and-retaining-a-job-at-dojo4 -> /dojo4/archive/five-tips-for-obtaining-and-retaining-a-job-at-dojo4.html
/dojo4/archive/front-end-dependency-management-with-bower-ro-r -> /dojo4/archive/front-end-dependency-management-with-bower-ro-r.html
/dojo4/archive/focus-points-for-change -> /dojo4/archive/focus-points-for-change.html
/dojo4/archive/dojo4-guide-to-a-better-year-42-tips -> /dojo4/archive/dojo4-guide-to-a-better-year-42-tips.html
/dojo4/archive/friday-question -> /dojo4/archive/friday-question.html
/dojo4/archive/fred-jean -> /dojo4/archive/fred-jean.html
/dojo4/archive/from-a-streamlined-startup-stack-to-pci-compliance-on-aws -> /dojo4/archive/from-a-streamlined-startup-stack-to-pci-compliance-on-aws.html
/dojo4/archive/getting-our-kids-in-shape-never-felt-so-good -> /dojo4/archive/getting-our-kids-in-shape-never-felt-so-good.html
/dojo4/archive/geo-near-queries-with-mongoid-3 -> /dojo4/archive/geo-near-queries-with-mongoid-3.html
/dojo4/archive/habits-as-a-conduit-for-change -> /dojo4/archive/habits-as-a-conduit-for-change.html
/dojo4/archive/hackerspaces-r-us -> /dojo4/archive/hackerspaces-r-us.html
/dojo4/archive/girl-effect-accelerator-braindump -> /dojo4/archive/girl-effect-accelerator-braindump.html
/dojo4/archive/generosity-is-an-advantage -> /dojo4/archive/generosity-is-an-advantage.html
/dojo4/archive/hacking-for-civic-good-is-the-new-awesome-boulder-civic-hackfest-2013 -> /dojo4/archive/hacking-for-civic-good-is-the-new-awesome-boulder-civic-hackfest-2013.html
/dojo4/archive/green-the-web-post-number-1-championing-the-conversation-to-a-carbon-neutral-internet -> /dojo4/archive/green-the-web-post-number-1-championing-the-conversation-to-a-carbon-neutral-internet.html
/dojo4/archive/for-a-smoother-ride-let-culture-drive-and-put-operations-in-shotgun -> /dojo4/archive/for-a-smoother-ride-let-culture-drive-and-put-operations-in-shotgun.html
/dojo4/archive/happy-birthday-dojo4 -> /dojo4/archive/happy-birthday-dojo4.html
/dojo4/archive/grief-as-an-entrepreneurial-asset -> /dojo4/archive/grief-as-an-entrepreneurial-asset.html
/dojo4/archive/hands-off-my-window-title -> /dojo4/archive/hands-off-my-window-title.html
/dojo4/archive/getting-stronger -> /dojo4/archive/getting-stronger.html
/dojo4/archive/have-babies-at-dojo4 -> /dojo4/archive/have-babies-at-dojo4.html
/dojo4/archive/hacking-human-suffering-is-the-only-real-growth-industry -> /dojo4/archive/hacking-human-suffering-is-the-only-real-growth-industry.html
/dojo4/archive/harvest-time-calgary-farmers-market -> /dojo4/archive/harvest-time-calgary-farmers-market.html
/dojo4/archive/handcrafted-code-and-design -> /dojo4/archive/handcrafted-code-and-design.html
/dojo4/archive/home-office -> /dojo4/archive/home-office.html
/dojo4/archive/how-did-you-fund-your-education -> /dojo4/archive/how-did-you-fund-your-education.html
/dojo4/archive/hello-hello-moshimoshico-is-all-about-building-broducts -> /dojo4/archive/hello-hello-moshimoshico-is-all-about-building-broducts.html
/dojo4/archive/hey-you-don-t-need-a-cms -> /dojo4/archive/hey-you-don-t-need-a-cms.html
/dojo4/archive/how-to-create-and-apply-a-patch-w-git-across-similar-repositories -> /dojo4/archive/how-to-create-and-apply-a-patch-w-git-across-similar-repositories.html
/dojo4/archive/hello-goodbye-dojo4 -> /dojo4/archive/hello-goodbye-dojo4.html
/dojo4/archive/how-to-fold-a-marketing-site-into-a-web-app -> /dojo4/archive/how-to-fold-a-marketing-site-into-a-web-app.html
/dojo4/archive/hubba-hubba -> /dojo4/archive/hubba-hubba.html
/dojo4/archive/i-emailadore-you -> /dojo4/archive/i-emailadore-you.html
/dojo4/archive/imbed-for-android -> /dojo4/archive/imbed-for-android.html
/dojo4/archive/how-to-get-your-front-end-developers-to-fix-things -> /dojo4/archive/how-to-get-your-front-end-developers-to-fix-things.html
/dojo4/archive/hubbishness -> /dojo4/archive/hubbishness.html
/dojo4/archive/irish-dance-and-wordpress-the-soul-destroyer -> /dojo4/archive/irish-dance-and-wordpress-the-soul-destroyer.html
/dojo4/archive/in-your-minds-browser-clear-your-cache-every-tuesday-morning -> /dojo4/archive/in-your-minds-browser-clear-your-cache-every-tuesday-morning.html
/dojo4/archive/it-s-business-time-10-tips-for-doing-it-better -> /dojo4/archive/it-s-business-time-10-tips-for-doing-it-better.html
/dojo4/archive/impact-project-example-idea -> /dojo4/archive/impact-project-example-idea.html
/dojo4/archive/hubbing-it-in-halifax -> /dojo4/archive/hubbing-it-in-halifax.html
/dojo4/archive/jared-polis-representative-of-hate -> /dojo4/archive/jared-polis-representative-of-hate.html
/dojo4/archive/it-s-in-the-logs-stupid -> /dojo4/archive/it-s-in-the-logs-stupid.html
/dojo4/archive/leadership-we-did-it-ourselves -> /dojo4/archive/leadership-we-did-it-ourselves.html
/dojo4/archive/korean-release-the-click-clean-scorecard -> /dojo4/archive/korean-release-the-click-clean-scorecard.html
/dojo4/archive/lead -> /dojo4/archive/lead.html
/dojo4/archive/learn-to-write-dsls-the-right-way -> /dojo4/archive/learn-to-write-dsls-the-right-way.html
/dojo4/archive/large-files-made-small-coming-to-an-airport-near-you -> /dojo4/archive/large-files-made-small-coming-to-an-airport-near-you.html
/dojo4/archive/leprechauns-love-rainbows -> /dojo4/archive/leprechauns-love-rainbows.html
/dojo4/archive/lean-development-process-sketch -> /dojo4/archive/lean-development-process-sketch.html
/dojo4/archive/luxury-vacations-need-we-say-more -> /dojo4/archive/luxury-vacations-need-we-say-more.html
/dojo4/archive/lets-kill-altruism -> /dojo4/archive/lets-kill-altruism.html
/dojo4/archive/love-is-listening-together -> /dojo4/archive/love-is-listening-together.html
/dojo4/archive/marshal-mongoid-object-like-butter -> /dojo4/archive/marshal-mongoid-object-like-butter.html
/dojo4/archive/if-you-want-to-be-happy-think-of-others -> /dojo4/archive/if-you-want-to-be-happy-think-of-others.html
/dojo4/archive/maintaining-our-urban-professionalism -> /dojo4/archive/maintaining-our-urban-professionalism.html
/dojo4/archive/less-is-more-busyness-vs--effectiveness -> /dojo4/archive/less-is-more-busyness-vs--effectiveness.html
/dojo4/archive/maurizio-the-microsite -> /dojo4/archive/maurizio-the-microsite.html
/dojo4/archive/meditation-doesn-t-actually-do-anything-dojo -> /dojo4/archive/meditation-doesn-t-actually-do-anything-dojo.html
/dojo4/archive/meaningful-connection-equals-purposeful-business -> /dojo4/archive/meaningful-connection-equals-purposeful-business.html
/dojo4/archive/meditation-every-tuesday-morning-the-dojo -> /dojo4/archive/meditation-every-tuesday-morning-the-dojo.html
/dojo4/archive/miles-smiles -> /dojo4/archive/miles-smiles.html
/dojo4/archive/move-to-south-africa-for-the-great-tech-jobs -> /dojo4/archive/move-to-south-africa-for-the-great-tech-jobs.html
/dojo4/archive/never-debug-alone -> /dojo4/archive/never-debug-alone.html
/dojo4/archive/meetings-do-not-need-to-look-like-meetings -> /dojo4/archive/meetings-do-not-need-to-look-like-meetings.html
/dojo4/archive/ncwit-is-making-it-happen -> /dojo4/archive/ncwit-is-making-it-happen.html
/dojo4/archive/never-play-games-other-secrets-to-success-from-dojo4-s-cto -> /dojo4/archive/never-play-games-other-secrets-to-success-from-dojo4-s-cto.html
/dojo4/archive/ninja-problem-solving -> /dojo4/archive/ninja-problem-solving.html
/dojo4/archive/nepal-still-needs-our-help-now -> /dojo4/archive/nepal-still-needs-our-help-now.html
/dojo4/archive/love-and-code-rocky-mountain-ruby-conference-presentation -> /dojo4/archive/love-and-code-rocky-mountain-ruby-conference-presentation.html
/dojo4/archive/number-365poop -> /dojo4/archive/number-365poop.html
/dojo4/archive/multi-domain-https-with-server-name-indication -> /dojo4/archive/multi-domain-https-with-server-name-indication.html
/dojo4/archive/nicer-whenver-for-yer-railzer -> /dojo4/archive/nicer-whenver-for-yer-railzer.html
/dojo4/archive/on-the-floor-at-dojo4 -> /dojo4/archive/on-the-floor-at-dojo4.html
/dojo4/archive/office-dog-makes-twitter-splash -> /dojo4/archive/office-dog-makes-twitter-splash.html
/dojo4/archive/number-number-moment-timezone-has-no-data-for-central-time-us-and-canada -> /dojo4/archive/number-number-moment-timezone-has-no-data-for-central-time-us-and-canada.html
/dojo4/archive/on-the-lip-of-shared-ownership-dojo4-becomes-a-co-op-series-number-3 -> /dojo4/archive/on-the-lip-of-shared-ownership-dojo4-becomes-a-co-op-series-number-3.html
/dojo4/archive/mobile-detection-behind-a-cdn -> /dojo4/archive/mobile-detection-behind-a-cdn.html
/dojo4/archive/know-thy-forms -> /dojo4/archive/know-thy-forms.html
/dojo4/archive/organizational-development-and-leadership-at-dojo4 -> /dojo4/archive/organizational-development-and-leadership-at-dojo4.html
/dojo4/archive/org-dev-dojo -> /dojo4/archive/org-dev-dojo.html
/dojo4/archive/on-the-lip-of-shared-ownership-dojo4-becomes-a-co-op-series-number-1 -> /dojo4/archive/on-the-lip-of-shared-ownership-dojo4-becomes-a-co-op-series-number-1.html
/dojo4/archive/patching-between-git-repos -> /dojo4/archive/patching-between-git-repos.html
/dojo4/archive/perfect-fit-community-gathering-of-young-social-entrepreneurs-at-dojo4 -> /dojo4/archive/perfect-fit-community-gathering-of-young-social-entrepreneurs-at-dojo4.html
/dojo4/archive/our-remote-working-setup -> /dojo4/archive/our-remote-working-setup.html
/dojo4/archive/on-the-lip-of-shared-ownership-dojo4-becomes-a-co-op-series-number-4 -> /dojo4/archive/on-the-lip-of-shared-ownership-dojo4-becomes-a-co-op-series-number-4.html
/dojo4/archive/on-the-lip-of-shared-ownership-dojo4-becomes-a-co-op-series-number-2 -> /dojo4/archive/on-the-lip-of-shared-ownership-dojo4-becomes-a-co-op-series-number-2.html
/dojo4/archive/playing-god-in-the-garden -> /dojo4/archive/playing-god-in-the-garden.html
/dojo4/archive/orgdev-wants-you -> /dojo4/archive/orgdev-wants-you.html
/dojo4/archive/patience-perspective-and-poop-parenting-and-business -> /dojo4/archive/patience-perspective-and-poop-parenting-and-business.html
/dojo4/archive/proud-parents-of-a-future-dojo4er -> /dojo4/archive/proud-parents-of-a-future-dojo4er.html
/dojo4/archive/ports-or-porn-stars -> /dojo4/archive/ports-or-porn-stars.html
/dojo4/archive/random-core-dumps-in-ruby-193-on-osx -> /dojo4/archive/random-core-dumps-in-ruby-193-on-osx.html
/dojo4/archive/reblog-the-jellyfish-model -> /dojo4/archive/reblog-the-jellyfish-model.html
/dojo4/archive/per-project-ssh-keys-ftw -> /dojo4/archive/per-project-ssh-keys-ftw.html
/dojo4/archive/push-it-out-the-window -> /dojo4/archive/push-it-out-the-window.html
/dojo4/archive/relay-twitter-campfire -> /dojo4/archive/relay-twitter-campfire.html
/dojo4/archive/reblog-programming-is-gardening-not-engineering -> /dojo4/archive/reblog-programming-is-gardening-not-engineering.html
/dojo4/archive/processing-huge-files-with-an-html5-file-input -> /dojo4/archive/processing-huge-files-with-an-html5-file-input.html
/dojo4/archive/responding-to-the-everyday-as-it-happens -> /dojo4/archive/responding-to-the-everyday-as-it-happens.html
/dojo4/archive/resque-best-practices -> /dojo4/archive/resque-best-practices.html
/dojo4/archive/responsive-design-is-dead-long-live-responsive-design -> /dojo4/archive/responsive-design-is-dead-long-live-responsive-design.html
/dojo4/archive/rails-to-json -> /dojo4/archive/rails-to-json.html
/dojo4/archive/rising-and-falling-in-business -> /dojo4/archive/rising-and-falling-in-business.html
/dojo4/archive/responsive-against-lung-cancer -> /dojo4/archive/responsive-against-lung-cancer.html
/dojo4/archive/non-icky-javascript-helper-ap-is-on-your-rails-controllers -> /dojo4/archive/non-icky-javascript-helper-ap-is-on-your-rails-controllers.html
/dojo4/archive/running-with-it -> /dojo4/archive/running-with-it.html
/dojo4/archive/running-dropbox-for-multiple-accounts-on-one-machine -> /dojo4/archive/running-dropbox-for-multiple-accounts-on-one-machine.html
/dojo4/archive/saccharine-smiles-and-fishnet-stockings -> /dojo4/archive/saccharine-smiles-and-fishnet-stockings.html
/dojo4/archive/screen-set-up-your-project-s-terminal-environment-once-and-only-once -> /dojo4/archive/screen-set-up-your-project-s-terminal-environment-once-and-only-once.html
/dojo4/archive/simple-essential -> /dojo4/archive/simple-essential.html
/dojo4/archive/shipped-it -> /dojo4/archive/shipped-it.html
/dojo4/archive/sense-of-self-as-commodity -> /dojo4/archive/sense-of-self-as-commodity.html
/dojo4/archive/simple-changes-to-be-more-productive -> /dojo4/archive/simple-changes-to-be-more-productive.html
/dojo4/archive/site-launch-planted-nutrition -> /dojo4/archive/site-launch-planted-nutrition.html
/dojo4/archive/slow-food-slow-tech -> /dojo4/archive/slow-food-slow-tech.html
/dojo4/archive/snuggin -> /dojo4/archive/snuggin.html
/dojo4/archive/snugg-le-up-the-boulder-energy-challenge-community-pitch-night-tommorrow -> /dojo4/archive/snugg-le-up-the-boulder-energy-challenge-community-pitch-night-tommorrow.html
/dojo4/archive/sinskey-vin65-and-dragons -> /dojo4/archive/sinskey-vin65-and-dragons.html
/dojo4/archive/sister-code-5-ways-to-meet-women-halfway -> /dojo4/archive/sister-code-5-ways-to-meet-women-halfway.html
/dojo4/archive/so-long-and-thanks-for-all-the-unicorns -> /dojo4/archive/so-long-and-thanks-for-all-the-unicorns.html
/dojo4/archive/so-you-want-to-change-the-world-we-do-too-by-building-better-businesses-aka-the-little-handbook-for-sturdy-startups -> /dojo4/archive/so-you-want-to-change-the-world-we-do-too-by-building-better-businesses-aka-the-little-handbook-for-sturdy-startups.html
/dojo4/archive/shiny-shiny-markdown -> /dojo4/archive/shiny-shiny-markdown.html
/dojo4/archive/so-you-think-youre-a-web-developer-eh -> /dojo4/archive/so-you-think-youre-a-web-developer-eh.html
/dojo4/archive/program-like-you-give-a-damn -> /dojo4/archive/program-like-you-give-a-damn.html
/dojo4/archive/spine-js-an-experience-a-review -> /dojo4/archive/spine-js-an-experience-a-review.html
/dojo4/archive/spreading-the-good-feels -> /dojo4/archive/spreading-the-good-feels.html
/dojo4/archive/step-1-mmco-status-update-on-purpose -> /dojo4/archive/step-1-mmco-status-update-on-purpose.html
/dojo4/archive/step-0-getting-started-building-a-purposeful-organization -> /dojo4/archive/step-0-getting-started-building-a-purposeful-organization.html
/dojo4/archive/su2c-live-telethon-rawked -> /dojo4/archive/su2c-live-telethon-rawked.html
/dojo4/archive/tagged -> /dojo4/archive/tagged.html
/dojo4/archive/tax-day-is-coming-be-not-afraid -> /dojo4/archive/tax-day-is-coming-be-not-afraid.html
/dojo4/archive/technology-considered-harmful -> /dojo4/archive/technology-considered-harmful.html
/dojo4/archive/speaking-at-hour-of-code -> /dojo4/archive/speaking-at-hour-of-code.html
/dojo4/archive/test-your-b-corp-trivia-knowledge -> /dojo4/archive/test-your-b-corp-trivia-knowledge.html
/dojo4/archive/the-big-pivot -> /dojo4/archive/the-big-pivot.html
/dojo4/archive/the-black-swan-theory -> /dojo4/archive/the-black-swan-theory.html
/dojo4/archive/the-ceo-should-wash-the-dishes -> /dojo4/archive/the-ceo-should-wash-the-dishes.html
/dojo4/archive/the-buffalo-bicycle-classic -> /dojo4/archive/the-buffalo-bicycle-classic.html
/dojo4/archive/the-dojo-is-growing -> /dojo4/archive/the-dojo-is-growing.html
/dojo4/archive/the-calgary-farmer-s-market -> /dojo4/archive/the-calgary-farmer-s-market.html
/dojo4/archive/static-is-the-new-black -> /dojo4/archive/static-is-the-new-black.html
/dojo4/archive/the-manager-and-the-engineer -> /dojo4/archive/the-manager-and-the-engineer.html
/dojo4/archive/the-fear-startups -> /dojo4/archive/the-fear-startups.html
/dojo4/archive/testing-ie9-is-less-like-eating-glass-than-before -> /dojo4/archive/testing-ie9-is-less-like-eating-glass-than-before.html
/dojo4/archive/the-5-mystical-practices-of-great-engineers -> /dojo4/archive/the-5-mystical-practices-of-great-engineers.html
/dojo4/archive/the-mongoid-wars-removing-production-indexes -> /dojo4/archive/the-mongoid-wars-removing-production-indexes.html
/dojo4/archive/the-power-of-passion-projects -> /dojo4/archive/the-power-of-passion-projects.html
/dojo4/archive/the-new-startups-got-heart -> /dojo4/archive/the-new-startups-got-heart.html
/dojo4/archive/size-matters -> /dojo4/archive/size-matters.html
/dojo4/archive/the-sekrets-gem -> /dojo4/archive/the-sekrets-gem.html
/dojo4/archive/the-how-vs-the-what-of-building-meaningful-career-or-why-following-your-bliss-is-a-crock -> /dojo4/archive/the-how-vs-the-what-of-building-meaningful-career-or-why-following-your-bliss-is-a-crock.html
/dojo4/archive/the-problem-with-volunteerism -> /dojo4/archive/the-problem-with-volunteerism.html
/dojo4/archive/the-shadow-world-of-css-tables -> /dojo4/archive/the-shadow-world-of-css-tables.html
/dojo4/archive/the-worlds-simplest-presenter-pattern -> /dojo4/archive/the-worlds-simplest-presenter-pattern.html
/dojo4/archive/threads-are-so-dang-awesome -> /dojo4/archive/threads-are-so-dang-awesome.html
/dojo4/archive/tips-for-mongodb-migrations-in-rails -> /dojo4/archive/tips-for-mongodb-migrations-in-rails.html
/dojo4/archive/this-is-dojo4 -> /dojo4/archive/this-is-dojo4.html
/dojo4/archive/today-s-moment-of-zen -> /dojo4/archive/today-s-moment-of-zen.html
/dojo4/archive/this-blog-posted-from-behind-the-locked-door-of-the-bathroom-at-dojo4 -> /dojo4/archive/this-blog-posted-from-behind-the-locked-door-of-the-bathroom-at-dojo4.html
/dojo4/archive/these-are-12-of-my-favorite-things -> /dojo4/archive/these-are-12-of-my-favorite-things.html
/dojo4/archive/trends-community-data-made-easy -> /dojo4/archive/trends-community-data-made-easy.html
/dojo4/archive/unpublished-apis-or-how-i-learned-to-stop-worrying-and-love-the-bomb -> /dojo4/archive/unpublished-apis-or-how-i-learned-to-stop-worrying-and-love-the-bomb.html
/dojo4/archive/using-redis-with-sensitive-information -> /dojo4/archive/using-redis-with-sensitive-information.html
/dojo4/archive/using-terminal-notifier-in-our-capfiles -> /dojo4/archive/using-terminal-notifier-in-our-capfiles.html
/dojo4/archive/wallspace-finder-is-up-running -> /dojo4/archive/wallspace-finder-is-up-running.html
/dojo4/archive/uncle-earl-godfrey-reggio-and-why-how-and-where-we-do-our-work-matters -> /dojo4/archive/uncle-earl-godfrey-reggio-and-why-how-and-where-we-do-our-work-matters.html
/dojo4/archive/we-3-awesomeboulder -> /dojo4/archive/we-3-awesomeboulder.html
/dojo4/archive/wanted-gnu-unreasonable-nerds -> /dojo4/archive/wanted-gnu-unreasonable-nerds.html
/dojo4/archive/we-have-the-cutest-munchkins -> /dojo4/archive/we-have-the-cutest-munchkins.html
/dojo4/archive/we-re-flying-high-on-bitballoon -> /dojo4/archive/we-re-flying-high-on-bitballoon.html
/dojo4/archive/we-wrote-a-book -> /dojo4/archive/we-wrote-a-book.html
/dojo4/archive/web-developer-challenge -> /dojo4/archive/web-developer-challenge.html
/dojo4/archive/toolbox-for-a-better-world-do-something-simple-first-listen-deeply -> /dojo4/archive/toolbox-for-a-better-world-do-something-simple-first-listen-deeply.html
/dojo4/archive/thoughts-on-launching-and-scaling-quickly -> /dojo4/archive/thoughts-on-launching-and-scaling-quickly.html
/dojo4/archive/weekends -> /dojo4/archive/weekends.html
/dojo4/archive/weekends-make-us-more-productive -> /dojo4/archive/weekends-make-us-more-productive.html
/dojo4/archive/throw-things-into-the-future-with-us-dojo4-is-hiring -> /dojo4/archive/throw-things-into-the-future-with-us-dojo4-is-hiring.html
/dojo4/archive/what-a-rush -> /dojo4/archive/what-a-rush.html
/dojo4/archive/we-didn-t-find-this-green-coat-in-the-office -> /dojo4/archive/we-didn-t-find-this-green-coat-in-the-office.html
/dojo4/archive/what-s-up-with-moshi-moshi-co -> /dojo4/archive/what-s-up-with-moshi-moshi-co.html
/dojo4/archive/weekends-make-us-more-productive-on-mondays -> /dojo4/archive/weekends-make-us-more-productive-on-mondays.html
/dojo4/archive/were-all-naked-8-ways-to-help-the-right-clients-find-you -> /dojo4/archive/were-all-naked-8-ways-to-help-the-right-clients-find-you.html
/dojo4/archive/what-we-do-and-how-we-do-it-is-who-we-are -> /dojo4/archive/what-we-do-and-how-we-do-it-is-who-we-are.html
/dojo4/archive/what-would-it-be-like-if-everything-was-better-for-everyone -> /dojo4/archive/what-would-it-be-like-if-everything-was-better-for-everyone.html
/dojo4/archive/what-is-impact-anyway -> /dojo4/archive/what-is-impact-anyway.html
/dojo4/archive/what-would-you-do-with-a-1-000-to-make-boulder-more-awesome -> /dojo4/archive/what-would-you-do-with-a-1-000-to-make-boulder-more-awesome.html
/dojo4/archive/what-dojo4-did-over-the-weekend -> /dojo4/archive/what-dojo4-did-over-the-weekend.html
/dojo4/archive/why-did-speakteesy-die -> /dojo4/archive/why-did-speakteesy-die.html
/dojo4/archive/who-s-been-busy-in-denver -> /dojo4/archive/who-s-been-busy-in-denver.html
/dojo4/archive/why-phonegap-sucks -> /dojo4/archive/why-phonegap-sucks.html
/dojo4/archive/when-was-the-last-time-you-heard-my-voice -> /dojo4/archive/when-was-the-last-time-you-heard-my-voice.html
/dojo4/archive/whats-new-in-dojo4--2-version-notes -> /dojo4/archive/whats-new-in-dojo4--2-version-notes.html
/dojo4/archive/why-does-company-culture-matter -> /dojo4/archive/why-does-company-culture-matter.html
/dojo4/archive/where-can-we-meet -> /dojo4/archive/where-can-we-meet.html
/dojo4/archive/within40feet-day-11 -> /dojo4/archive/within40feet-day-11.html
/dojo4/archive/within-40-feet-of-where-i-stand -> /dojo4/archive/within-40-feet-of-where-i-stand.html
/dojo4/archive/within40feet-day-12 -> /dojo4/archive/within40feet-day-12.html
/dojo4/archive/within40feet-day-10 -> /dojo4/archive/within40feet-day-10.html
/dojo4/archive/within40feet-day-16 -> /dojo4/archive/within40feet-day-16.html
/dojo4/archive/where-we-gave-in-2015 -> /dojo4/archive/where-we-gave-in-2015.html
/dojo4/archive/within40feet-day-13 -> /dojo4/archive/within40feet-day-13.html
/dojo4/archive/within40feet-day-15 -> /dojo4/archive/within40feet-day-15.html
/dojo4/archive/within40feet-day-2 -> /dojo4/archive/within40feet-day-2.html
/dojo4/archive/within40feet-day-14 -> /dojo4/archive/within40feet-day-14.html
/dojo4/archive/within40feet-day-19 -> /dojo4/archive/within40feet-day-19.html
/dojo4/archive/within40feet-day-23 -> /dojo4/archive/within40feet-day-23.html
/dojo4/archive/within40feet-day-17 -> /dojo4/archive/within40feet-day-17.html
/dojo4/archive/within40feet-day-22 -> /dojo4/archive/within40feet-day-22.html
/dojo4/archive/within40feet-day-21 -> /dojo4/archive/within40feet-day-21.html
/dojo4/archive/within40feet-day-26 -> /dojo4/archive/within40feet-day-26.html
/dojo4/archive/within40feet-day-20 -> /dojo4/archive/within40feet-day-20.html
/dojo4/archive/within40feet-day-18 -> /dojo4/archive/within40feet-day-18.html
/dojo4/archive/within40feet-day-24 -> /dojo4/archive/within40feet-day-24.html
/dojo4/archive/within40feet-day-25 -> /dojo4/archive/within40feet-day-25.html
/dojo4/archive/within40feet-day-27 -> /dojo4/archive/within40feet-day-27.html
/dojo4/archive/within40feet-day-3 -> /dojo4/archive/within40feet-day-3.html
/dojo4/archive/within40feet-day-29 -> /dojo4/archive/within40feet-day-29.html
/dojo4/archive/within40feet-day-28 -> /dojo4/archive/within40feet-day-28.html
/dojo4/archive/within40feet-day-33 -> /dojo4/archive/within40feet-day-33.html
/dojo4/archive/within40feet-day-31 -> /dojo4/archive/within40feet-day-31.html
/dojo4/archive/within40feet-day-30 -> /dojo4/archive/within40feet-day-30.html
/dojo4/archive/within40feet-day-34 -> /dojo4/archive/within40feet-day-34.html
/dojo4/archive/within40feet-day-32 -> /dojo4/archive/within40feet-day-32.html
/dojo4/archive/within40feet-day-35 -> /dojo4/archive/within40feet-day-35.html
/dojo4/archive/within40feet-day-36 -> /dojo4/archive/within40feet-day-36.html
/dojo4/archive/within40feet-day-4 -> /dojo4/archive/within40feet-day-4.html
/dojo4/archive/within40feet-day-37 -> /dojo4/archive/within40feet-day-37.html
/dojo4/archive/within40feet-day-38 -> /dojo4/archive/within40feet-day-38.html
/dojo4/archive/within40feet-day-40 -> /dojo4/archive/within40feet-day-40.html
/dojo4/archive/within40feet-day-5 -> /dojo4/archive/within40feet-day-5.html
/dojo4/archive/within40feet-day-7 -> /dojo4/archive/within40feet-day-7.html
/dojo4/archive/within40feet-day-39 -> /dojo4/archive/within40feet-day-39.html
/dojo4/archive/within40feet-day-6 -> /dojo4/archive/within40feet-day-6.html
/dojo4/archive/within40feet-day-8 -> /dojo4/archive/within40feet-day-8.html
/dojo4/archive/within40feet-day-9 -> /dojo4/archive/within40feet-day-9.html
/dojo4/archive/work-after-flo-dojo4 -> /dojo4/archive/work-after-flo-dojo4.html
/dojo4/archive/wordpress-isn-t-worth-it-in-the-long-run -> /dojo4/archive/wordpress-isn-t-worth-it-in-the-long-run.html
/dojo4/archive/workeasy-opening-in-our-neighborhood-soon -> /dojo4/archive/workeasy-opening-in-our-neighborhood-soon.html
/dojo4/archive/you-should-learn-to-code -> /dojo4/archive/you-should-learn-to-code.html
/dojo4/archive/writing-hygienic-mixins-in-ruby -> /dojo4/archive/writing-hygienic-mixins-in-ruby.html
/dojo4/archive/your-people-at-workeasy -> /dojo4/archive/your-people-at-workeasy.html
/dojo4/archive/yes-we-can-js -> /dojo4/archive/yes-we-can-js.html
/dojo4/archive/your-style-is-orthodox-and-it-sucks -> /dojo4/archive/your-style-is-orthodox-and-it-sucks.html
/dojo4/archive/zurb-s-foundation-3-embracing-the-new-old-box-model -> /dojo4/archive/zurb-s-foundation-3-embracing-the-new-old-box-model.html
/dojo4/archive/youthroots-and-how-it-can-matter-to-you-too -> /dojo4/archive/youthroots-and-how-it-can-matter-to-you-too.html
/dojo4/archive/your-application-s-notifcations-bleeping-beep -> /dojo4/archive/your-application-s-notifcations-bleeping-beep.html
/dojo4/archive/zebras-get-down-to-business-dazzlecon17 -> /dojo4/archive/zebras-get-down-to-business-dazzlecon17.html
/dojo4/archive/yak-shaving-at-tax-time -> /dojo4/archive/yak-shaving-at-tax-time.html
---
{:stats=>{:n=>351, :e=>1.01}}

==========================================
RSYNC ./public/ -> ./tmp/019438e5-f406-7e73-b97d-a05bc948bd1e
------------------------------------------

==========================================
MV ../tmp/019438e5-f406-7e73-b97d-a05bc948bd1e -> ./build
------------------------------------------

```
