in our rails apps we always have an '/su' or 'super user' section.  we dump stuff like reports into that backend.  recently i needed to allow super users to view logs in realtime from the browser (to assist debugging firewall issues for a license server we built).  i considered doing something clever like websockets and then i became sane and just decided to do the simplest thing that could possibly work - remember, this is super users only so the following polling approach is *juuuust dandy*...
<br />
<br />

step one was to setup an action and view that could tail a log, show it, and then ajax poll update it.  icing was adding a fancy ui (aka *link*) that could start and stop the polling
<br />
<br />

here's a majority of the relevant codez
<br />
<br />

<script src="https://gist.github.com/1994292.js?file=tail-f.rb"></script>
<br />
<br />

step two, shown in that gist, was to quiet down the recursive logger feature i inadvertently added: aka - the polling ajax itself created tons of logger output.
<br />

so there you have it.  low tech.  easy cheasy.  k.i.s.s. log tailing for admins.
<br />
<br />