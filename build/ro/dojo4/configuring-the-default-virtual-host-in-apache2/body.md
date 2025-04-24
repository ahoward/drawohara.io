````apache


#
#
# apache has the odd behaviour of routing any request with a bad or unknown
# Host: header to the first virtual host found in it's config.  this can cause
# serioulsy bad issues when multiple sites are hosted in the same apache
# instance.  for example, a failed request for http://foo.bar.com/missing
# could hit a passenger virtual host and cause unspecfied behaviour depending
# on how that application behaves.
#
# the solution is to ensure a catch-all virtual host exists and is loaded
# before all other virtual host configuration files - and that this virutal
# host simply 404's (you could also serve a friendly error page)
#
# assuming a layout where apache conf files are loaded from, eg:
#
#   /etc/apache2/sites-enabled/*.conf
#
# you should put this configuation in a file named
#
#   /etc/apache2/sites-enabled/0.conf
#
# the '0.conf' ensures it's loaded first.  you can validate that this config
# is loaded first via
#
#   ls -1 /etc/apache2/sites-enabled/ | sort | head -1
#
# this should print
#
#   /etc/apache2/sites-enabled/0.conf
#
# once the configuration is in place you can test that it is indeed the
# default/first configuration used via
#
#   curl --silent --header 'Host: fu.bar.com' your.domain.com
#
# the default apache 404 page will be served is this is correct.  obviously
# you can configure the default virtual servers to have an acutal document
# root, etc...
#
# another important note.  it is *not* enough to simple configure the
#
#   _default_:80
#
# virtual host.
#
# you also need to setup the actual named host
#
#   ServerName _default_
#
# the reason for this is that name based virtual hosting will use, by default,
# the first *name based virtual host* so you cannot rely on an un-named one,
# which would suffice in most situations.
#


# this section will catch requests to missing hosts under a name-based vhost
# configuration
#
  <VirtualHost *:80>
    ServerName _default_
    Redirect 404 /
  </VirtualHost>


# and this will handle the rest
#
  <VirtualHost _default_:80>
    Redirect 404 /
  </VirtualHost>



````