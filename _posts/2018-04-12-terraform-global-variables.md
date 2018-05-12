---
layout: 'single'
title: 'Terraform Global Variables'
excerpt: 'A simple way to implement global variables in Terraform. {::nomarkdown}<br><br>Example available in the <strong>VMUG-Labs</strong> project.<br><br><iframe style="display: inline-block;" src="https://ghbtns.com/github-btn.html?user=vmug-labs&repo=vmug-labs&type=star&count=true&size=large" frameborder="0" scrolling="0" width="160px" height="30px"></iframe> <iframe style="display: inline-block;" src="https://ghbtns.com/github-btn.html?user=vmug-labs&repo=vmug-labs&type=fork&count=true&size=large" frameborder="0" scrolling="0" width="158px" height="30px"></iframe>{:/nomarkdown}'
date: '2018-04-12 09:36:40 -0500'
published: true
header:
  overlay_image: '/assets/images/pixabay-sunrise-1756274.jpg'
  overlay_filter: 0.5
  teaser: '/assets/images/pixabay-sunrise-1756274_640.jpg'
  caption: '[**pixabay**](https://pixabay.com/en/sunrise-space-outer-globe-world-1756274/)'
  cta_label: 'GitHub Repository'
  cta_url: 'https://github.com/vmug-labs/vmug-labs'
classes: 'wide'
toc: false
categories:
- 'Automation'
- 'Cloud Computing'
- 'Virtualization'
tags:
- 'HashiCorp'
- 'Open source'
- 'Terraform'
- 'VMUG'
meta:
  _wpcom_is_markdown: 1
  _publicize_done_external: 'a:2:{s:7:"twitter";a:1:{i:18402702;s:59:"https://twitter.com/troylindsay42/status/984440174124953600";}s:8:"facebook";a:1:{i:18883722;s:38:"https://facebook.com/10155592459651314";}}'
  _rest_api_published: 1
  _rest_api_client_id: -1
  _publicize_job_id: 16726215685
  timeline_notification: 1523543801
  _publicize_done_18611616: 1
  _wpas_done_18402702: 1
  publicize_twitter_user: 'troylindsay42'
  publicize_google_plus_url: 'https://plus.google.com/+TroyLindsay/posts/UPv7PQhPsrW'
  _publicize_done_18611618: 1
  _wpas_done_18402704: 1
  publicize_linkedin_url: 'https://www.linkedin.com/updates?discuss=&scope=19360941&stype=M&topic=6390205878632542208&type=U&a=-pZo'
  _publicize_done_18611619: 1
  _wpas_done_18402705: 1
  _publicize_done_19035169: 1
  _wpas_done_18883722: 1
---
Anyone who has developed a highly modular Terraform project has wished at some point that there was a simple way to implement global variables.  This feature will probably not be developed though, because as Paul Hinze of HashiCorp [stated][Terraform issue 5480]:

> In general we're against the particular solution of Global Variables, since it makes the input -> resources -> output flow of Modules less explicit, and explicitness is a core design goal.

I am an advocate of the [Don't Repeat Yourself (DRY) software development principle][DRY], and two of the key goals for my open source [VMUG Labs project][VMUG-Labs repo] are simplicity & ease of use for the end user, so I started brainstorming for a better way to implement this- a solution where you do not have to remember to specify a shared [tfvars file][Terraform variables], use a a script that specifies the shared tfvars file or run-line variables for you, group resources that you want segregated, or reference the value from the state file of one of the other modules or use a default value for the variable when those doesn't make sense.

Eventually, it dawned on me- create a global variable module with static outputs and reference the module in your Terraform resource configuration files.  The optimal implementation of this would be to store the module in a private source control repository because remote modules can reference specific versions, though this can also implemented via a local module, which was the best fit for my VMUG Labs project since it is open source (public) and I wanted to minimize the number of components necessary for end users.

At first, I thought that I was the first to think of this solution (and document it publicly), but then I found that @keirhbadger [beat me to it][Terraform issue 5480] by almost a year.  Oh well.

Here are a couple of example output values from the [outputs.tf.example file][VMUG-Labs outputs.tf.example] in the local global_variables module in the VMUG Labs project.  You would make your own copy of this file named outputs.tf and set the values appropriately.  The new outputs.tf will be ignored by your git client per the entry in the .gitignore file to prevent the sensitive data in this file from being accidentally committed into source control.

<!-- hcl is not supported by rouge or pygments at this time -->
{% highlight ruby %}
output "aws_profile" {
  value = "aws_profile"
}

output "aws_region" {
  value = "us-west-2"
}
{% endhighlight %}

I can then use the static output values in the global_variables module to set input parameters in segregated resources with separate state files.  For example, the [domain_controller][VMUG-Labs domain_controller] and [jumphost][VMUG-Labs jumphost] Terraform config files:

<!-- hcl is not supported by rouge or pygments at this time -->
{% highlight ruby %}
module "global_variables" {
  source = "../../../modules/global_variables"
}

provider "aws" {
  version = "~> 1.13"
  profile = "${module.global_variables.aws_profile}"
  region = "${module.global_variables.aws_region}"
}
{% endhighlight %}

Voila!  That's it!

This solution can be a more intuitive approach for end users that may be less experienced with Terraform.

Enjoy!

[Terraform issue 5480]: https://github.com/hashicorp/terraform/issues/5480
[DRY]: https://en.wikipedia.org/wiki/Don%27t_repeat_yourself
[VMUG-Labs repo]: https://github.com/vmug-labs/vmug-labs
[Terraform variables]: https://www.terraform.io/intro/getting-started/variables.html
[VMUG-Labs outputs.tf.example]: https://github.com/vmug-labs/vmug-labs/blob/master/modules/global_variables/outputs.tf.example
[VMUG-Labs domain_controller]: https://github.com/vmug-labs/vmug-labs/blob/master/live/global/domain_controller/main.tf
[VMUG-Labs jumphost]: https://github.com/vmug-labs/vmug-labs/blob/master/live/global/jumphost/main.tf
