The other day we released version 0.1.0 of [DREBS](https://rubygems.org/gems/drebs), our Disaster Recovery for Elastic Block Storage script. We use it every hour on all 3 of our EC2 instances, backing up 6 different EBS volumes. This script is crucial to us and the AWS community at large because Amazon does not officially support any such script or tool to provide backups. There are several SaaS products out there which provide the functionality, but open source scripts for hackers like us are far and few between. The newly rewritten version is production ready and we hope you'll enjoy it as much as we do.

Last year, former dojo4 employee and forever friend of the dojo [Garett Shulman](https://twitter.com/shulmang), released the [first version of DREBS](http://dojo4.com/blog/a-simple-backup-strategy-for-amazon-cloud-hosts). It had the simple goal of allowing an administrator to define backup strategies and pre/post backup tasks (mysqldump, etc.) for each EBS volume mounted to an EC2 instance. A simple cron task runs DREBS every  hour, which goes through each EBS instance' backup strategy and if the strategy indicates a backup should happen, DREBS uses the [right_aws](https://github.com/rightscale/right_aws) gem to backup the volume and upload it to the AWS account as an EBS snapshot.

The new version of DREBS provides the same functionality but with a few improvements:

* State is now stored in a tiny sqlite database instead of a json file.
* Resilient when strategies change.
* Resilient when snapshots are deleted in the AWS console.
* A DREBS shell which allows you to test your config easily and quickly.

As an example setup, here's DREBS in our crontab on all of our machines:

```
0 * * * * /home/dojo4/git/drebs/bin/drebs execute /usr/local/var/drebs_config.yml &> /usr/local/var/drebs_cron.out
```

and here's our config file for one of our EC2 instances:

```
---
aws_access_key_id: XXXX
aws_secret_access_key: XXX
region: us-west-1
strategies:
- hours_between: 6
  num_to_keep: 12
  mount_point: /dev/sdh
  pre_snapshot_tasks:
  - pg_dump -U postgres -f /ebs/databases/postgresql/backups/project_name_production.sql project_name_production
  post_snapshot_tasks:
- hours_between: 1
  num_to_keep: 2
  mount_point: /dev/sda1
  pre_snapshot_tasks:
  post_snapshot_tasks:
- hours_between: 24
  num_to_keep: 4
  mount_point: /dev/sda1
- hours_between: 96
  num_to_keep: 4
  mount_point: /dev/sda1
log_path: /usr/local/var/drebs.log
email_on_exception: miles@dojo4.com
email_host: smtp.gmail.com
email_port: 587
email_domain: gmail.com
email_user: xxx
email_password: xxx
```


As always, we have more ideas on how to improve this script and if this script helps you as much as it does us, we invite you to fork [the repo](https://github.com/dojo4/drebs) and send us a pull request:

* Improve test coverage
* Use whenever gem for easier crontab setup
* Arbitrary execution intervals (snapshots every 5 minutes instead of every hour)
* AWS API keys and other config values from AWS Instance Data
* Add example AWS user access config


We think DREBS is a great contribution to the AWS community that has helped us build a great deployment architecture that has hosted awesome websites and products over the years. If you agree and use it, we'd love to hear your feedback on twitter at [@dojo4](https://twitter.com/intent/tweet?text=@dojo4)!
