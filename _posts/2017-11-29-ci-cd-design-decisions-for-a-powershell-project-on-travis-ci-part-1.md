---
type: 'post'
layout: single
title: CI/CD design decisions for a PowerShell project on Travis CI (part 1 of 2)
redirect_to: 'https://troylindsay.io/posts/2017-11-29-ci/cd-design-decisions-for-a-powershell-project-on-travis-ci/'
excerpt: 'Why I designed the {::nomarkdown}<strong>Armor PowerShell</strong> project the way I did.<br><br><iframe style="display: inline-block;" src="https://ghbtns.com/github-btn.html?user=tlindsay42&repo=armorpowershell&type=star&count=true&size=large" frameborder="0" scrolling="0" width="160px" height="30px"></iframe> <iframe style="display: inline-block;" src="https://ghbtns.com/github-btn.html?user=tlindsay42&repo=armorpowershell&type=fork&count=true&size=large" frameborder="0" scrolling="0" width="158px" height="30px"></iframe>{:/nomarkdown}'
published: true
last_modified_at: '2021-12-13'
header:
  overlay_image: '/assets/images/powershell_github_travis-ci.png'
  overlay_filter: 0.5
  teaser: '/assets/images/powershell_github_travis-ci.png'
classes: 'wide'
toc_icon: 'terminal'
categories:
- Automation
tags:
- Continuous Delivery
- Continuous Deployment
- Continuous Integration
- FOSS
- Free
- GitHub
- Linux
- macOS
- Microsoft
- Open source
- OSX
- Powershell
- Powershell Core
- Travis CI
- Ubuntu
meta:
  _wpcom_is_markdown: 1
  _thumbnail_id: 317
  _rest_api_published: 1
  _rest_api_client_id: -1
  _publicize_job_id: 11984220132
  _publicize_done_external: 'a:2:{s:7:"twitter";a:1:{i:18402702;s:59:"https://twitter.com/troylindsay42/status/936093553700278272";}s:8:"facebook";a:1:{i:18883722;s:38:"https://facebook.com/10155228267151314";}}'
  _publicize_done_18611616: 1
  _wpas_done_18402702: 1
  publicize_twitter_user: 'troylindsay42'
  publicize_google_plus_url: 'https://plus.google.com/+TroyLindsay/posts/2rLGUq65AQr'
  _publicize_done_18611618: 1
  _wpas_done_18402704: 1
  publicize_linkedin_url: 'https://www.linkedin.com/updates?discuss=&scope=19360941&stype=M&topic=6341859258858029056&type=U&a=3B2_'
  _publicize_done_18611619: 1
  _wpas_done_18402705: 1
  _publicize_done_19035169: 1
  _wpas_done_18883722: 1
---
Per my [previous post][post], this post covers my continuous integration / [continuous deployment][cd] design decisions for my open source [ArmorPowerShell project][armorpowershell].

## General Configuration

### Building Specific Branches

You can whitelist and/or blacklist branches [here][list], but I chose to build all branches in this project and included logic in the various scripts to limit actions prior to merging into master.

```yaml
# whitelist
#branches:
  #only:
    #- master

# blacklist
#branches:
  #except:
    #-
```

### Jobs

You can granularly define build stages as well as conditional builds based on criteria such as branch, release tag, et cetera in the [Jobs][jobs] section.  I have not implemented this so far.

```yaml
#jobs:
  #include:
    #- stage:
```

### Language

I recommend setting the [Language][language] to `generic` for scripting language projects (which is not listed in the Language documentation, but is briefly mentioned [here][multi-os]), because all I needed for installing PowerShell Core was bash, curl, & apt for Ubuntu and homebrew for macOS, but there are a wide variety of choices if you require otherwise.

```yaml
language: generic
```

### Runtime

You can also define specific [runtime][runtime] versions for certain applications.  If more than one runtime version is specified for the same item, a job will be created for each version.  I did not need to implement any of these for this project though.

