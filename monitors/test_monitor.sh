date +%s > /tmp/temp_time_init
free | grep Mem | awk -F' ' '{print $2}' > /tmp/temp_mem_total
free | grep Mem | awk -F' ' '{print $3}' > /tmp/temp_mem_initial
echo $$ > /tmp/temp_monitor_pid
echo 0 > /tmp/temp_count
echo 0 > /tmp/temp_mem_amount
echo 0 > /tmp/temp_cpu_amount
echo 0 > /tmp/temp_io_amount
echo 0 > /tmp/temp_net_amount
while [ true ]; do
  test_monitor_agent.sh $1 $2 $3 $4 $5 $6 $7
  sleep 5
done
