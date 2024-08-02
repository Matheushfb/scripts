#!/bin/bash
keys=("aws_access_key_id" "aws_secret_access_key" "aws_session_token")
commando=$(aws sts get-session-token | grep -E "Access|Token" | cut -f4 -d \")
j=0
echo [default]
while [ $j -lt 3 ]
do
    for i in $commando
    do
        #${keys[$j]}=$i 
        j=$[$j+1]
    done
done

