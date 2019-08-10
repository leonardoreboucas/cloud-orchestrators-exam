cd ${orchestrator}/${provider}
cmd_provision="terraform apply --var region_name=${region} --var availability_zone=${region}${zone} --auto-approve"
cmd_unprovision='terraform destroy --auto-approve'
cd ../..
