echo "Terraform Init..."
for provider in $list_providers; do
  echo "(${provider})..."
  DIR_BASE=${DIR}/${orchestrator}/${provider}
  cd $DIR_BASE
  pwd
  terraform init ${DIR_BASE}
  terraform destroy --auto-approve $DIR_BASE
  cd -
done
