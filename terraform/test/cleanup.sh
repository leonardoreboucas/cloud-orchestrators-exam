echo "Terraform Init..."
for provider in $list_providers; do
  echo "(${provider})..."
  DIR_BASE=${DIR}/${orchestrator}/${provider}
  cd $DIR_BASE
  terraform init
  terraform refresh
  terraform destroy --auto-approve
  cd -
done
