Hosting, DNS & HTTPS often require the interactions of more than a few providers.  Often becoming unwieldily if not managed effectively.

DNS requires both record management and domain registration.  For both Dojo4 has employed [DyDNS](http://dyn.com/dns) for many years.

Dojo4 generally uses [Amazon AWS EC2 cloud computers](http://aws.amazon.com/ec2) for hosting and as such tend to use [AWS ELB load balancers](http://aws.amazon.com/elasticloadbalancing) in front of those web hosts.  Unfortunately, Amazon doesn't give you a consistent IP addresses for ELB instances and so consequently the only way to create second level domain records pointing to ELB instances is to use [Amazon AWS Route53](http://aws.amazon.com/route53) for record management which has a special alias record for the purpose.  So, we tend to use Route53 for DNS record management.

Due to the way TLS handshakes are negotiated by linux/apache you are limited to the number of SSL certificates that can be served to the number of IP's on the host.  With EC2 this is basically a single cert if you are not using a [VPC](http://aws.amazon.com/vpc).  Dojo4 often uses ELB's to provide SSL as a means to get around this.

DNS & HTTPS are closely related as the domains and subdomains to be secured must be enumerated prior to certificate provisioning.  Often the most convenient and flexible strategy is to get a wildcard cert.  Note, though, that not all wildcard certificate issuers include the base domain in the certificate (so you can only use the cert to protect *.somedomain.com, and not somedomain.com).  The $100/year wildcard certificate from [dnsimple.com](dnsimple.com) issued by [Comodo](http://comodo.com) and including the base domain is a good value even with the $96 ($8/month * 12 months) dnsimple dns hosting cost.

dnsimple has some other convenient features such as being able to delegate management of records set to other dnsimple user accounts.  As we have moved record set management from DynDNS to Route53, and are having an account on dnsimple for SSL provisioning, we went ahead and moved domain registration from DynDNS to dnsimple to consolidate services.

Some handy command-liners:

Find the Start Of Authority for a DNS record
>dig SOA dojo4.com

View the certificate that a host is serving
>openssl s_client -showcerts -connect dojo4.com:443 < /dev/null

Access a web server by IP ignoring SSL verification
>curl -k https://184.72.61.241 -H "Host: projects.dojo4.com"