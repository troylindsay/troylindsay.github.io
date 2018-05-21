---
type: 'post'
layout: 'single'
title: 'PowerShell Core on Travis CI (part 2 of 3)'
excerpt: 'How to build, test, and deploy your PowerShell projects on Linux and macOS for free with Travis CI! {::nomarkdown}<br><br>Example available in the <strong>Armor PowerShell</strong> project.<br><br><iframe style="display: inline-block;" src="https://ghbtns.com/github-btn.html?user=tlindsay42&repo=armorpowershell&type=star&count=true&size=large" frameborder="0" scrolling="0" width="160px" height="30px"></iframe> <iframe style="display: inline-block;" src="https://ghbtns.com/github-btn.html?user=tlindsay42&repo=armorpowershell&type=fork&count=true&size=large" frameborder="0" scrolling="0" width="158px" height="30px"></iframe>{:/nomarkdown}'
published: true
last_modified_at: '2018-05-20'
header:
  overlay_image: '/assets/images/powershell_github_travis-ci.png'
  overlay_filter: 0.5
  teaser: '/assets/images/powershell_github_travis-ci.png'
toc_icon: 'terminal'
classes: 'wide'
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
## Customizing the build

Travis CI's documentation of the .travis.yml file sprawls quite a bit as there are so many features available, so I'll start with an example .travis.yml config file that should work for testing most of your open-source PowerShell projects on the Travis CI platform.  In my next post, I will provide a high-level overview of all of the available options that I found in the documentation for reference, as well as my design decisions for the ArmorPowerShell project.

### Example .travis.yml config file

To start testing your open-source PowerShell project on macOS & Ubuntu, copy the contents below to a file named `.travis.yml` in the base directory of your project.

#### .travis.yml

```yaml
language: generic

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

install:
  - pwsh -f "${env:TRAVIS_BUILD_DIR}/install-dependencies.ps1"

before_script:
  - pwsh -f "${env:TRAVIS_BUILD_DIR}/build.ps1"

script:
  - pwsh -f "${env:TRAVIS_BUILD_DIR}/test.ps1"

after_success:
  - pwsh -f "${env:TRAVIS_BUILD_DIR}/deploy.ps1"
```

##### NOTES

* The powershell executable name has been shortened to `pwsh` as of [v6.0.0-beta.9][pwsh].
* There are a few lines that call PowerShell to execute a file, such as `pwsh -f "${env:TRAVIS_BUILD_DIR}/install-dependencies.ps1"` in the base directory of the project, fully-pathed through the `TRAVIS_BUILD_DIR` [environment variable][env_var], but these are by no means necessary.  You could store these files in sub-directories, give the files different names, call commands instead of files, or do something else entirely- these are all just ideas to stimulate your imagination; however, whatever logic you define needs to be valid or your build will fail.

### What does this .travis.yml config file do?

* **language:** This defines the programming language that the build system should use.
  * I set this to `generic`, because I am building a scripting language project.
  * The generic setting is not documented in the [Travis CI Languages documentation][language], but is listed in a few examples, such as [this one][example].
* **matrix:** The Matrix section allows you to customize each image that will build your code.
  * **include:** Include the specified image configurations.  All configurations defined for an image in the matrix will override the corresponding global configuration.  For example, I configured a `before_install` section in the `osx` image above, so if I had a global `before_install` section defined in the `.travis.yml` config file, the macOS image would skip it.  Excludes can also be defined for here more complex build topologies.
    * **os:** The operating system of the image.  As of 20171125, the two choices are `osx` (macOS) and `linux` (Ubuntu).
    * **dist:** The Ubuntu Linux distro image.  As of 20171125, the two choices are `trusty` (Ubuntu 14.04 LTS Trusty Tahr) and `precise` (Ubuntu 12.04 LTS Precise Pangolin, which is end of life).
    * **sudo:** This purpose of this [setting][sudo] is almost certainly not what you think.  Setting sudo to `false` in your Trusty images causes your build to be deployed to a container instead of a VM, which will start up and complete much faster than the VM image.  Unfortunately, as of 20171125, there is not a containerized option for macOS yet.  If you want or need to use an Linux VM image, set sudo to `required`.  I have had no issues with building or testing my code inside a container so far.  I will update the article if I discover a blocking issue, but I don't expect to at this point since the PowerShell Core team publishes nightly builds on [Docker Hub][docker_hub] and of note, they also build on [Travis CI][builds].
    * **addons:** There is a lot that can be configured in the addons section, but for now, we're only going to use this for the Trusty image to add the appropriate Microsoft software repository where the official PowerShell Core binaries are hosted, the software repository key, and to install PowerShell Core per the recommended methodology as defined in the [PowerShell Core Install Guide][guide].
      * **apt:** The default package management tool for Ubuntu.
        * **sources:** Software repositories to add.
          * **sourceline:** The software repository configuration.
          * **key_url:** The public key for encrypting the traffic.
        * **packages:** Software packages to install
          * **powershell:** Install PowerShell Core on Linux, please and thank you.
    * **osx_image:** The macOS image that you want to use.
      * As of 20171125, the Travis CI default is `7.3`, which is an older macOS 10.11 image.
      * The official PowerShell install guide only lists support for macOS 10.12; however, I have performed a few basic functional tests on osx images: `7.3` (10.11) & `6.4` (10.10). PowerShell Core installed, and completed the build and test runs successfully without any additional configuration on macOS 10.11, but failed on macOS 10.10.
        * PowerShell Core may work on macOS 10.10 with additional configuration, but I am not interested in researching this any further at this time.
      * If you are concerned about breaking changes between macOS versions, you can duplicate the osx matrix image section and replace the value of osx_image with a different version.
        * Available image versions can be found [here][osx].
    * **before_install:** This matrix image section overrides the global before_install configuration for our osx image, and is used for installing PowerShell Core as defined in the [installation guide][macos_guide].
      * **brew tap caskroom/cask:** [reference][caskroom]
        > Homebrew-Cask extends Homebrew and brings its elegance, simplicity, and speed to macOS applications and large binaries alike.
      * **brew cask install powershell:** Install PowerShell Core on macOS, please and thank you.
  * **fast_finish:** Job failures halt the build.  If you would rather have the build attempt to continue on error, change the value to `false`.
