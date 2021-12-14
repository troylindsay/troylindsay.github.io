---
type: 'post'
layout: 'single'
title: 'Free CI for your GitHub forks'
redirect_to: 'https://troylindsay.io/posts/2017-11-30-free-ci-for-your-github-forks/'
excerpt: 'How to build & test your feature branch for free on AppVeyor & Travis CI before submitting a pull request.'
published: true
last_modified_at: '2021-12-13'
header:
  overlay_image: '/assets/images/technology-3389917.jpg'
  overlay_filter: 0.5
  teaser: '/assets/images/technology-3389917_640.jpg'
classes: 'wide'
toc: false
categories:
- 'Automation'
tags:
- 'Appveyor'
- 'Continuous Integration'
- 'FOSS'
- 'Free'
- 'GitHub'
- 'Open source'
- 'Travis CI'
meta:
  _wpcom_is_markdown: 1
  _thumbnail_id: 329
  _publicize_done_external: 'a:2:{s:7:"twitter";a:1:{i:18402702;s:59:"https://twitter.com/troylindsay42/status/936126669504487424";}s:8:"facebook";a:1:{i:18883722;s:38:"https://facebook.com/10155228409521314";}}'
  _rest_api_published: 1
  _rest_api_client_id: -1
  _publicize_job_id: 11987160237
  _publicize_done_18611616: 1
  _wpas_done_18402702: 1
  publicize_twitter_user: 'troylindsay42'
  publicize_google_plus_url: 'https://plus.google.com/+TroyLindsay/posts/1GzJHhXUeDJ'
  _publicize_done_18611618: 1
  _wpas_done_18402704: 1
  publicize_linkedin_url: 'https://www.linkedin.com/updates?discuss=&scope=19360941&stype=M&topic=6341892382329499648&type=U&a=OCK1'
  _publicize_done_18611619: 1
  _wpas_done_18402705: 1
  _publicize_done_19035169: 1
  _wpas_done_18883722: 1
---
I had an epiphany the other day when troubleshooting an issue with a pull request that I had submitted, which is that you can have [AppVeyor][appveyor] and [Travis CI][travis_ci] (free CI/CD services for public repos) build & test your commits to your fork's feature branch on push by simply enabling the repo in your AppVeyor and/or Travis CI accounts.  In this instance, my changes had worked on my Fedora image, but the build failed on Travis CI's Ubuntu Trusty image.  Had I thought of this beforehand, I would have been able to detect and resolve the issue before submitting the pull request.  This is especially useful if you are attempting to help augment and/or optimize the project's build configuration.

Also, you can implement this even if the project doesn't use either of these CI/CD services or if the owners do not store the build configuration in the respective YAML file.  The caveat is that in either case, you would have to configure the CI services yourself.

To start building & testing a new project in AppVeyor, go [here][av_new], and for Travis CI, go to your profile page.

![Enable a new project in AppVeyor](/assets/images/appveyor_new-project.png){: .align-center}

![Enable a new project in Travis CI](/assets/images/travis-ci_new-project.png){: .align-center}

So far, I have used this methodology to provide screenshots and build logs as evidence in a couple of pull requests.  I have also used this to create and submit a Travis CI build configuration for a project that was only using AppVeyor and demonstrated how it would work if merged.  Pretty cool, right?

Enjoy!

[appveyor]: https://www.appveyor.com/
[travis_ci]: https://travis-ci.org/
[av_new]: https://ci.appveyor.com/projects/new
