echo "Terraform Init..."
for i in $list_providers; do
  echo "($i)..."
  cd terraform/$i
  terraform init
  terraform destroy --auto-approve
  cd ../../
done
