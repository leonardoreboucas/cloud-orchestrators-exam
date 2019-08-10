echo "Terraform Init..."
for provider in $list_providers; do
  echo "(${provider})..."
  DIR_BASE=${DIR}/${orchestrator}/${provider}
  terraform init -plugin-dir ${DIR_BASE} ${DIR_BASE}
  terraform destroy --auto-approve --backup=$DIR_BASE --state=$DIR_BASE --state-out=$DIR_BASE $DIR_BASE
done
