source .set_credentials.sh
mode='create update'
for i in $mode; do
  #AWS
  cfy secrets $i aws_access_key_id --secret-string "$aws_access_key_id"
  cfy secrets $i aws_secret_access_key --secret-string "$aws_secret_access_key"
  #GCP
  cfy secrets $i gcp_client_x509_cert_url --secret-string "$gcp_client_x509_cert_url"
  cfy secrets $i gcp_client_email --secret-string "$gcp_client_email"
  cfy secrets $i gcp_client_id --secret-string "$gcp_client_id"
  cfy secrets $i gcp_project_id --secret-string "$gcp_project_id"
  cfy secrets $i gcp_private_key_id --secret-string "$gcp_private_key_id"
  cfy secrets $i gcp_private_key --secret-string "$gcp_private_key"
  cfy secrets $i gcp_zone --secret-string "$gcp_zone"
  #AZURE
  cfy secrets $i azure_subscription_id --secret-string $azure_subscription_id
  cfy secrets $i azure_tenant_id --secret-string $azure_tenant_id
  cfy secrets $i azure_client_id --secret-string $azure_client_id
  cfy secrets $i azure_client_secret --secret-string $azure_client_secret
done
