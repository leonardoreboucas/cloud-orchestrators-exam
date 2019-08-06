cfy uninstall -f -v -p ignore_failure=true cloudify-wordpress-blueprint-${1}
cfy deployment delete cloudify-wordpress-blueprint-${1}
cfy blueprints delete cloudify-wordpress-blueprint-${1}
cfy install -v ${1}.yaml -b cloudify-wordpress-blueprint-${1} -d cloudify-wordpress-blueprint-${1}
