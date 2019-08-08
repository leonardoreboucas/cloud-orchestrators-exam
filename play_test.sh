#!/bin/bash

############# Orchestrator ############
list_orchestrators='cloudify'

######### Providers ##########
list_providers='aws gcp azure'

############ Regions ############
# Virginia / London / São Pauol
list_aws_region='us-east-1 eu-west-2 sa-east-1'
list_gcp_region='us-east4 europe-west2 southamerica-east1'
list_azure_region='East-US UK-South Brazil-South'

########## Executions ##########
test_executions=3

echo "Cleaning Cloudify Manager..."
for i in $list_providers; do
  echo "Cleaning Cloudify Manager ($i)..."
  cfy uninstall -f -v -p ignore_failure=true $i
  cfy deployment delete $i
  cfy blueprints delete cloudify-wordpress-blueprint-$i
done

echo "process,orchestrator,provider,region,execution,date,cpu,mem,io,net">results
execution=0
while [ $execution -lt $test_executions ]; do
  for orchestrator in $list_orchestrators; do
    for provider in $list_providers; do
      case  $provider  in
        aws)
           list_region=$list_aws_region
           ;;
        gcp)
           list_region=$list_gcp_region
           ;;
        azure)
           list_region=$list_azure_region
           ;;
        *)
      esac
      for region in $list_region; do
        case $orchestrator in
          cloudify)
            INPUTS="${provider}_region_name=${region}"
            cmd_provision="cfy install -b cloudify-wordpress-blueprint-$provider -d $provider -i ${INPUTS} cloudify/${provider}.yaml"
            cmd_unprovision="cfy uninstall -f -v -p ignore_failure=true ${provider}"
            ;;
          terraform)
            cmd_provision='sleep 5'
            cmd_unprovision='sleep 5'
            ;;
          *)
        esac
        echo -e "\n${orchestrator} - ${provider} - ${region} - ${execution}"
        EXEC_DATE=$(date +%Y-%m-%d-%s)
        LOCAL=executions/${EXEC_DATE}/${orchestrator}/${provider}/${region}/${execution}
        mkdir -p $LOCAL
        test_monitor.sh provision ${orchestrator} ${provider} ${region} ${execution} &
        monitor_pid=$!
        $cmd_provision >> $LOCAL/provision.log
        kill -9 $monitor_pid > /dev/null
        sleep 30
        test_monitor.sh unprovision ${orchestrator} ${provider} ${region} ${execution} &
        monitor_pid=$!
        $cmd_unprovision >> $LOCAL/unprovision.log
        kill -9 $monitor_pid > /dev/null
      done
    done
  done
execution=$((execution + 1))
done
