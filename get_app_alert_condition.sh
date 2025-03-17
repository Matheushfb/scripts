#!/bin/bash

API_KEY="NRAK-9MSB8KFMACRL03880GO15DMVBVC"
policyID=("5706072" "5751316") 


declare -A policyNames

policies_json=$(curl --silent --fail -X 'GET' \
  "https://api.newrelic.com/v2/alerts_policies.json" \
  -H "X-Api-Key: $API_KEY" \
  -H 'accept: application/json')

for id in "${policyID[@]}"; do
  name=$(echo "$policies_json" | jq -r ".policies[] | select(.id == $id) | .name")
  policyNames["$id"]="$name"
done

for id in "${policyID[@]}"; do
  policy_name="${policyNames[$id]}"
  file_name="${policy_name// /_}.txt"  # Substitui espaços por "_"

  echo "🔎 Processando Policy: $policy_name (ID: $id)"
  > "$file_name"  # Limpa o arquivo antes de escrever

  for page in {1..4}; do
    saida=$(curl --silent --fail -X 'GET' \
      "https://api.newrelic.com/v2/alerts_nrql_conditions.json?policy_id=$id&page=$page" \
      -H "X-Api-Key: $API_KEY" \
      -H 'accept: application/json')

    if [[ -n "$saida" ]]; then
      echo "$saida" | jq -r '.nrql_conditions[].name' | awk -F '|' '{print $1}' >> "$file_name"
    fi
  done

  sort -o "$file_name" "$file_name"
done

file1="${policyNames[${policyID[0]}]// /_}.txt"
file2="${policyNames[${policyID[1]}]// /_}.txt"

if diff -q "$file1" "$file2" &>/dev/null; then
  echo "✅ As condições das policies são IGUAIS!"
else
  echo "❌ As condições das policies são DIFERENTES!"
  diff "$file1" "$file2"
fi