* **install:** This section can be used for calling the PowerShell script to install dependencies, such as any modules needed to build and/or test the script.
  * I highly recommend storing the logic for each section in a separate file so that:
    1. It is easier for you to reuse & maintain code if you choose to also integrate with [AppVeyor][appveyor] for testing your open-source project for free on Windows PowerShell as well, and also...
    1. ...because of the inherent challenges with embedding code in code.
  * The [build lifecycle][build_lifecycle] order of operations has the install section follow the before_install section and precedes the before_script section.
  * Here is my [install-dependencies.ps1][dependencies] script for the ArmorPowerShell project.
* **before_script:** This section can be used for calling your PowerShell build script to do things such as update the module manifest, update the documentation, et cetera.
  * Here is my [build.ps1][build] script for the ArmorPowerShell project.
* **script:** This section can be used for calling your PowerShell unit, integration, and/or functional test scripts.
  * If you are new to these concepts, I recommend reading up on those topics, as well as [Pester][pester].
  * Here is my [start-tests.ps1][start_tests] script for the ArmorPowerShell project.
* **after_success:** This section can be used for calling a deployment script if that makes sense for your project, such as publishing your module, script, et cetera to the [PowerShell Gallery][psgallery], [NuGet][nuget], [Chocolatey][chocolatey], [GitHub Releases][ghreleases], et cetera.
  * Here is my [publish-psgallery.ps1][publish] script for the ArmorPowerShell project.

Travis CI is an extremely powerful platform with tons of other features that you can take advantage of, but that is all that I am going to cover in this post as to the possibilities available in the .travis.yml config file.

*Continued in [Part 3][part_3].*

[pwsh]: https://github.com/PowerShell/PowerShell/releases/tag/v6.0.0-beta.9
[env_var]: https://docs.travis-ci.com/user/environment-variables
[language]: https://docs.travis-ci.com/user/languages/
[example]: https://docs.travis-ci.com/user/multi-os/#Python-example-(unsupported-languages)
[sudo]: https://docs.travis-ci.com/user/reference/overview/
[docker_hub]: https://hub.docker.com/r/microsoft/powershell/
[builds]: https://travis-ci.org/PowerShell/PowerShell/builds/307043228
[guide]: https://github.com/PowerShell/PowerShell/blob/master/docs/installation/linux.md#ubuntu-1404
[osx]: https://docs.travis-ci.com/user/reference/osx/#OS-X-Version
[macos_guide]: https://github.com/PowerShell/PowerShell/blob/master/docs/installation/linux.md#macos-1012
[caskroom]: https://caskroom.github.io/
[appveyor]: https://www.appveyor.com/
[build_lifecycle]: https://docs.travis-ci.com/user/customizing-the-build/#The-Build-Lifecycle
[dependencies]: https://github.com/tlindsay42/ArmorPowerShell/blob/v1.0.0.103/build/shared/install-dependencies.ps1
[build]: https://github.com/tlindsay42/ArmorPowerShell/blob/v1.0.0.103/build/shared/build.ps1
[pester]: https://github.com/pester/Pester
[start_tests]: https://github.com/tlindsay42/ArmorPowerShell/blob/v1.0.0.103/tests/start-tests.ps1
[psgallery]: https://www.powershellgallery.com/
[nuget]: https://www.nuget.org/
[chocolatey]: https://chocolatey.org/
[ghreleases]: https://docs.travis-ci.com/user/deployment/releases/
[publish]: https://github.com/tlindsay42/ArmorPowerShell/blob/v1.0.0.103/build/appveyor/publish-psgallery.ps1
[part_3]: {% post_url 2017-11-25-powershell-core-on-travis-ci-part-3 %}
