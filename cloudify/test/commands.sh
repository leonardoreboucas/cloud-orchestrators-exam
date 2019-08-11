INPUTS="${provider}_region_name=$region"
BPID="$(date +%s)"
cmd_provision="cfy install -b ${BPID}-cloudify-wp-${provider} -d $provider -i ${INPUTS} ${DIR}/cloudify/${provider}.yaml"
cmd_unprovision="cfy uninstall -f -v -p ignore_failure=true ${provider}"
