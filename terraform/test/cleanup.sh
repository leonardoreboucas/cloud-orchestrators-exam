echo "Terraform Init..."
for provider in $list_providers; do
  echo "(${provider})..."
  terraform init ${orchestrator}/${provider}
  terraform destroy --auto-approve ${orchestrator}/${provider}
done
