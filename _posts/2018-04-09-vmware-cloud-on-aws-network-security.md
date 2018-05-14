---
type: 'post'
layout: 'single'
title: 'VMware Cloud on AWS: Network Security'
excerpt: 'Product review focused on the current network security features'
date: 2018-04-09 07:00:59 -05:00
published: true
toc_icon: 'fire'
header:
  overlay_image: '/assets/images/pixabay-network-3396348.jpg'
  overlay_filter: 0.5
  teaser: '/assets/images/pixabay-network-3396348_640.jpg'
  caption: '[**pixabay**](https://pixabay.com/en/network-data-connection-technology-3396348/)'
categories:
- 'Automation'
- 'Cloud Computing'
- 'Networking'
- 'Security'
- 'Virtualization'
tags:
- 'AWS'
- 'Firewall'
- 'NSX'
- 'Product review'
- 'SDDC'
- 'vExpert'
- 'VMC'
- 'VMUG'
- 'VMware'
- 'VMware Cloud on AWS'
- 'vSphere'
meta:
  _wpcom_is_markdown: 1
  _rest_api_published: 1
  _rest_api_client_id: -1
  publicize_twitter_user: 'troylindsay42'
  publicize_linkedin_url: 'https://www.linkedin.com/updates?discuss=&scope=19360941&stype=M&topic=6389080115732631552&type=U&a=cd2Q'
  _publicize_job_id: 16616185215
  timeline_notification: 1523275398
  _publicize_done_external: 'a:2:{s:7:"twitter";a:1:{i:18402702;s:59:"https://twitter.com/troylindsay42/status/983314411224956928";}s:8:"facebook";a:1:{i:18883722;s:38:"https://facebook.com/10155585035686314";}}'
  _publicize_done_18611616: 1
  _wpas_done_18402702: 1
  publicize_google_plus_url: 'https://plus.google.com/+TroyLindsay/posts/McFZQvbFecM'
  _publicize_done_18611618: 1
  _wpas_done_18402704: 1
  _publicize_done_18611619: 1
  _wpas_done_18402705: 1
  _publicize_done_19035169: 1
  _wpas_done_18883722: 1
---
## Overview

I recently had the opportunity to play with a four host VMware Cloud on AWS (VMC) <abbr title="Software-Defined Datacenter">SDDC</abbr> for a month as part of an extracurricular, open source, VMUG project using HashiCorp Terraform to automate the provision of virtual infrastructure for a VMware-oriented hackathon, but I'll discuss the project more in depth in an [upcoming post][post].  I learned a lot during the trial and am very grateful for the opportunity.

## Getting Started

If you haven't read the [VMC Getting Started Guide][guide], here are a couple of important items:

1. You'll need to create a few firewall rules from the VMC portal to access your SDDC.  By default, both the Management Gateway's (MGW) and Compute Gateway's (CGW) firewall policy default to deny all, so no traffic is permitted to or from either environment until you allow it.
    * <abbr title="Management Gateway">**MGW**</abbr>: NSX Edge Services Gateway (ESG) that secures the north/south traffic to and from the VMC vCenter Server, ESXi hosts, and NSX Manager
    * <abbr title="Customer Gateway">**CGW**</abbr>: ESG that secures north/south traffic to and from the VMs that you provision and control in your SDDC.
1. Since this is a managed service, the rules that you can create on the Management Gateway are restricted to specific services for specific endpoints.  For example, you cannot create a rule permitting SSH access to the ESXi hosts in the environment, but you can permit ICMP so that you can monitor host availability via ping.

## Constraints

### Firewall Services

One thing that I found interesting is that VMC only permits one service entry per firewall rule, which can be a TCP or UDP port (eg: `80/tcp`), an ICMP type (eg: `0 Echo Reply`), a range of TCP or UDP ports (eg: `49152-65535/tcp`), all TCP, all UDP, or all ICMP, or any, but cannot be configured for multiple, non-contiguous services (eg: `80/tcp, 443/tcp`) per [the guide][fw].  Permitting this connectivity must be written as separate rules in VMC.  Implementing a single target service object standard such as this is one way to help design a firewall policy that can be easy to read, troubleshoot, and administer if implemented properly, but I was a little surprised that this was mandated since the firewall functionality of the NSX platform is so robust.  This is also a constraint of firewall rules in AWS VPC security groups, but it seems odd in a NSX environment.

### Firewall Grouping Objects

Next, reusable NSX grouping objects, such as IPSets, security groups, custom service objects, and service groups are not yet available in VMC.  This made the initial bit of manual firewall policy management to be tedious since I have been spoiled by the convenience of these.

### Use Case Example

To illustrate the challenge posed by the combination of these limitations, imagine provisioning a new Active Directory domain controller in your VMC SDDC for an existing domain residing outside the SDDC and you had a requirement of only permitting the minimum necessary connectivity.  You would have to write and manage over 20 separate firewall rules per [the guide][dc] with the domain controller IP address statically defined in either the source or destination of each rule (as appropriate) to accomplish this because of the single service/service-range constraint.

If you then needed to provision another domain controller for that domain in your SDDC and wanted to permit the same connectivity to & from the original domain controller and also maintain your requirement of permitting the minimum necessary connectivity, you would need to modify the sources and/or destinations of the existing 20+ rules (or add 20+ new rules) because of the lack of reusable firewall grouping objects.

If NSX grouping objects were available, you could consolidate the rules to a small handful with service groups that permitted the same traffic for the first domain controller and maintain the single target service (group) object.  To permit the traffic for the second domain controller (assuming that dynamic security groups and security groups with parent infrastructure objects weren't used for firewall policy to be automatically updated and applied), you would only have to make one change instead of multiple.  Examples include adding the new IP address to the IPSet object, creating a new IPSet and adding it to the security group object, and adding the VM object to the security group object.

### Distributed Firewall

Another challenge to maintaining a strong network security posture is that the VMC SDDC distributed firewall is not yet configurable; however, this feature is currently listed as Planned in [the public roadmap][roadmap].  An alternative for controlling east/west traffic in the mean time is to use host-based firewalls.

## Conclusion

There are so many neat and effective ways to administer firewall policy with NSX, so this was one area that could use improvement and my only real point of constructive criticism from the trial period.  Overall, I was impressed with the excellence in architecture, engineering, and service delivery demonstrated by the VMC platform.

## Acknowledgements

Special thanks to [Ken Nalbone][kn], [Wences Michel][wm], and [Brian Graf][bg] for this great learning opportunity.

[post]: {% post_url 2018-04-10-using-terraform-to-deploy-nested-esxi-hosts %}
[guide]: https://docs.vmware.com/en/VMware-Cloud-on-AWS/services/com.vmware.vmc-aws.getting-started/GUID-3D741363-F66A-4CF9-80EA-AA2866D1834E.html
[fw]: https://docs.vmware.com/en/VMware-Cloud-on-AWS/services/com.vmware.vmc-aws.getting-started/GUID-0E66C9C8-C260-4056-8511-44818431110C.html
[dc]:https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/dd772723(v=ws.10)
[roadmap]: https://cloud.vmware.com/vmc-aws/roadmap "I <3 public roadmaps!"
[kn]: https://fullstackkengineer.com/ "Ken's blog"
[wm]: https://m1labs.co/ "Wences' blog"
[bg]: http://www.brianjgraf.com/ "Brian's blog"
