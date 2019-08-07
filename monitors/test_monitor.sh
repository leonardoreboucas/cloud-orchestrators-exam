echo $$ > temp_monitor_pid
echo 0 > temp_count
echo 0 > temp_mem_amount
echo 0 > temp_cpu_amount
echo 0 > temp_io_amount
echo 0 > temp_net_amount
echo "date,cpu,mem,io,net">results
while [ true ]; do
  test_monitor_agent.sh
  sleep 5
done
