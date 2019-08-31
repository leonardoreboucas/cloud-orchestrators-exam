# cloud-orchestrators-exam

This project intend to be a practical test over Cloudify an Terraform using a simple Wordpress blueprint showed in the Figure below.

<img src="https://github.com/leonardoreboucas/cloud-orchestrators-exam/blob/master/images/arch_wordpress_eng.png"
     alt="Wordpress Architecture"
     style="float: left; margin-left: 49%;" />

The tests can be made on AWS, Azure and GCP:

<img src="https://github.com/leonardoreboucas/cloud-orchestrators-exam/blob/master/images/arch_test.png"
     alt="Test Architecture"
     style="float: left; margin-left: 49%;" />

This project contains:
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
  * Network transfoer amount

# Prerequisites

### Get credentials parameters on AWS
* Log in to your AWS Management Console.
* Click on your user name at the top right of the page.
* Click on the Security Credentials link from the drop-down menu.
* Find the Access Credentials section, and copy the latest Access Key ID.
* Click on the Show link in the same row, and copy the Secret Access Key.

You should obtain e parameters:
* aws_access_key_id
* aws_secret_access_key
