echo -e "------------------------- TEST BEGIN ----------------------"
echo -e "\n${orchestrator} - ${provider} - ${region} - ${execution}"
echo -e "-----------------------------------------------------------"
LOCAL=executions/${EXEC_DATE}/${orchestrator}/${provider}/${region}/${execution}
mkdir -p $LOCAL
touch $LOCAL/provision.log
touch $LOCAL/unprovision.log
echo "BEGIN PROVISION,${orchestrator},${provider},${region},${execution},$(date +%s)" >> executions/${EXEC_DATE}/results
  test_monitor.sh ${EXEC_DATE} provision ${orchestrator} ${provider} ${region} ${execution} &
  monitor_pid=$!
  $cmd_provision  2>&1 | tee -a $LOCAL/provision.log
  kill -9 $monitor_pid &> /dev/null
echo "END PROVISION,${orchestrator},${provider},${region},${execution},$(date +%s)"  >> executions/${EXEC_DATE}/results
  echo "waiting to unprovision..."
  sleep 10
echo "BEGIN UNPROVISION,${orchestrator},${provider},${region},${execution},$(date +%s)"  >> executions/${EXEC_DATE}/results
  test_monitor.sh ${EXEC_DATE} unprovision ${orchestrator} ${provider} ${region} ${execution} &
  monitor_pid=$!
  $cmd_unprovision  2>&1 | tee -a $LOCAL/unprovision.log
  kill -9 $monitor_pid &> /dev/null
echo "END UNPROVISION,${orchestrator},${provider},${region},${execution},$(date +%s)"  >> executions/${EXEC_DATE}/results
echo -e "------------------------- TEST END ------------------------"
echo -e "\n${orchestrator} - ${provider} - ${region} - ${execution}"
echo -e "-----------------------------------------------------------"
