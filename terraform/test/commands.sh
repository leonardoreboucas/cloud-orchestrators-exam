DIR_BASE=${DIR}/${orchestrator}/${provider}
cmd_provision="terraform apply --var region_name=${region} --var availability_zone=$DIR_BASE --auto-approve --backup=$DIR_BASE/.tf.backup --state=$DIR_BASE/.tf.state --state-out=$DIR_BASE/.tf.state-out $DIR_BASE"
cmd_unprovision="terraform destroy --auto-approve --backup=$DIR_BASE/.tf.backup --state=$DIR_BASE/.tf.state --state-out=$DIR_BASE/.tf.state-out $DIR_BASE"
unset DIR_BASE
