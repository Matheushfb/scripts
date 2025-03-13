#!/bin/bash

API_KEY="XYZ"
policyID=("00000000" "0000000")

for i in ${policyID[@]}

do
  saida=$(curl --silent --fail -X 'GET' \
    "https://api.newrelic.com/v2/alerts_nrql_conditions.json?policy_id=$i&page=[1-4]" \
    -H  "X-Api-Key: $API_KEY" \
    -H 'accept: application/json')

  echo "$saida" | jq -r '.nrql_conditions[].name' | awk -F '|' '{print $1}' | sort > $i.txt
done

validate=$(diff ${policyID[0]}.txt ${policyID[1]}.txt)

if [[ $validate -eq 0 ]]
then
  echo "Conditions OK!"
else
  echo "Conditions not OK!"
  diff ${policyID[0]}.txt ${policyID[1]}.txt
fi




