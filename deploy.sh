#!/bin/bash
public_ip=$(terraform output public_ip)

bosh create-env concourse.yml -n \
  --state ./state.json \
  --vars-store ./creds.yml \
  -v zone=us-central1-b \
  -v network=concourse \
  -v subnetwork=concourse-us-central1 \
  -v internal_cidr=10.0.10.0/24 \
  -v internal_gw=10.0.10.1 \
  -v internal_ip=10.0.10.10 \
  -v external_ip=$public_ip \
  -v external_url=https://${public_ip}.xip.io \
  -v github_client_id=${GITHUB_CLIENT_ID} \
  -v github_client_secret=${GITHUB_CLIENT_SECRET} \
  -v github_org=${GITHUB_ORG} \
  -v github_team=${GITHUB_TEAM} \
  -v gcp_credentials="'$(cat ./gcp_credentials.json)'" \
  -v project_id=${GCP_PROJECT_ID} \
  -v service_account=${GCP_SERVICE_ACCOUNT}

ruby -ryaml -e "puts YAML.load_file('creds.yml')['bosh_ssh']['private_key']" > bosh.key
chmod 600 bosh.key