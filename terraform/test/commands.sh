cmd_provision="terraform apply --auto-approve --var region_name=${region},availability_zone=${region}${zone}"
cmd_unprovision="terraform destroy --auto-approve"
