cmd_provision="terraform apply --auto-approve -var region_name=${region} --var availability_zone=${region}${zone}"
cmd_unprovision="terraform destroy --auto-approve --refresh=true --refresh -var region_name=${region} --var availability_zone=${region}${zone}"
