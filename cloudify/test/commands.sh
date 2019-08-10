INPUTS="${provider}_region_name=$region"
cmd_provision="cfy install -b cloudify-wordpress-blueprint-${provider} -d $provider -i ${INPUTS} ${DIR}/cloudify/${provider}.yaml"
cmd_unprovision="cfy uninstall -f -v -p ignore_failure=true ${provider}"
