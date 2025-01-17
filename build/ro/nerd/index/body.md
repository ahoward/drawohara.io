### they say i am a big fat 🤓 -- and they are right!

for some strange reason, this makes me happy

![](./assets/terminal.jpg "image of terminal")

as you can read on my [about](/about) page, i have written [too much software](/rubygems)

i got my start researching _in_ [NOAA](https://www.boulder.noaa.gov/)

_for_ [C.I.R.E.S](https://cires.colorado.edu/)

while studying _at_ [CU's College of Engineering & Applied Science](https://www.colorado.edu/engineering/)

> wut?

well, basically, the university has a program that donates young scientists to
other research institutes, to help do science.

the goal is getting the university's name on papers which, if you know anything
about science, is gold.  publish or perish... etc.  publishing == funding.

my first big project, which i completed with my friends:

- [Dave Clements](https://www.linkedin.com/in/daveclem/)
- [Tom Lauren](https://www.linkedin.com/in/tom-lauren-a46b793/)
- [Doug Fales](https://www.linkedin.com/in/dougfales/)
- [Scott Symmank](https://www.linkedin.com/in/scott-symmank-23b6a64/)

was a cutting edge bit of software.  essentially, we wrote a J2EE (java.  yep)
app that was deployed on linux field computers.  the purpose, was to analyze
weather data, in the field, while on large forest fire suppression projects, to
make __go__ or __no-go__ calls.  by this, i mean the "local weather report
needed to know if i will kill this team by sending them up this canyon, right
now"

this was pre-ruby, pre-common-js, and pre-iphone.   we wrote a crazy thing that
worked on bizarre linux filed computers using satellite internet which, at that
time.  was way, way out there.

i also wrote a 'golf app' for blackberry but... ok.  another story!

anyhow, we worked very, very hard on this - i didn't miss a single day at the
engineering center in a year - and it turned into a job with C.I.R.E.S for me.

subsequently, i went to work at FSL (Forecast Systems Lab) doing
hyper-high-availability (5 9s ((99.999 % uptime))) for operational satellite
ingest systems.

we designed cutting edge systems and novel... **brutal**... methods of ensuring
consistency of data such as **STONITH**, which stands for **"Stone The Other In The
Head"**.   this was the way we would ensure a single lead systems would know all
the subordinate systems __(we used to call these 'master' and 'slave' but that
has, thankfully, gone out of fashion....)__

anyhow, _basically_, when taking over ownership of an important system we
couldn't rely on such simple measures like concencus, or some other arrangment,
when you take over control, literally toggle the power of the other system you
are taking over: stone it in the head!  in this way, we could be damn sure that
our code worked, and acheive 5 9s. of uptime.  if you are wondering, we actualy
built hardware to support this and, at that time, were doing some of the first
ha-postgress systems in the world.

i also did a lot of work in verification.

geophysical models take hundreds, or thousands, or even hundreds of thousands,
of configurations. to run.  people talk about how __neat 12-factor__ is now,
and i just shake my head... what if you had to manage **millions** of
configuration values.  the next trick is version them, so we know how they
change over time because, as scientists, if we make a change to say, a cloud
physics model, we need to 'test it'.  but

> how *do* you test software, when you don't now the 'right answer'?

ain't that relevant now?!

the approach is actually theoretically simple:

some people know it as **the scientific method** (air-quotes).  basically, you
make your change, hold all other variables the same, and look for changes.  in
the case of storms you might re-run 10 years of weather predictions, each at
the 0hr, 1hr, 8hr, 24hr, etc.  predictions, and then analyze all **that** data,

to see if

 __"it got better"__

what do we mean by __"better"__ you ask?

**good question**!

this reminds me, very much. of the current 🌎 situation, in which hundreds of
thousands of well-meaning and progressive technologies have, despite linters,
test-suites, cults like xp and agile.bs, who have all been, literally
**screaming** to the world about how hard thier job is, and how powerful thier
stuff is, and how bad you need to buy it so we can have an IPO, have suddenly
thown out all need to **test anything at all**, understand the outputs, the ramifications,
or anything.  _we just ask the **oracle**_!  (this is AI for those of you
non-nerds)...

> software development **is presently** one of the biggest existential threats to democracy

__^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^__

, the economny, and the environemnt, let alone human beings, because
of this trend.  i have heard PhD level programmers refer to AI as _a universal
API_, claiming they can replace 'anyone' via this ability to distill an API
from thin air, and then program a human (we call these "agents") to use the
silly think.  so, let me say this back to you slowly, and in english:

software developers, ranging from ones that work in social media, self driving cars, ecnonimics, space-weather, video games, etc. have decided the following is statement is **valid**:

> " We can pattern match ANYTHING (rawr!), if only we pump enough data into it!  

ergo...

> GIVE US ALL THE DATA AND [FEAR ME](https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExMzc0bG9xd29hbG95c3N3cmk3dTNyMW1zYTR4bWc0ajEzaW00YzRkcyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/26CalrOGwwL9265yw/giphy.gif)!

now, here is the hitch.  who says what all this data is?  where does it come
from?  well, i will tell you one thing: **they aren't telling us**.  instead,
they are **selling us**.  and by this i literally mean they are **selling me to
you** and **you to me**.  the thoughts and communications we share these are
what they capture and sell.  good time to re-watch the matrix, btw....

consider just two companies.

### 1. google

the 'deep research feature' one can use in version 1.5 is amazing.  ask it to
research, it downloads a tiny, relevant, subset of the interwebs, it compiles a
little RAG database for you, and informs your questions to the oracle with
that.  **neato**! 

here are, but a __few__ small problems with this:

- you are researching on data that google has 'discovered to be relevant'.
now, i don't know if you are ever even heard of something calle **S E O**, but,
i assure you there is a battle happening with little aliens to tricky the
google for a very, very long time.  so long, that some of this information may
even be considered 'fact'.   the key yere is that **S stands for Sales**.  see
what i mean?

- next, google understands exactly who you are, what your facebook handle is,
when you took a piss, your fitness data (corelated with your response after the
election which is almost as easy as marking them with two yellow triangles in
the form of the star of david)... you **give this to them btw**, and now it
also reads your text messages and understands the things you really really
research.  what could _possibly_ go wrong?

- oh god i nearly forgot haha!  you have *zero fucking idea* if the answer you
get from these things is 'right'.   i'm not even going to go there but, if you
ever, talked to me about 'testing' and did't appreciate that, in fact, their
are more ways to verify programs than 'coverage' (which is, btw, the biggest
waste of resources the industry has ever made, even more than AI.. more on this
soon).  next, you buy a service to look for 'trends in the data' and integrate
it into your CI pipeline and OMFG 🤦 - **STOP AND LOOK IN THE MIRROR PEOPLE**.
if you are using AI in either science or programmer, and have not stopped to
consider what little things like 'correctness' or 'reproducability' are.
perhaps you are **actually** in [this camp](https://photos.app.goo.gl/V34nXqtH4PZa1emV7)
 but don't even know it yet...  (more soon on the connection between technology
and facism but... so little time!)


### 2. openai

... more on the real evils of this company soon but, i wouldn't send them *my* data.  personal, or business.  just sayin.


### 3. so, who should i use?

[https://mistral.ai/](https://mistral.ai/) ... more on this soon too.  sooooo much to write!

> but, we are **way** of topic.

back at FSL, i continued working in the area of complex notions of
'correctness', and ended up developing novel database platform at the time,
called 'bitemporal postgresql'.  some remains of it live on the interwebs.
think version control on steriods.  enough about that.

my next stint was at [The National Geophysical Data Center](https://www.ngdc.noaa.gov/), where i __helped__ write a bunch of papers:


- <a href='/purls/can-poverty-rates-be-estimated-using-satellite-data'>/purls/can-poverty-rates-be-estimated-using-satellite-data</a>
- <a href='/purls/a-global-inventory-of-coral-reef-stressors-based-on-satellite-observed-nighttime-lights'>/purls/a-global-inventory-of-coral-reef-stressors-based-on-satellite-observed-nighttime-lights</a>
- <a href='/purls/change-detection-in-satellite-observed-nighttime-lights-1992-2003'>/purls/change-detection-in-satellite-observed-nighttime-lights-1992-2003</a>
- <a href='/purls/a-twelve-year-record-of-national-and-global-gas-flaring-volumes-estimated-using-satellite-data'>/purls/a-twelve-year-record-of-national-and-global-gas-flaring-volumes-estimated-using-satellite-data</a>
- <a href='/purls/global-distribution-and-density-of-constructed-impervious-surfaces'>/purls/global-distribution-and-density-of-constructed-impervious-surfaces</a>

> what do i mean by 'help'?

mostly, i built very, very [large super-compute](https://www.linuxjournal.com/article/7922),
essentially big fat map-reduce style computing but, at the time, neither of
those terms existed.  we had to invent novel ways, of moving our code of off
big-endian (not spelled wrong) cray (also not spelled wrong) machines and onto
tons of commodity hardware.  namely, hundreds of linux boxen.

i also did a ton of work around clustering... very low level c/c++ code, using
ideas from signal processing and computer vision, to detect the edges of cities
via a process similar to the [watershed algorithm](https://en.wikipedia.org/wiki/Watershed_(image_processing))
 but...  at scale.

i also got to release piles of open source software at NGDC and, for this alone, i am very grateful.


<hr>
__... breathe.. __

next, [this crazy mofo](https://www.linkedin.com/in/gregory-greenstreet-082635/) hired me.  to compile the [GNU scientific library](https://www.gnu.org/software/gsl/) on.. wait for it...

**windows**!

wowza i _am_ old!

anyhow, Greg worked for [Don Springer](https://www.linkedin.com/in/dospringer/), at company called [Collective Intellect](https://www.oracle.com/corporate/pressrelease/oracle-buys-collective-intellect-060512.html).  which, at the time, was the "Mobius Group" (which would eventually become [The Foundry Group](https://foundry.vc/) and... **#BOOM** .. start-ups in Boulder, Colorado, were a thing.

it was fun time.

it was after this that i started [dojo4](/dojo4), which was the crown jewl in my life as a geek, for many reasons i hope to write about soon.  including close to ten years mentoring [techstars](https://www.techstars.com/) companies where, i have made some super duper great friends.

until then, i will say, as i always do that:

- this is a work in progress.
- i am doing it live.
- i cannot spell, so fucking sue me.

(if you **do** find an errer (heh), then [ping me](/contact) or [submit a pr](https://github.com/ahoward/drawohara.io) as this is all in gh)

and ... fucking **ads**!, my [new company](/purls/disco), aims to remedy some, but not all, of the symptoms i am watching the 'AI movement' go through...

with more than a little bit of horror.


