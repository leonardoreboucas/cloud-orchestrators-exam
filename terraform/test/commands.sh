DIR_BASE=${DIR}/${orchestrator}/${provider}
cmd_provision="terraform apply --var region_name=${region} --var availability_zone=$DIR_BASE --auto-approve --backup=$DIR_BASE --state=$DIR_BASE --state-out=$DIR_BASE $DIR_BASE"
cmd_unprovision="terraform destroy --auto-approve --auto-approve --backup=$DIR_BASE --state=$DIR_BASE --state-out=$DIR_BASE $DIR_BASE"
unset DIR_BASE
