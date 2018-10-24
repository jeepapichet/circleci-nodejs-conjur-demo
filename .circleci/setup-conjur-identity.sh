#!/bin/bash

CONJUR_AUTHN_LOGIN="host/circleci/executor/$CIRCLE_PROJECT_REPONAME"
HOST_ID="circleci/executor/$CIRCLE_PROJECT_REPONAME"

env


urlencoded_login=$(echo $CONJUR_CIRCLECI_MASTER_LOGIN | sed 's=/=%2F=g')
echo "encoded login = $urlencoded_login"
echo "master apikey = $CONJUR_CIRCLECI_MASTER_API_KEY"

auth=$(curl -s --cacert $CONJUR_CERT_FILE -H "Content-Type: text/plain" -X POST -d "$CONJUR_CIRCLECI_MASTER_API_KEY" $CONJUR_APPLIANCE_URL/authn/users/$urlencoded_login/authenticate)

echo "auth = $auth"

auth_token=$(echo -n $auth | base64 | tr -d '\r\n')
echo "auth_token = $auth_token"

urlencoded_hf_id=$(echo $CONJUR_HOST_FACTORY | sed 's=/=%2F=g')

token_exp_time=$(date --iso-8601=seconds --date="120 seconds")
urlencoded_token_exp_time=$(echo $token_exp_time | sed 's=/=%2F=g; s= =%20=g; s=:=%3A=g; s=+=%2B=g')

echo "encoded_hf_id = $urlencoded_hf_id"
echo "token exp = $token_exp_time = $urlencoded_token_exp_time"

response=$(curl -s \
              --cacert $CONJUR_CERT_FILE \
              -X POST -H "Authorization: Token token=\"$auth_token\"" \
              $CONJUR_APPLIANCE_URL/host_factories/$urlencoded_hf_id/tokens?expiration=$urlencoded_token_exp_time)

hf_token=$(echo $response | jq -r '.[].token')
echo "hostfactory token= $hf_token"


urlencoded_hostid=$(echo $HOST_ID | sed 's=/=%2F=g')


echo "redeem id for host = $urlencoded_hostid"

response=$(curl -s \
         --cacert $CONJUR_CERT_FILE \
         -X POST -H "Content-Type: application/json" \
         -H "Authorization: Token token=\"$hf_token\"" \
         $CONJUR_APPLIANCE_URL/host_factories/hosts?id=$urlencoded_hostid)

CONJUR_AUTHN_API_KEY=$(echo $response | jq -r '.api_key')

echo "Conjur LOGIN = $CONJUR_AUTHN_LOGIN"
echo "Conjur API KEY = $CONJUR_AUTHN_API_KEY"

echo export CONJUR_AUTHN_API_KEY=$CONJUR_AUTHN_API_KEY >> "$BASH_ENV"
echo export CONJUR_AUTHN_LOGIN=$CONJUR_AUTHN_LOGIN >> "$BASH_ENV"

env | grep CONJUR

echo $BASH_ENV
cat  $BASH_ENV

