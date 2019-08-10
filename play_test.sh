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
test_executions=3

########## Terraform Init ##########
echo "Terraform Init..."
for i in $list_providers; do
  echo "($i)..."
  cd terraform/$i
  terraform init
  terraform destroy --auto-approve
  cd ../../
done

echo "Starting tests..."
EXEC_DATE=$(date +%Y-%m-%d-%H-%I-%S)
mkdir -p executions/${EXEC_DATE}
echo "date,process,orchestrator,provider,region,execution,timestamp,cpu,mem,io,net" > executions/${EXEC_DATE}/results
execution=1
while [ $execution -le $test_executions ]; do
  for orchestrator in $list_orchestrators; do
    for provider in $list_providers; do
      cd ${orchestrator}/${provider}
      pwd
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
        case $region in
          ##AWS
          us-east-1)
          zone=b
          ;;
          eu-west-2)
          zone=b
          ;;
          sa-east-1)
          zone=a
          ;;
          ##GCP
          us-east4)
          zone=-a
          ;;
          europe-west2)
          zone=-a
          ;;
          southamerica-east1)
          zone=-a
          ;;
          ##Azure
          'East US')
          zone=-a
          ;;
          'UK South')
          zone=-a
          ;;
          'Brazil South')
          zone=-a
          ;;
	*)
	esac
        case $orchestrator in
          cloudify)
            echo "Cleaning Cloudify Managers..."
            for i in $list_providers; do
              echo "Cleaning Cloudify Manager ($i)..."
              cfy uninstall -f -v -p ignore_failure=true $i
              cfy deployment delete $i
              cfy blueprints delete cloudify-wordpress-blueprint-$i
            done
            INPUTS="${provider}_region_name='$(echo $region | sed -e 's/_/ /g')'"
            cmd_provision="cfy install -b cloudify-wordpress-blueprint-${provider} -d $provider -i ${INPUTS} cloudify/${provider}.yaml"
            cmd_provision2="sleep 0"
            cmd_unprovision="cfy uninstall -f -v -p ignore_failure=true ${provider}"
            cmd_unprovision2="sleep 0"
	          ;;
          terraform)
            region=$(echo $region | sed -e 's/_/ /g')
            cmd_provision="terraform apply --var region_name=${region} --var availability_zone=${region}${zone} --auto-approve"
            cmd_unprovision='terraform destroy --auto-approve'
            ;;
          *)
        esac
        echo -e "\n${orchestrator} - ${provider} - ${region} - ${execution}"
        LOCAL=../../executions/${EXEC_DATE}/${orchestrator}/${provider}/${region}/${execution}
        mkdir -p $LOCAL
        touch $LOCAL/provision.log
        touch $LOCAL/unprovision.log
        test_monitor.sh ${EXEC_DATE} provision ${orchestrator} ${provider} ${region} ${execution} &
        monitor_pid=$!
        $cmd_provision  2>&1 | tee -a $LOCAL/provision.log
        kill -9 $monitor_pid &> /dev/null
        sleep 30
        test_monitor.sh ${EXEC_DATE} unprovision ${orchestrator} ${provider} ${region} ${execution} &
        monitor_pid=$!
        $cmd_unprovision  2>&1 | tee -a $LOCAL/unprovision.log
        kill -9 $monitor_pid &> /dev/null
      done
      cd ../..
    done
  done
execution=$((execution + 1))
done
echo "Cleaning Cloudify Manager..."
for i in $list_providers; do
  echo "Cleaning Cloudify Manager ($i)..."
  cfy uninstall -f -v -p ignore_failure=true $i
  cfy deployment delete $i
  cfy blueprints delete cloudify-wordpress-blueprint-$i
done
rm -rf /tmp/temp*
