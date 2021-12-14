---
type: 'post'
layout: 'single'
title: 'PowerShell Core on Travis CI (part 1 of 3)'
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
## Overview

Last month, I started a new pet project of building an [open-source PowerShell module for Armor][project], and one of the first goals that came to mind was that I wanted to ensure compatibility with PowerShell Core on Linux.  I had recently re-read Chris Wahl's article: [How to Version and Publish a PowerShell Module to GitHub and PSGallery with AppVeyor][wahl], and figured that there had to be a similar service for Linux, so I started looking around.  I found Travis CI rather quickly, and was pleasantly surprised to discover that they offered macOS images in addition to Ubuntu.

If you are unfamiliar with Travis CI, [here][travis_ci_desc] is a solid description:

> Travis CI is a hosted, distributed continuous integration service used to build and test projects hosted at GitHub. Travis CI automatically detects when a commit has been made and pushed to a GitHub repository that is using Travis CI, and each time this happens, it will try to build the project and run tests. This includes commits to all branches, not just to the master branch.

Restated, this means that every time you push new code up to your public repo, Travis CI (and/or AppVeyor) will build your project per your specifications, run any tests defined, and even deploy it if desired.  For free.  ***Build, test, and deploy on push for free.***  How cool is that?

Now, one of the reasons that I am writing this article is that getting started with building & testing a PowerShell project on Travis CI was not intuitive.  AppVeyor and Travis CI were both designed for building, testing, and deploying [programming language][programming] projects, not [scripting language] projects.  It took a lot of [RTFM][rtfm] and a little trial & error to figure it out, but it was so worth it.  The following article covers some of my lessons learned in the process.  I hope that you find them valuable.

## Getting started with Travis CI

> 1. Sign into [Travis CI][travis_ci_auth] with your [GitHub][github] account and accept the GitHub access permissions confirmation.
> 1. Once you’re signed in to Travis CI, and we’ve synchronized your GitHub repositories, go to your profile page and enable the repository you want to build: ![enable button][enable]
> 1. Add a `.travis.yml` file to your repository to tell Travis CI what to do.
> 1. Add the `.travis.yml` file to git, commit and push, to trigger a Travis CI build:
>    1. Travis only runs builds on the commits you push *after* you’ve enabled the repository in Travis CI.
> 1. Check the build status page to see if your build [passes or fails][travis_ci_build], according to the return status of the build command

Not too bad, right?  Don't worry, there isn't that much more even though the scroll bar indicates otherwise.

## Install the Travis Client

> The [travis gem][gem] includes both a [command line client][cli] and a [Ruby library][lib] to interface with a Travis CI service.

You'll need the Travis Client on your workstation for encrypting sensitive data such as access tokens as well as for [linting][lint] your `.travis.yml` file.

### Install Ruby

> #### Windows
>
> On Windows, we [recommend][windows] using the [RubyInstaller][installer], which includes the latest version of Ruby
>
> #### Mac OS X via Homebrew
>
> Mac OSX prior to 10.9 ships with a very dated Ruby version. You can use [Homebrew][homebrew] to install a recent version:
>
> ```bash
> brew install ruby
> gem update --system
> ```

### Install the Travis ruby gem

> Make sure you have at least [Ruby][ruby] 1.9.3 (2.0.0 recommended) installed.
> You can check your Ruby version by running `ruby -v`:
>
> ```bash
> ruby -v
> ruby 2.0.0p195 (2013-05-14 revision 40734) [x86_64-darwin12.3.0]
> ```
>
> Then run:
>
> ```bash
> gem install travis -v 1.8.8 --no-rdoc --no-ri
> ```
>
> Now make sure everything is working:
>
> ```bash
> travis version
> 1.8.8
> ```

*Continued in [Part 2][part_2].*

[project]: https://github.com/tlindsay42/ArmorPowerShell
[wahl]: http://wahlnetwork.com/2017/04/18/version-and-publish-powershell-appveyor/
[travis_ci_desc]: https://stackoverflow.com/questions/22587148/trying-to-understand-what-travis-ci-does-and-when-it-should-be-used
[programming]: https://en.wikipedia.org/wiki/Programming_language
[scripting]: https://en.wikipedia.org/wiki/Scripting_language
[rtfm]: https://en.wikipedia.org/wiki/RTFM
[travis_ci_auth]: https://travis-ci.org/auth
[github]: https://github.com
[travis_ci_build]: https://docs.travis-ci.com/user/customizing-the-build/#Breaking-the-Build
[enable]: {{ '/assets/images/enable.png' | relative_url }} 'enable button'
[lint]: https://en.wikipedia.org/wiki/Lint_(software) "validating"
[gem]: https://rubygems.org/gems/travis
[cli]: https://github.com/travis-ci/travis.rb#command-line-client
[lib]: https://github.com/travis-ci/travis.rb#ruby-library
[windows]: https://github.com/travis-ci/travis.rb#windows
[installer]: http://rubyinstaller.org/
[homebrew]: http://mxcl.github.io/homebrew/
[ruby]: http://www.ruby-lang.org/en/downloads/
[part_2]: {% post_url 2017-11-25-powershell-core-on-travis-ci-part-2 %}
