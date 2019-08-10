echo -e "------------------------- TEST BEGIN -------------------------"
echo -e "   ${orchestrator} - ${provider} - ${region} - ${execution}"
echo -e "--------------------------------------------------------------"
LOCAL=$DIR/executions/${EXEC_DATE}/${orchestrator}/${provider}/${region}/${execution}
mkdir -p $LOCAL
### provision - begin
touch $LOCAL/provision.log
test_monitor.sh $RESULTS ${EXEC_DATE} provision ${orchestrator} ${provider} ${region} ${execution} &
monitor_pid=$!
$cmd_provision  2>&1 | tee -a $LOCAL/provision.log
kill -9 $monitor_pid &> /dev/null
### provision - end
echo "waiting to unprovision..."
sleep 10
### unprovision - begin
touch $LOCAL/unprovision.log
test_monitor.sh $RESULTS ${EXEC_DATE} unprovision ${orchestrator} ${provider} ${region} ${execution} &
monitor_pid=$!
$cmd_unprovision  2>&1 | tee -a $LOCAL/unprovision.log
kill -9 $monitor_pid &> /dev/null
### unprovision - end
echo -e "--------------------------- TEST END --------------------------"
echo -e "   ${orchestrator} - ${provider} - ${region} - ${execution}"
echo -e "---------------------------------------------------------------"
