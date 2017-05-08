#!/bin/bash

export GOOGLE_CREDENTIALS=$(cat gcp_credentials.json)
export GOOGLE_APPLICATION_CREDENTIALS=$(cat gcp_credentials.json)
terraform $@
