DIR_BASE=${DIR}/${orchestrator}/${provider}
cd $DIR_BASE
cmd_provision="terraform apply --auto-approve"
cmd_unprovision="terraform destroy --auto-approve"
cd -
