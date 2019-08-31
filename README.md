# Cloud Orchestrators Exam

## Description

This project intend to be a practical test over AWS, Azure and GCP using **Cloudify** an **Terraform** as cloud orchestrators for a simple Wordpress blueprint.

### Wordpress Architecture

<img src="https://github.com/leonardoreboucas/cloud-orchestrators-exam/blob/master/images/arch_wordpress_eng.png"
     alt="Wordpress Architecture"
     style="display: block; margin-left: auto;  margin-right: auto; width: 50%;" />
     
### Exam Architecture

<img src="https://github.com/leonardoreboucas/cloud-orchestrators-exam/blob/master/images/arch_test.png"
     alt="Test Architecture"
     style="float: left; margin-left: 49%;" />

### Exam Parameters
<img src="https://github.com/leonardoreboucas/cloud-orchestrators-exam/blob/master/images/params.png"
     alt="Test Parameters"
     style="float: left; margin-left: 49%;" />
     
### This project content:
* 6 blueprints definitions
  * Wordpress for AWS via Terraform
  * Wordpress for Azure via Terraform
  * Wordpress for GCP via Terraform
  * Wordpress for AWS via Cloudify
  * Wordpress for Azure via Cloudify
  * Wordpress for GCP via Cloudify
* Monitors for:
  * CPU average usage
  * Memory average usage
  * I/O amount
  * Network transfer amount

## Prerequisites

### Get credentials parameters on AWS
* Log in to your AWS Management Console.
* Click on your user name at the top right of the page.
* Click on the Security Credentials link from the drop-down menu.
* Find the Access Credentials section, and copy the latest Access Key ID.
* Click on the Show link in the same row, and copy the Secret Access Key.

You should obtain this parameters:
* aws_access_key_id
* aws_secret_access_key