```yaml
#dotnet:
#gemfile:
#mono:
#php:
#python:
#rvm:
```

### Git

In the Git section, you can specify a [clone depth limit][clone depth] or [disable cloning of submodules][submodules] to optimize job performance.  As of 20171128, the default commit depth on Travis CI is `50`, which should provide sufficient commit history for most projects with accommodation for job queuing.

```yaml
#git:
  #depth:
  #submodules:
```

## Environment Configuration

### Environment Variables

If you plan to test your open-source PowerShell project on multiple CI providers such as Travis CI and AppVeyor, I recommend defining a few global [environment variables][env vars] such as the ones listed below that abstract the CI specific variables to minimize the logic needed for handling each in your build scripts.  If you define a variable more than once, another job will be created for each definition.  You can also define matrix-specific environment variables in this section, or at the image level in the Matrix section.

```yaml
# environment variables
env:
 global:
 - BUILD_PATH="$TRAVIS_BUILD_DIR"
 - MODULE_NAME="&lt;insert module name&gt;"
 - MODULE_PATH="$BUILD_PATH/$MODULE_NAME"
 - MODULE_VERSION="{set module version in build script}"
 - OWNER_NAME="$(echo $TRAVIS_REPO_SLUG | cut -d '/' -f1)"
 - PROJECT_NAME="$(echo $TRAVIS_REPO_SLUG | cut -d '/' -f2)"
 - secure: <secure string>
  #matrix:
```

### Services

There are lots of terrific [services and databases][svcs] that are installed and available in each image should you need them.

```yaml
# enable service required for build/tests
#services:
  #- cassandra # start Apache Cassandra
  #- couchdb # start CouchDB
  #- elasticsearch # start ElasticSearch
  #- memcached # start Memcached
  #- mongodb # start MongoDB
  #- mysql # start MySQL
  #- neo4j # start Neo4j Community Edition
  #- postgresql # start PostgreSQL
  #- rabbitmq # start RabbitMQ
  #- redis-server # start Redis
  #- riak # start Riak
```

### Global Image Settings

You can define your build images at the global scope; however, I chose to use the matrix build image configuration as recommended [here][multi-os] for multiple operating system build configurations, because it is cleaner.  For example, when `osx_image` is defined at the global scope, your Ubuntu builds will receive the `xcode` tag, even though it does not apply.

{% include figure image_path="/assets/images/xcode-tag.png" caption="xcode tag assigned to Ubuntu Trusty build image" %}

![xcode tag assigned to Ubuntu Trusty build image]({{ '/assets/images/xcode-tag.png' | relative_url }})

```yaml
# Build worker image (VM template)
#os:
#- linux
#- osx

#sudo: required

#dist: trusty

#osx_image: xcode9.1
```

### Build Matrix

The [Matrix][matrix] section allows you to customize each image that will build your code.  I cover most of these features sufficiently in the [previous post][post], but the two that I did not are:

1. [allow_failures][allow_failures], which will permit the specified build image to pass regardless of any errors that occur.  I'll likely never use this feature because it defeats the purpose of implementing continuous integration in my opinion.
1. [exclude][exclude], which prevents building specified images when you define combinations of environment variables, runtime versions, and/or matrix images.  I don't foresee my scripting language projects being complicated enough to require this feature.

```yaml
matrix:
  include:
    - os: linux
      dist: trusty
      sudo: false
      addons:
        apt:
          sources:
            - sourceline: "deb [arch=amd64] https://packages.microsoft.com/ubuntu/14.04/prod trusty main"
              key_url: "https://packages.microsoft.com/keys/microsoft.asc"
          packages:
            - powershell
    - os: osx
      osx_image: xcode9.1
      before_install:
        - brew tap caskroom/cask
        - brew cask install powershell 
  fast_finish: true
  #allow_failures:
  #exclude:
```

### Add-Ons

In the [addons][addons] section, you can define hostnames, prepare for headless testing, upload build artifacts, add SSH known hosts, et cetera.  I have not needed any of these so far for this project.

