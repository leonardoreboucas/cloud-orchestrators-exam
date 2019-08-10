echo "Terraform Init..."
for i in $list_providers; do
  echo "($i)..."
  terraform init ${orchestrator}/${provider}
  terraform destroy --auto-approve ${orchestrator}/${provider}
done
