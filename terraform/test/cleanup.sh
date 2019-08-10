echo "Terraform Init..."
for provider in $list_providers; do
  echo "(${provider})..."
  DIR_BASE=${DIR}/${orchestrator}/${provider}
  terraform init ${DIR_BASE}
  terraform destroy --auto-approve --backup=$DIR_BASE/.tf.backup --state=$DIR_BASE/.tf.state --state-out=$DIR_BASE/.tf.state-out $DIR_BASE
  rm -rf $DIR_BASE/.tf.*
done
