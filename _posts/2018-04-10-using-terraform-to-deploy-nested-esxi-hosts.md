---
type: 'post'
layout: 'single'
title: 'Using Terraform to deploy Nested ESXi hosts'
excerpt: 'in your VMware Cloud on AWS SDDC (or home lab!) with the Virtually Ghetto vSphere 6.5 U1 ESXi virtual appliance. {::nomarkdown}<br><br>Example available in the <strong>VMUG-Labs</strong> project.<br><br><iframe style="display: inline-block;" src="https://ghbtns.com/github-btn.html?user=vmug-labs&repo=vmug-labs&type=star&count=true&size=large" frameborder="0" scrolling="0" width="160px" height="30px"></iframe> <iframe style="display: inline-block;" src="https://ghbtns.com/github-btn.html?user=vmug-labs&repo=vmug-labs&type=fork&count=true&size=large" frameborder="0" scrolling="0" width="158px" height="30px"></iframe>{:/nomarkdown}'
date: '2018-04-10 12:28:18 -05:00'
published: true
classes: 'wide'
toc: true
toc_icon: 'user-astronaut'
header:
  overlay_image: '/assets/images/pixabay-solaris-3365405.jpg'
  overlay_filter: 0.5
  teaser: '/assets/images/pixabay-solaris-3365405_640.jpg'
  caption: '[**pixabay**](https://pixabay.com/en/solaris-world-earth-watts-sea-3365405/)'
  cta_label: 'GitHub Repository'
  cta_url: 'https://github.com/vmug-labs/vmug-labs'
categories:
- 'Automation'
- 'Cloud Computing'
- 'Virtualization'
tags:
- 'ESXi'
- 'FOSS'
- 'Free'
- 'HashiCorp'
- 'Home'
- 'Hypervisor'
- 'Lab'
- 'Nested'
- 'Open source'
- 'PowerCLI'
- 'PowerShell'
- 'SDDC'
- 'Terraform'
- 'vExpert'
- 'VMC'
- 'VMUG'
- 'VMware'
- 'VMware Cloud on AWS'
- 'vSphere'
meta:
  _wpcom_is_markdown: 1
  _wp_old_date: '2018-04-09'
  _rest_api_published: 1
  _rest_api_client_id: -1
  _publicize_job_id: 16660958368
  _publicize_done_external: 'a:2:{s:7:"twitter";a:1:{i:18402702;s:59:"https://twitter.com/troylindsay42/status/983758591306936320";}s:8:"facebook";a:1:{i:18883722;s:38:"https://facebook.com/10155587930016314";}}'
  _publicize_done_18611616: 1
  _wpas_done_18402702: 1
  publicize_twitter_user: 'troylindsay42'
  timeline_notification: 1523381300
  publicize_google_plus_url: 'https://plus.google.com/+TroyLindsay/posts/NPZGZb2kSog'
  _publicize_done_18611618: 1
  _wpas_done_18402704: 1
  publicize_linkedin_url: 'https://www.linkedin.com/updates?discuss=&scope=19360941&stype=M&topic=6389524296393375744&type=U&a=Mhgz'
  _publicize_done_18611619: 1
  _wpas_done_18402705: 1
  _publicize_done_19035169: 1
  _wpas_done_18883722: 1
---
## Overview

As I mentioned in the [previous post][post], I recently started a new open source <abbr title="VMware Users Group">VMUG</abbr> project with some new friends with a goal of automatically provisioning the necessary virtual infrastructure for VMware-oriented hackathons on the VMware Cloud on AWS (VMC) platform using HashiCorp Terraform and Gruntwork Terragrunt, in a simple and cost effective manner.  The project is called VMUG Labs and the source code can be found in the [GitHub repository][repo].

As indicated by the title of this post, you would only need to make a few tweaks to make this work in your home lab, work lab, or any vSphere environment where you want to deploy nested ESXi hosts, because VMC can use the standard Terraform VMware vSphere provider for provisioning VMs in your <abbr title="Software-Defined Datacenter">SDDC</abbr>.  I'll cover how to use Terraform to deploy nested ESXi hosts in your lab in more detail in the next post.

## Prerequisites

