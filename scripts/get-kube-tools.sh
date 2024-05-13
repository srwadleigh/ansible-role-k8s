#!/bin/sh

INSTALL_PATH="/usr/local/bin"
INSTALL_ARCH="amd64"
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
KUBIE_VERSION="latest"
YQ_VERSION="latest"
HELM_URL="https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"

sudo wget -qO ${INSTALL_PATH}/kubectl https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${INSTALL_ARCH}/kubectl
sudo chmod a+x ${INSTALL_PATH}/kubectl

sudo wget -qO ${INSTALL_PATH}/kubie https://github.com/sbstp/kubie/releases/${KUBIE_VERSION}/download/kubie-linux-${INSTALL_ARCH} 
sudo chmod a+x ${INSTALL_PATH}/kubie

sudo wget -qO ${INSTALL_PATH}/yq https://github.com/mikefarah/yq/releases/${YQ_VERSION}/download/yq_linux_${INSTALL_ARCH}
sudo chmod a+x ${INSTALL_PATH}/yq

curl -fsSL -o get_helm.sh ${HELM_URL}
chmod 700 get_helm.sh
./get_helm.sh
