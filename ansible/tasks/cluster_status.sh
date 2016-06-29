#!/bin/bash

clusterOK=$(sudo rabbitmqctl cluster_status | grep "{partitions,\[\]}" | wc -l)


if [ "$clusterOK" -eq "0" ]; then
    aws cloudwatch put-metric-data --metric-name $METRIC_NAME --namespace $NAMESPACE --value 1 --region $REGION
else
    aws cloudwatch put-metric-data --metric-name $METRIC_NAME --namespace $NAMESPACE --value 0 --region $REGION
fi
