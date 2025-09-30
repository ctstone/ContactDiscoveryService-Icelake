#!/bin/bash

./mvnw install -DskipTests -Dpackaging=docker -Djib.to.image=cdsi:latest

(docker container stop cdsi && docker container rm cdsi) || true

docker run -d \
  --name cdsi \
  -p 8080:8080 \
  -p 8081:8081 \
  -e MICRONAUT_ENVIRONMENTS=dev \
  -e MICRONAUT_CONFIG_FILES=/home/app/application-poc.yaml \
  --device=/dev/sgx_enclave \
  --device=/dev/sgx_provision \
  -v /var/run/aesmd:/var/run/aesmd \
  -e SGX_AESM_ADDR=1 \
  -v ~/.aws:/home/cds/.aws:ro \
  -v $HOME/jamb/application-poc.yaml:/home/app/application-poc.yaml:ro \
  -e OE_LOG_LEVEL=INFO \
  cdsi:latest
