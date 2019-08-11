echo "Cleaning Cloudify Manager..."
for i in $list_providers; do
  echo "Cleaning Cloudify Manager ($i)..."
  cfy uninstall -f -v -p ignore_failure=true $i
  cfy deployment delete $i
  cfy blueprints delete cloudify-wp-blueprint-$i
done