```yaml
#addons:
  #artifacts:
    #paths:
      #-
  #chrome:
  #firefox:
  #hosts:
  #mariadb:
  #rethinkdb:
  #sauce_connect:
    #username:
    #access_key:
  #ssh_known_hosts:
```

#### APT Add-ons

> To install packages not included in the default [container-based-infrastructure][container] you need to use the APT addon, as `sudo apt-get` is not available.

For now, I have only used this to setup the Microsoft PowerShell Core package management repository and install PowerShell Core on my Ubuntu Trusty container image defined in my build matrix.

If the APT Add-ons step exits with a non-zero error code, the build is marked as error and stops immediately.

```yaml
#addons:
  #apt:
    #sources:
      #- sourceline:
        #key_url:
    #packages:
      #-
```

### Build Cache

You can [cache][cache] files and folders to preserve them between builds such as if you have low-volatility, large files that take a while to clone.  I did not.  Tabula rasa.

If the cache step exits with a non-zero error code, the build is marked as error and stops immediately.

```yaml
# build cache to preserve files/folders between builds
#cache:
```

### Before Install

> In a `before_install` step, you can install additional dependencies required by your project such as Ubuntu packages or custom services.

One important thing to be aware of is that matrix image instructions *override* global instructions.  Since I placed the homebrew commands to install PowerShell in the Before Install step of the macOS build matrix image, if I were to define a global Before Install step, the macOS build matrix image would ignore it.  Alternatively, you could use [conditional logic][condition] in the global step if you only wanted to perform some instructions on a specific operating system, and some on all build images.

If the before_install step exits with a non-zero error code, the build is marked as error and stops immediately.

```yaml
#before_install:
```

### Install

As of 20171128, there is no default dependency installation step for PowerShell projects on Travis CI.  In the install step, I chose to install and import the necessary PowerShell modules on all build images, and implemented it via a PowerShell script so that I always utilize the same logic in my AppVeyor builds with no additional configuration (ie: [DRY][dry]).

If the install step exits with a non-zero error code, the build is marked as error and stops immediately.

```yaml
install:
- pwsh -file ./build/shared/install-dependencies.ps1
```

[post]: {% post_url 2017-11-25-powershell-core-on-travis-ci-part-1 %}
[cd]: https://www.atlassian.com/continuous-delivery/ci-vs-ci-vs-cd
[armorpowershell]: https://github.com/tlindsay42/ArmorPowerShell
[list]: https://docs.travis-ci.com/user/customizing-the-build/#Building-Specific-Branches
[jobs]: https://docs.travis-ci.com/user/build-stages/using-yaml-aliases/
[language]: https://docs.travis-ci.com/user/language-specific/
[multi-os]: https://docs.travis-ci.com/user/multi-os/
[runtime]: https://docs.travis-ci.com/user/customizing-the-build#Specifying-Runtime-Versions
[submodules]: https://docs.travis-ci.com/user/customizing-the-build/#Git-Submodules
[env vars]: https://docs.travis-ci.com/user/environment-variables
[svcs]: https://docs.travis-ci.com/user/database-setup/
[matrix]: https://docs.travis-ci.com/user/customizing-the-build#Build-Matrix
[allow_failures]: https://docs.travis-ci.com/user/customizing-the-build#Rows-that-are-Allowed-to-Fail
[exclude]: https://docs.travis-ci.com/user/customizing-the-build#Excluding-Jobs
[addons]: https://docs.travis-ci.com/user/addons/
[container]: https://docs.travis-ci.com/user/reference/overview/#virtualization-environments
[cache]: https://docs.travis-ci.com/user/caching
[condition]: https://docs.travis-ci.com/user/installing-dependencies/#Installing-Dependencies-on-Multiple-Operating-Systems
[dry]: https://en.wikipedia.org/wiki/Don%27t_repeat_yourself "Don't Repeat Yourself"
