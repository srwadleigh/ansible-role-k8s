#!/bin/bash

# env expected to be supplied via ansible task
# PLAYBOOK_PATH
# KUBECONTEXT
# SECRET

KUBECONF="$HOME/.kube/config-${KUBECONTEXT}.yaml"
SECRET_FILE="${PLAYBOOK_DIR}/files/manifests/${SECRET}"

apply_secret() {
  kubectl apply --kubeconfig="${KUBECONF}" --context="${KUBECONTEXT}" -f "$1"
}

if ansible-vault view "${SECRET_FILE}" &> /dev/null; then
  ansible-vault decrypt --output=- "${SECRET_FILE}" | apply_secret -
else
  apply_secret "${SECRET_FILE}"
fi
