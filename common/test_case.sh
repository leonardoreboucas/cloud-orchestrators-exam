echo -e "------------------------- TEST BEGIN -------------------------"
echo -e "   ${orchestrator} - ${provider} - ${region} - ${execution}"
echo -e "--------------------------------------------------------------"
LOCAL=$DIR/executions/${EXEC_DATE}/${orchestrator}/${provider}/${region}/${execution}
mkdir -p $LOCAL
### provision - begin
PROVISION_RUN=true
CONT=0
RETRY=2
cd ${DIR}/${orchestrator}/${provider}
while [ $PROVISION_RUN ] && [ $CONT -le $RETRY ]; do
  echo "Starting provisioning process" > $LOCAL/provision.log
  test_monitor.sh ${RESULTS} ${EXEC_DATE} provision ${orchestrator} ${provider} ${region} ${execution} &
  monitor_pid=$!
  $cmd_provision  2>&1 >> $LOCAL/provision.log
  kill -9 $monitor_pid &> /dev/null
  if [ "${orchestrator}" == "cloudify" ]; then
    cfy deployments outputs gcp cloudify-${BPID}-wp-${provider} >> $LOCAL/provision.log
  fi
  echo "validating provisioning process..."
  if [ "$(cat $LOCAL/provision.log | grep apply-finished-wp)" == "" ]; then
    echo "Provision failed"
    if [ $CONT -eq $RETRY ]; then
      echo "No more retrys... skipping"
      break
    else
      echo "Retrying..."
    fi
    CONT=$((CONT + 1))
    echo "failed" >> $RESULTS
    source test/cleanup.sh
  else
    echo "Provision successfully"
    echo "success" >> $RESULTS
    PROVISION_RUN=false
    break
  fi
done

### provision - end
echo "waiting for unprovision..."
sleep 10
### unprovision - begin
touch $LOCAL/unprovision.log
test_monitor.sh $RESULTS ${EXEC_DATE} unprovision ${orchestrator} ${provider} ${region} ${execution} &
monitor_pid=$!
$cmd_unprovision  2>&1 > $LOCAL/unprovision.log
kill -9 $monitor_pid &> /dev/null
### unprovision - end
echo -e "--------------------------- TEST END --------------------------"
echo -e "   ${orchestrator} - ${provider} - ${region} - ${execution}"
echo -e "---------------------------------------------------------------"
cd -
