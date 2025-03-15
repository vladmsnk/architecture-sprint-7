#!/bin/bash

USER1="user1"
USER2="user2"

CERT_DIR="./certs"
mkdir -p ${CERT_DIR}

openssl genrsa -out ${CERT_DIR}/${USER1}.key 2048
openssl genrsa -out ${CERT_DIR}/${USER2}.key 2048

openssl req -new -key ${CERT_DIR}/${USER1}.key -out ${CERT_DIR}/${USER1}.csr -subj "/CN=${USER1}/O=admins"
openssl req -new -key ${CERT_DIR}/${USER2}.key -out ${CERT_DIR}/${USER2}.csr -subj "/CN=${USER2}/O=viewers"

sudo openssl x509 -req -in ${CERT_DIR}/${USER1}.csr -CA $(minikube --profile=minikube ssh -- cat /var/lib/minikube/certs/ca.crt) -CAkey $(minikube --profile=minikube ssh -- cat /var/lib/minikube/certs/ca.key) -CAcreateserial -out ${CERT_DIR}/${USER1}.crt -days 365

sudo openssl x509 -req -in ${CERT_DIR}/${USER2}.csr -CA $(minikube --profile=minikube ssh -- cat /var/lib/minikube/certs/ca.crt) -CAkey $(minikube --profile=minikube ssh -- cat /var/lib/minikube/certs/ca.key) -CAcreateserial -out ${CERT_DIR}/${USER2}.crt -days 365

echo "Созданы сертификаты для пользователей ${USER1} и ${USER2}"

kubectl config set-credentials ${USER1} --client-certificate=${CERT_DIR}/${USER1}.crt --client-key=${CERT_DIR}/${USER1}.key
kubectl config set-credentials ${USER2} --client-certificate=${CERT_DIR}/${USER2}.crt --client-key=${CERT_DIR}/${USER2}.key

echo "Пользователи добавлены в kubeconfig"