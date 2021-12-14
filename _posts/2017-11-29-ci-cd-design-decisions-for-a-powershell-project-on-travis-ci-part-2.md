---
type: 'post'
layout: single
title: CI/CD design decisions for a PowerShell project on Travis CI (part 2 of 2)
redirect_to: 'https://troylindsay.io/posts/2017-11-29-ci/cd-design-decisions-for-a-powershell-project-on-travis-ci/'
excerpt: 'Why I designed the {::nomarkdown}<strong>Armor PowerShell</strong> project the way I did.<br><br><iframe style="display: inline-block;" src="https://ghbtns.com/github-btn.html?user=tlindsay42&repo=armorpowershell&type=star&count=true&size=large" frameborder="0" scrolling="0" width="160px" height="30px"></iframe> <iframe style="display: inline-block;" src="https://ghbtns.com/github-btn.html?user=tlindsay42&repo=armorpowershell&type=fork&count=true&size=large" frameborder="0" scrolling="0" width="158px" height="30px"></iframe>{:/nomarkdown}'
published: true
last_modified_at: '2021-12-13'
header:
  overlay_image: '/assets/images/powershell_github_travis-ci.png'
  overlay_filter: 0.5
  teaser: '/assets/images/powershell_github_travis-ci.png'
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
## Tests Configuration

### Before Script

You can run custom commands prior to the build script step.  I have not had a need for this step yet.

If the before_script step exits with a non-zero error code, the build is marked as error and stops immediately.

```yaml
#before_script:
```

### Script

I call both my build script and test runner script here because non-zero error codes flag the build as a failure, but the build continues to run, which was what I wanted for these.  There is also an `after_script` section where I could have run my tests, but this step is run last, after the finalization `after_success` and `after_failure` steps (similar to the AppVeyor `on_finish` step), but also after the deploy steps.  Also, these three steps do not affect the build result unless the step times out, and I wanted both the build script and the test script to affect the build result.

```yaml
script:
- pwsh -file ./build/shared/build.ps1
- pwsh -file ./tests/start-tests.ps1
```

### Before Cache

This step is used to clean up your cache of files & folders that will persist between builds.  I have not needed this yet.  Again, tabula rasa.

```yaml
#before_cache:
```

### After Success / After Failure

> You can perform additional steps when your build succeeds or fails using the `after_success` (such as building documentation, or deploying to a custom server) or `after_failure` (such as uploading log files) options.

I chose to build my documentation in the `build.ps1` script in the script step instead of the `after_success` step, because I wanted failure to affect the build result in my project.

```yaml
# on successful build
#after_success:

# on build failure
#after_failure:
```

## Deployment Configuration

There are tons of continuous deployment options available in the [Deployment Configuration][deployment], such as Heroku, Engine Yard, and so many others, but I haven't needed any for this project so far because I am handling all of the publishing from AppVeyor.  The continuous deployment tasks could have been implemented just as easily from Travis CI, I just happened to finish the AppVeyor integration first and my publishing tasks only need to happen once per build.

```yaml
# scripts to run before deployment
#before_deploy:

#deploy:
  #skip_cleanup:

# scripts to run after deployment
#after_deploy:

# after build failure or success
#after_script:
```

## Notifications

It took me approximately one email to get tired of build email notifications.  I recommend disabling it in the [Notifications][notifications] section as shown below.  Next, there are tons of free options out there, but I chose to create a free Slack.com workspace for monitoring builds.  Travis CI has an app published in the Slack App Directory, and setup instructions can be found [here][slack].

```yaml
notifications:
  email: false
  slack:
  secure: <secure string>
```

## Conclusion

That's it for now.  I have really enjoyed using the Travis CI platform so far, and feel much more confident in the quality of my project because of it.

Enjoy!

[deployment]: https://docs.travis-ci.com/user/deployment/
[notifications]: https://docs.travis-ci.com/user/notifications/
[slack]: https://docs.travis-ci.com/user/notifications/#Configuring-slack-notifications
