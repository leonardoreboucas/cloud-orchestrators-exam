#!/bin/bash


list_orchestrators='terraform cloudify'
list_providers='aws gcp azure'

#Virginia / London / São Paulo
list_aws_region='us-east-1 eu-west-2 sa-east-1'
list_gcp_region='us-east4 europe-west2 southamerica-east1'
list_azure_region='East-US UK-South Brazil-South'

test_executions=3
execution=1
while [ $execution -ne $test_executions ]; do
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
        mkdir -p logs/${orchestrator}/${provider}/${region}/${execution}/outputs
        touch logs/${orchestrator}/${provider}/${region}/${execution}/data.csv
        ID=$(date +%n)
        echo "${ID}" >> logs/${orchestrator}/${provider}/${region}/${execution}/data.csv
      done
    done
  done
  execution=$((execution + 1))
done
