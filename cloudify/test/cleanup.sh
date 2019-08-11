echo "Cleaning Cloudify Manager..."
for i in $list_providers; do
  echo "Cleaning Cloudify Manager ($i)..."
  cfy uninstall -f -v -p ignore_failure=true $i
  cfy deployment delete $i
  for x in `echo "$(cfy blueprints list --json | jq '.[].id' | sed -e 's/"//g')"`; do
    cfy blueprints delete -f $x
  done
done
