FROM eclipse-temurin:21-jre-jammy@sha256:02fc89fa8766a9ba221e69225f8d1c10bb91885ddbd3c112448e23488ba40ab6

COPY classes/sgx_runtime_libraries.sh /tmp/sgx_runtime_libraries.sh
RUN /tmp/sgx_runtime_libraries.sh

WORKDIR /home/app
COPY classes /home/app/classes
COPY dependency/* /home/app/libs/
COPY classes/sgx_default_qcnl_azure.conf /etc/sgx_default_qcnl.conf
EXPOSE 8080

# Required, along with libsgx-quote-ex, for out-of-proc attestation. See
# https://docs.microsoft.com/en-us/azure/confidential-computing/confidential-nodes-aks-addon
ENV SGX_AESM_ADDR=1

RUN groupadd --gid 10000 cds && useradd --uid 10000 --gid 10000 cds
USER 10000

ENTRYPOINT ["java", "-cp", "/home/app/libs/*:/home/app/classes/", "org.signal.cdsi.Application"]
