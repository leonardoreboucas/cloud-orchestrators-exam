DIR_BASE=${DIR}/${orchestrator}/${provider}
cmd_provision="cd ${DIR_BASE} ; terraform apply --auto-approve"
cmd_unprovision="terraform destroy --auto-approve ; cd -"
