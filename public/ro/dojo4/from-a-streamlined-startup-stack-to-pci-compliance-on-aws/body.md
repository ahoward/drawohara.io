## Intro

Working through projects at [Dojo4](http://dojo4.com) I'm often surprised to see the way that seemingly tiny increases in technical complexity [compound](http://en.wikipedia.org/wiki/Combinatorial_explosion) into significant attention and resource sinks.  Consequently, when projects are initially getting going, we tend to favor a simplified hosting and application stack which shares many features commonly seen in shared hosting services.  This includes choices like hosting the app and db together, employing a single deployment user on the hosting system, and simple [uptime monitoring](http://uptimerobot.com).

Recently, our long time client, [Inspire Commerce](http://www.inspirecommerce.com/), developed a new business plan requiring that their application meet the stringent [Payment Card Industry](https://www.pcisecuritystandards.org/) (PCI) Level 1 security compliance for processing, transmitting, and storing credit card information.  Many of the security requirements detailed in the PCI [Data Security Standard](https://www.pcisecuritystandards.org/security_standards/) (DSS) motivate a significant change in thinking from the streamlined focused stack mentioned above.   This post will briefly enumerate some of these details and outline our solutions.

The PCI DSS is broken into 12 sections covering everything from firewall configuration to personnel security policies.  I'll run down a few of the sections which are relevant to the hosting stack.

## 1. Install and maintain a firewall configuration to protect cardholder data

This is a pretty detailed section of the DSS which mandates the installation and configuration of [firewall](http://en.wikipedia.org/wiki/Firewall_%28computing%29) services on all networking devices, from workstations, to routers, to servers.  Using [Amazon Web Services](http://aws.amazon.com/) (AWS) [Elastic Compute Cloud](http://aws.amazon.com/ec2/) (EC2) as the foundation of our hosting stack, many of these networking devices are abstracted out of our view or control.  Conveniently, [AWS is itself PCI Level 1 compliant](http://aws.amazon.com/security/#certifications) leaving a lot of these details to the engineers at Amazon.
 
However, firewalls for the EC2 nodes themselves does require some conideration.   EC2 nodes are protected by a firewall implemented at the [hypervizor](www.xen.org/products/xenhyp.html) layer and configured by AWS [Security Groups](http://docs.amazonwebservices.com/AWSEC2/latest/UserGuide/using-network-security.html).  Our basic Security Group has all ports denying packets with the exception of 22, 80, & 443 accepting from all sources.  We run [Ubuntu Linux](www.ubuntu.com/) on our nodes and out of the box have the [IP Tables](www.netfilter.org/projects/iptables/) firewall configured with an open policy.

The PCI DSS focuses on using firewalls to create secure private networks, or [De-Militarized-Zones](http://en.wikipedia.org/wiki/DMZ_%28computing%29) (DMZ) for systems hosting apps which process payment card data.  AWS Security Groups provide a useful mechanism for creating secure private networks between various components of the application stack.  For example, by creating a WEB security group and a DB security group, and opening the database port in the DB security group to only WEB security group sources, the EC2 hypervisor firewall running on a database server will only allow access to the database from web servers connecting on the internal private network interface.

For redundancy, we mirror the AWS Security Group configuration for the EC2 hypervisor firewall with the [CloudPassage](http://www.cloudpassage.com/) service which is able to manage the IP Tables firewall at the operating system layer of systems hosting components of the card processing application.  CloudPassage organizes firewall policies in [Server Groups](http://www.cloudpassage.com/features/halo-firewall.html) which are somewhat analogous to AWS Security Groups.  Another great feature of CloudPassage is the [GhostPorts](http://www.cloudpassage.com/features/multifactor-authentication.html) service.  We configure the ssh port policy in CloudPassage to accept connections from GhostPort sources.  In order for a client machine to become a GhostPort source, a user on that machine must authenticate to the CloudPassage portal, be authorized to open GhostPorts for a server group, and authenticate with a registered Yubikey dongle, or respond to an SMS challenge with a registered cell phone.  Upon successful authentication and authorization, CloudPassage configures IP Tables to accept connections from the client machine source ip.  This is a convenient, secure, temporary, and auditable way to manage access to sensitive hosts.

## 2. Do not use vendor-supplied defaults for system passwords and other security parameters

This section would seem to be pretty obvious.  A good example of the importance of changing vendor supplied default password is the [Splunk](http://www.splunk.com/) [Universal Forwarder](http://docs.splunk.com/Documentation/Splunk/latest/Deploy/Introducingtheuniversalforwarder) default password of changeme.

However buried in this section is an important hosting requirement somewhat unrelated to the section title.  "2.2.1 Implement only one primary function per server to prevent functions that require different security levels from co-existing on the same server. (For example web servers, database servers, and DNS should be implemented on separate servers)".

As mentioned above, AWS security groups make the task of securely separating services like web and database servers onto separate hosts pretty simple.

## 5. Use and regularly update anti-virus software or programs

[ClamAV](http://clamav.com) makes quick work of this requirement on Ubuntu Linux.

## 8. Assign a unique ID to each person with computer access

The intent of this section is to facilitate auditability and accountability by removing shared user accounts.  Since we use a [key based](http://en.wikipedia.org/wiki/Ssh-keygen) authentication mechanism for [secure shell](http://en.wikipedia.org/wiki/Secure_Shell) access, there are three primary concerns for knowing who did what.  First it is necessary to prevent user from being able to switch to another user account with the [su command](http://en.wikipedia.org/wiki/Su_%28Unix%29).  This is easily accomplished by removing the [execute permission](http://en.wikipedia.org/wiki/Filesystem_permissions#Traditional_Unix_permissions) on the su binary and modify [/etc/pam.d](http://aplawrence.com/Basics/understandingpam.html) prevent all su authorization.  Second, ensure that the [authorized_keys](http://www.eng.cam.ac.uk/help/jpmg/ssh/authorized_keys_howto.html) files for all user accounts only contain a single entry.  Lastly, ensure that all keys used for secure shell access are password protected and that a policy is in place to forbid sharing of keys between users.

Now, the [Linux Audit Daemon](http://www.cyberciti.biz/tips/linux-audit-files-to-see-who-made-changes-to-a-file.html) (AuditD) can be used to track system activity to specific users.

## 9. Restrict physical access to cardholder data

The title of this section is pretty self explanatory.  Basically, this section covers the topics of restricting physical data center access to authorized personnel.  Similar to the discussion of network device firewall configuration above, this is covered by the AWS PCI Level 1 certification and the details can be left to Amazon.

## 10. track and monitor all access to network resources and cardholder data

The motivation of this section is "preventing, detecting, or minimizing the impact of a data compromise".  This involves topics like logging, file integrity management, and intrusion detection.  Our strategy starts with the employment of a logging service to support aggregation of logs, retention of logs, as well as searching of log records.  We are using the [Splunk](http://splunk.com) application for this functionality.  We setup an EC2 instance for a logging server and installed Splunk.  We setup AWS Security Groups and CloudPassage ServerGroups for the new server which has the Splunk listener port accepting connections from web server and db server sources on the private network interface.  Next we setup the Splunk Universal Forwarder on web and db servers and configured the forwarders to monitor application, apache, mongodb, sys, audit, & auth logs.

For file integrity monitoring and intrusion detection we installed the [OSSEC](http://www.ossec.net/?page_id=165) application on all of our servers and added all of the logs that OSSEC writes to the Splunk forwarders.
