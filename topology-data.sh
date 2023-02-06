#!/bin/bash
set -x
set -euo
#format: 
# sno, dbName, podName, pvcName, volName, az
nses=(platform-mongo app-microservices app-microservices-coins)
echo "sno,dbName,podName,volName,az" > topology-data.csv

COUNTER=0
for ns in "${nses[@]}"; do
    mongopods=($(kubectl get pod --namespace $ns | grep rs0 | grep -v arbiter| cut -d " " -f1))
    for pod in "${mongopods[@]}"; do
        pvcmongo=$(kubectl get pods ${pod} --namespace $ns -o json | jq -r '.spec.volumes[0].persistentVolumeClaim.claimName')
        volume=$(kubectl get pvc ${pvcmongo} --namespace $ns -o json | jq -r '.spec.volumeName')
        az=$(kubectl get pv ${volume} -o json | jq -r '.spec.nodeAffinity.required.nodeSelectorTerms[0].matchExpressions[0].values[0]')
        COUNTER=$((COUNTER+1))
        echo "$COUNTER,$pod,$pvcmongo,$volume,$az" >> topology-data.csv
    done
done
