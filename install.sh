#!/bin/bash

cd "$(dirname "$0")"
. ./config.ini

if [ -z "${pha4pgsql_dir}" -o -z "${OCF_ROOT}" ]; then
  echo "Please set pha4pgsql_dir and OCF_ROOT in the config.ini first!"
  exit 1
fi

echo "generate config.pcs..."
sh ./gencfg.sh
if [ $? -ne 0 ]; then
    echo 'failed to execute "gencfg.sh"' >&2
    exit 1
fi

chmod 600 config.ini config.pcs
chmod +x tools/* ra/* *.sh bin/cls_*

# copy scripts
for node in ${node1} ${node2} ${node3} ${othernodes}
do
    if [ "`hostname`" == "$node" ]; then
        mkdir -p ${pha4pgsql_dir}
        if [ "`pwd`" != "${pha4pgsql_dir}" ]; then
            cp -rf * ${pha4pgsql_dir}/
        fi
        cp -f ra/* ${OCF_ROOT}/resource.d/heartbeat/
    else
        ssh "$node" mkdir -p ${pha4pgsql_dir}
        scp -rp * ${node}:${pha4pgsql_dir}/
        scp -p ra/* ${node}:${OCF_ROOT}/resource.d/heartbeat/
    fi
done



