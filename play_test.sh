#!/bin/bash
source common/.set_credentials.sh
############# Orchestrator ############
list_orchestrators='terraform'

######### Providers ##########
list_providers='gcp'

############ Regions ############
# Virginia / London / São Paulo
list_aws_region='us-east-1 eu-west-2 sa-east-1'
list_gcp_region='us-east4 europe-west2 southamerica-east1'
list_azure_region='EastUS UKSouth BrazilSouth'

########## Executions ##########
test_executions=1

echo "Starting tests..."
EXEC_DATE=$(date +%Y-%m-%d-%H-%I-%S)
mkdir -p executions/${EXEC_DATE}
echo "date,process,orchestrator,provider,region,execution,timestamp,cpu,mem,io,net,duration" > executions/${EXEC_DATE}/results
execution=1
while [ $execution -le $test_executions ]; do
  for orchestrator in $list_orchestrators; do
    source $orchestrator/test/cleanup.sh
    for provider in $list_providers; do
      source common/providers_regions.sh
      for region in $list_region; do
        source common/providers_zones.sh
        source ${orchestrator}/test/commands.sh
        source common/test_case.sh
      done
    done
  done
  execution=$((execution + 1))
done

echo "Cleaning up..."
for orchestrator in $list_orchestrators; do
  source orchestrator/test/cleanup.sh
doe
rm -rf /tmp/temp*
echo "Tests finished"
