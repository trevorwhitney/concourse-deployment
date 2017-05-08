# concourse-deployment

Use this repo to deploy a standalone concourse instance to Google Cloud Platform.


1. Create google service account with the `owner` role if you do not already have one. The deploy
script will expect the service account's key to be in `gcp_credentials.json`.

    ```bash
    gcloud config set compute/zone us-central1-b
    gcloud config set compute/region us-central1
    gcloud iam service-accounts create concourse-service-account
    gcloud projects add-iam-policy-binding <SERVICE_ACCOUNT_NAME> \
          --member serviceAccount:<SERVICE_ACCOUNT_NAME>@<PROJECT_ID>.iam.gserviceaccount.com \
          --role roles/owner
    gcloud iam service-accounts keys create gcp_credentials.json \
        --iam-account <SERVICE_ACCOUNT_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
    ```

1. The deploy script will expect the following environment variables to be set.
    * `GITHUB_CLIENT_ID` (for github oauth)
    * `GITHUB_CLIENT_SECRET` (for github oauth)
    * `GITHUB_ORG` (for github oauth)
    * `GITHUB_TEAM` (for github oauth)
    * `GCP_PROJECT_ID`
    * `GCP_SERVICE_ACCOUNT`
    
1. Create a `terraform.tfvars` file, providing values for the following
    ```
    region = "us-central1"
    projectid = <PROJECT_ID>
    ```
1. Run `./terraform plan` to make sure all the variables have been provided, and then `./terraform apply` to create
the infrastructure.

1. Rune `./deploy.sh` to deploy concourse.