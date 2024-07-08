#!/bin/bash

vault_output="$1"
vault_regex=".*\.yml$"
vault_var_name="k8s_cluster_token"
token="$(openssl rand -hex 16)"

print_token() {
  echo "$token"
}

print_yaml() {
  printf -- "---\n$vault_var_name: %s\n" "$token"
}

encrypt_token() {
  ansible-vault encrypt_string "$token" --name "$vault_var_name"
}

encrypt_yaml() {
  print_yaml | ansible-vault encrypt
}

if [ -n "$vault_output" ]; then
  if [[ $vault_output =~ $vault_regex ]]; then
    if [ -f "$vault_output" ]; then
      echo "output file already exists, no token generated"
      exit 0
    else
      encrypt_yaml > "$vault_output"
    fi
  else
      echo "supplied output file should end with .yml"
      exit 1
  fi
else
  encrypt_token
fi
