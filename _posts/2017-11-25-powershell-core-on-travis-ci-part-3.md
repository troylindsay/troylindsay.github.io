---
type: 'post'
layout: 'single'
title: 'PowerShell Core on Travis CI (part 3 of 3)'
redirect_to: 'https://troylindsay.io/posts/2017-11-25-powershell-core-on-travis-ci/'
excerpt: 'How to build, test, and deploy your PowerShell projects on Linux and macOS for free with Travis CI! {::nomarkdown}<br><br>Example available in the <strong>Armor PowerShell</strong> project.<br><br><iframe style="display: inline-block;" src="https://ghbtns.com/github-btn.html?user=tlindsay42&repo=armorpowershell&type=star&count=true&size=large" frameborder="0" scrolling="0" width="160px" height="30px"></iframe> <iframe style="display: inline-block;" src="https://ghbtns.com/github-btn.html?user=tlindsay42&repo=armorpowershell&type=fork&count=true&size=large" frameborder="0" scrolling="0" width="158px" height="30px"></iframe>{:/nomarkdown}'
published: true
last_modified_at: '2021-12-13'
header:
  overlay_image: '/assets/images/powershell_github_travis-ci.png'
  overlay_filter: 0.5
  teaser: '/assets/images/powershell_github_travis-ci.png'
toc_icon: 'terminal'
categories:
- 'Automation'
tags:
- 'Continuous Delivery'
- 'Continuous Deployment'
- 'Continuous Integration'
- 'FOSS'
- 'Free'
- 'GitHub'
- 'Linux'
- 'macOS'
- 'Microsoft'
- 'Open source'
- 'OSX'
- 'PowerShell'
- 'PowerShell Core'
- 'Travis CI'
- 'Ubuntu'
meta:
  _wpcom_is_markdown: 1
  _thumbnail_id: 307
  _rest_api_published: 1
  _rest_api_client_id: -1
  _publicize_job_id: 11837283676
  _publicize_done_external: 'a:1:{s:7:"twitter";a:1:{i:18402702;s:59:"https://twitter.com/troylindsay42/status/934648058633076736";}}'
  _publicize_done_18611616: 1
  _wpas_done_18402702: 1
  publicize_twitter_user: 'troylindsay42'
  publicize_google_plus_url: 'https://plus.google.com/+TroyLindsay/posts/DjSXu8DCVp1'
  _publicize_done_18611618: 1
  _wpas_done_18402704: 1
  publicize_linkedin_url: 'https://www.linkedin.com/updates?discuss=&scope=19360941&stype=M&topic=6340413775547506689&type=U&a=QGlR'
  _publicize_done_18611619: 1
  _wpas_done_18402705: 1
---
## Lint your .travis.yml config file

Now, it's time to test your config file using the Travis Client that we installed earlier by running `travis post`.

```text
travis post

Warnings for .travis.yml:
[x] in matrix.include section: unexpected key osx_image, dropping
[x] in matrix.include section: unexpected key dist, dropping
[x] in matrix.include section: unexpected key sudo, dropping
```

Wait, what?  Why am I seeing these warnings?

As of 20171125, this type of build matrix image configuration is recommended per the [Travis CI multiple operating system build configurations documentation][matrix], but it will generate three false positive unexpected key warnings when [linting][lint] your `.travis.yml` config file.  These three warnings can be disregarded and have been reported [here][559].  Any warnings or errors other than these should be addressed.

## Commit your .travis.yml config file

When you are ready, run the following commands to:

1. Stage the `./travis.yml` config file to the index
1. Commit the `./travis.yml` config file
1. And then push it up to the master branch of your GitHub public repo, which will trigger the first Travis CI build for your project!
    * If you prefer to push the change to a branch other than master, then update the branch name accordingly.

```bash
git add ./.travis.yml
git commit --message 'Initial commit' ./.travis.yml
git push origin master
```

## Protect your important branches

Now that you have configured and run your first build, update your GitHub repository settings so that any contributions to your project must first pass your build and testing framework as a prerequisite for consideration.  To do so:

* Go to `https://github.com/<user>/<project>/settings/branches/<branch>/`
* Enable **Require status checks to pass before merging**.
* Also recommended:
  * Enable **Require pull request reviews before merging**.
  * Enable **Require review from Code Owners**.
  * Enable **Require branches to be up to date before merging**.

{% include figure image_path="/assets/images/github-branch-protection.png" alt="GitHub branch protection for master" %}

## You made it!

Voila!  You're done!  There are plenty of other things that you can do here such as configure notifications so that Travis CI automatically posts your build results in a Slack channel, publish your PowerShell module on successful build to the PowerShell gallery, or add a badge to your README.md indicating whether the last build passed or failed, all of which I'll cover in the next post, but you should have enough now to start testing your PowerShell project on macOS and Ubuntu for free on the powerful & versatile Travis CI platform.

Enjoy!

[matrix]: https://docs.travis-ci.com/user/multi-os/#Example-Multi-OS-Build-Matrix
[lint]: https://en.wikipedia.org/wiki/Lint_(software) "validating"
[559]: https://github.com/travis-ci/travis.rb/issues/559
