Web application deployments are complex from the get-go.  One often starts with at least a staging and a production deployment.  Add to this multi-tennancy, configs for third party integrations like facebook auth or salesforce, configs for cloud storage and content distribution networks, continuous integration environments, multi-client theming, SSL configs, vhost configs, build processes configs for js frontends, background task configuration, upload processing configuration, the list goes on... combinatorial explosion.

At dojo4 we have a rails based web app stack and we use Multistage Capistrano for deployment to AWS EC2 nodes.  We've found a simple strategy for managing the large variety of config and deployment requirements that our clients have presented us with.  The strategy involves a rake task which uses a RAILS_STAGE environment variable based on the Capistrano Multistage stage.  We setup a file structure for deployment specific configs in repo_root/config/deploy/files/RAILS_STAGE which is structured identically to the source repo file system.  During cap deploy, before current symlink or build processes, the rake task recursively copies repo_root/config/deploy/files/RAILS_STAGE into repo_root.

We have found this strategy to very effectively keep complex deployment configurations cleanly organized in a way which is easy to reason about and doesn't add much additional complexity to an already complex architecture.

The gist below demonstrates this idea.  Originally, this task leveraged various rails libraries.  However, I was able to factor out the rails dependencies while maintaining the tasks functionality so you can use it with any application stack.

<br />

<script src="https://gist.github.com/3286971.js?file=jobs.rb"></script>