Once I had provisioned a few [firewall rules][post] and a [logical network][logical_network] in my SDDC, the first VM that I deployed in VMC (manually) was William Lam's [vSphere ESXi 6.5 U1 virtual appliance][vghetto] to use as my template VM for Terraform.

For those that are unfamiliar, his virtual appliance image facilitates provisioning automation by allowing the user to supply operating system configuration values such as hostname, IP address, et cetera, via [vApp properties][vapp_properties] at provision time for achieving guest customization of the ESXi host VM (aka: nested hypervisor).

Next, you must set the `debug` vApp property in your VM template to be user configurable because the Terraform vSphere provider v1.3.3 and earlier does not support this.  Attempts to deploy VMs from a VM or VM template with any vApp property that is not configurable will fail as documented in [issue #394][394].  I made a few minor adjustments to a copy of David Hekimian's PowerCLI script for doing so and the source code can be found [here][script].  Run the following PowerShell script against your nested ESXi VM that you plan to use as a template:

```powershell
./Enable-VmVappProperties.ps1 -Name 'Nested_ESXi6.5u1_Appliance_Template_v1.0'
```

## Constraints

It is important to note that you are restricted from enabling the [promiscuous mode][promiscuous_mode] and the [forged transmits][forged_transmits] distributed port group security settings in VMC, so VMs running on nested hypervisors will be isolated (no network connectivity beyond the hypervisor).  This constraint was not unexpected, but does limit the possibilities of what we can build somewhat.  After much deliberation, our team came to the conclusion that most attendees of VMware-oriented hackathons would primarily want to interact with the virtual infrastructure and we accepted this limitation for the project.  This constraint should not apply to your lab environments though.

Next, all VMs must be deployed under specific virtual infrastructure objects in your VMC SDDC- specifically, the `Compute-ResourcePool` resource pool, the `Workloads` VM folder, and the `WorkloadDatastore` datastore that are all found under the `SDDC-Datacenter` datacenter object.

## Configure

To configure Terraform to provision your first nested ESXi host, you need to:

1. Create a Terraform configuration file, such as `main.tf`.
1. Configure the provider for connecting to vCenter
    ```ruby
    provider "vsphere" {
      version="~> 1.3"
      vsphere_server="vcenter.sddc-34-218-61-195.vmc.vmware.com" # Set this to your VMC SDDC FQDN
      allow_unverified_ssl=false
      user="cloudadmin@vmc.local"
      password="VMware1!" # Set this to your VMC SDDC password
    }
    ```
1. Configure data sources to retrieve information about the virtual infrastructure objects
    ```ruby
    data "vsphere_datacenter" "dc" {
      name="SDDC-Datacenter"
    }

    data "vsphere_resource_pool" "pool" {
      name="Compute-ResourcePool"
      datacenter_id="${data.vsphere_datacenter.dc.id}"
    }

    data "vsphere_datastore" "datastore" {
      name="WorkloadDatastore"
      datacenter_id="${data.vsphere_datacenter.dc.id}"
    }

    data "vsphere_distributed_virtual_switch" "dvs" {
      name="vmc-dvs"
      datacenter_id="${data.vsphere_datacenter.dc.id}"
    }

    data "vsphere_network" "network" {
      name="logical_network1"
      datacenter_id="${data.vsphere_datacenter.dc.id}"
    }
    ```
1. Configure the data source to retrieve information about the nested ESXi host VM template
    ```ruby
    data "vsphere_virtual_machine" "template" {
      name="Nested_ESXi6.5u1_Appliance_Template_v1.0"
      datacenter_id="${data.vsphere_datacenter.dc.id}"
    }
    ```
1. And now configure your first nested ESXi VM resource!
    ```ruby
    resource "vsphere_virtual_machine" "vm" {
      name="ESXi1"
      guest_id="vmkernel65Guest"
      resource_pool_id="${data.vsphere_resource_pool.pool.id}"
      datastore_id="${data.vsphere_datastore.datastore.id}"
      folder="Workloads"
      num_cpus=2
      memory=6144
      wait_for_guest_net_timeout=0

      network_interface {
        network_id="${data.vsphere_network.network.id}"
      }

      disk {
        label="sda"
        unit_number=0
        size="${data.vsphere_virtual_machine.template.disks.0.size}"
        eagerly_scrub="${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
        thin_provisioned="${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
      }

      disk {
        label="sdb"
        unit_number=1
        size="${data.vsphere_virtual_machine.template.disks.1.size}"
        eagerly_scrub="${data.vsphere_virtual_machine.template.disks.1.eagerly_scrub}"
        thin_provisioned="${data.vsphere_virtual_machine.template.disks.1.thin_provisioned}"
      }

      disk {
        label="sdc"
        unit_number=2
        size="${data.vsphere_virtual_machine.template.disks.2.size}"
        eagerly_scrub="${data.vsphere_virtual_machine.template.disks.2.eagerly_scrub}"
        thin_provisioned="${data.vsphere_virtual_machine.template.disks.2.thin_provisioned}"
      }

      clone {
        template_uuid="${data.vsphere_virtual_machine.template.id}"
      }

      vapp {
        properties {
          "guestinfo.hostname" = "esxi1"
          "guestinfo.ipaddress" = "" # Default = DHCP
          "guestinfo.netmask" = ""
          "guestinfo.gateway" = ""
          "guestinfo.vlan" = ""
          "guestinfo.dns" = "8.8.8.8"
          "guestinfo.domain" = ""
          "guestinfo.ntp" = "pool.ntp.org"
          "guestinfo.syslog" = ""
          "guestinfo.password" = "" # Default = VMware1!
          "guestinfo.ssh" = "True" # Case-sensitive string
          "guestinfo.createvmfs" = "False" # Case-sensitive string
          "guestinfo.debug" = "False" # Case-sensitive string
        }
      }

      lifecycle {
        ignore_changes= [
          "annotation",
          "vapp.0.properties",
        ]
      }
    }
    ```

The `lifecycle` section of the VM resource instructs Terraform to ignore changes to properties matching `annotations` and `vapp.0.properties` because the Virtually Ghetto Nested ESXi virtual appliance guest customization process removes most of the vApp properties at the end of the guest customization process so that sensitive data is not displayed on the deployed VM and also sets the annotation field.  Since Terraform is unaware of the post-provision guest customization process, subsequent executions of `terraform plan` and/or `terraform apply` will flag the VM resource as being in a bad state and will recommend that the nested ESXi VM be destroyed and recreated if this is not set.

## Automated provisioning

Once your configuration files are set, you're ready to start the automated provisioning process by running the following commands:

* `terraform init`: Downloads the vSphere provider and prepares for interacting with the environment
* `terraform plan`: Pre-flight check
* `terraform apply`: Deploy your nested ESXi host!
* `terraform destroy`: Eradicate your nested ESXi VM when you're done so that you can deploy it again

## Reference

You can find lots more information about getting started with Terraform in the official [Getting Started Guide][guide].

Enjoy!

[post]: {% post_url 2018-04-09-vmware-cloud-on-aws-network-security %}
[repo]: https://github.com/vmug-labs/vmug-labs
[vghetto]: https://www.virtuallyghetto.com/2017/05/updated-nested-esxi-6-0u3-6-5d-virtual-appliances.html
[logical_network]: https://docs.vmware.com/en/VMware-Cloud-on-AWS/services/com.vmware.vsphere.vmc-aws-manage-data-center.doc/GUID-897EE044-906D-45C6-BB89-EC60F457B88A.html
[vapp_properties]: https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.vm_admin.doc/GUID-836A323E-B3BD-4709-A71F-0AEA1CCB6727.html "Virtual appliance template properties used for specifying how a VM should be configured when provisioned from the template."
[script]: https://github.com/vmug-labs/vmug-labs/blob/master/Enable-VmVappProperties.ps1
[394]: https://github.com/terraform-providers/terraform-provider-vsphere/issues/394
[promiscuous_mode]: https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.security.doc/GUID-92F3AB1F-B4C5-4F25-A010-8820D7250350.html "Promiscuous mode eliminates any reception filtering that the virtual machine adapter performs so that the guest operating system receives all traffic observed on the wire."
[forged_transmits]: https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.security.doc/GUID-7DC6486F-5400-44DF-8A62-6273798A2F80.html#GUID-7DC6486F-5400-44DF-8A62-6273798A2F80 "When the Forged transmits option is set to Accept, ESXi does not compare source and effective MAC addresses."
[guide]: https://www.terraform.io/intro/getting-started/build.html
