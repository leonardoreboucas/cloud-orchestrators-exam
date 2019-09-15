# Cloud Orchestrators Exam

### Description

This project intend to be a practical test over AWS, Azure and GCP using **Cloudify** an **Terraform** as cloud orchestrators for a simple Wordpress blueprint.

#### Wordpress Architecture

<img src="https://github.com/leonardoreboucas/cloud-orchestrators-exam/blob/master/images/arch_wordpress_eng.png"
     alt="Wordpress Architecture"
     style="display: block; margin-left: auto;  margin-right: auto; width: 50%;" />
     
#### Exam Architecture

<img src="https://github.com/leonardoreboucas/cloud-orchestrators-exam/blob/master/images/arch_test.png"
     alt="Test Architecture"
     style="float: left; margin-left: 49%;" />

#### Exam Parameters
<img src="https://github.com/leonardoreboucas/cloud-orchestrators-exam/blob/master/images/params.png"
     alt="Test Parameters"
     style="float: left; margin-left: 49%;" />
     
#### This project content:
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
* Shell Script for cordinate the tests

## Prerequisites

### Get credentials parameters on AWS
* Log in to your AWS Management Console.
* Click on your user name at the top right of the page.
* Click on the Security Credentials link from the drop-down menu.
* Find the Access Credentials section, and copy the latest Access Key ID.
* Click on the Show link in the same row, and copy the Secret Access Key.

You should obtain this parameters:
* access_key_id
* secret_access_key

### Get credentials parameters on Azure

You should obtain this parameters:
* subscription_id
* azure_tenant_id
* azure_client_id
* azure_client_secret

Follow this instructions: [click](https://www.inkoop.io/blog/how-to-get-azure-api-credentials/)

### Get credentials parameters on GCP

* Create a service account and set permissions to operate the Compute Engine and VPC Networks.

You should obtain a JSON file with this parameters:
* client_x509_cert_url
* client_email
* client_id
* project_id
* private_key_id
* zone

Ensure this JSON is put on file: common/account.json.

### Set credentials on your local environment

Execute the commands below to export all credentials values obtained. Take care to change values.
```
#AWS
export aws_access_key_id=[PUT YOUR VALUE HERE]
export aws_secret_access_key=[PUT YOUR VALUE HERE]
export TF_VAR_aws_access_key=$aws_access_key_id
export TF_VAR_aws_secret_key=$aws_secret_access_key
#GCP
export gcp_client_x509_cert_url=[PUT YOUR VALUE HERE]
export gcp_client_email=[PUT YOUR VALUE HERE]
export gcp_client_id=[PUT YOUR VALUE HERE]
export gcp_project_id=[PUT YOUR VALUE HERE]
export gcp_private_key_id=[PUT YOUR VALUE HERE]
export gcp_private_key=[PUT YOUR VALUE HERE]
#Azure
export azure_subscription_id=[PUT YOUR VALUE HERE]
export azure_tenant_id=[PUT YOUR VALUE HERE]
export azure_client_id=[PUT YOUR VALUE HERE]
export azure_client_secret=[PUT YOUR VALUE HERE]
export TF_VAR_azure_subscription_id=$azure_subscription_id
export TF_VAR_azure_tenant_id=$azure_tenant_id
export TF_VAR_azure_client_id=$azure_client_id
export TF_VAR_azure_client_secret=$azure_client_secret
```

### Configure Orchestrators
For use terraform, just [download](https://www.terraform.io/downloads.html) it's binary and ensure it´s in your PATH and is possible to execute terraform command everywhere in your environment.

For use Cloudify, just follow [provider's instructions](https://cloudify.co/getting-started/) in order to install a Cloudify environment on your environment. This could be by docker images or install process. The CLI is required too. Your have to create secrets for each provider's parameters. The GCP parameter gcp_private_key should be setted as a plain text, so convert the string inside JSON to a plain text and use it to fill the respective secret on your Cloudify environment.

## Execution

* Clone this project:
  ``` git clone https://github.com/leonardoreboucas/cloud-orchestrators-exam.git ```
* Enter directory
  ``` cd cloud-orchestrators-exam ```
* Play Tests
  ``` ./play_test.sh ```
* Follow test execution on directory executions
