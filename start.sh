#!/bin/bash

minikube start --memory=4096 --driver=hyperkit

CONTEXT=$(kubectl config current-context)
if [[ "$CONTEXT" != "minikube" ]]; then
    kubectl config use-context minikube
fi

echo "Installing Kafka Strimzi operator..."
kubectl create namespace kafka
kubectl apply -f ./setup/kafka-crd.yaml -n kafka
kubectl apply -f ./setup/cluster.yaml -n kafka
echo "Kafka Strimzi operator is installed"

echo "Waiting for kafka cluster..."
kubectl wait kafka/local-kafka --for=condition=Ready --timeout=300s -n kafka
echo "Kafka is up and running"

echo "Port forwarding Kafka bootstrap servers..."
echo "bootstrap-servers: localhost:9091,localhost:9092,localhost:9093"
sleep 30
kubectl -n kafka  port-forward service/local-kafka-kafka-bootstrap 9091:9091 9092:9092 9093:9093

echo "stop minikube..."
minikube stop

echo "delete local cluster..."
minikube delete