Based on the [official documentation](https://cloud.google.com/docs/terraform/resource-management/managing-infrastructure-as-code)

## Prerequisites

1. **Create a Git repository containing this folder's code**

    Make sure to commit to a branch matching the name of the environment folder (default: "`dev`")

1. **Enable [Cloud Resource Manager API](https://console.cloud.google.com/apis/api/cloudresourcemanager.googleapis.com)**

    Can't be done via Terraform as it needs the API enabled to function in the first place

    ```bash
    gcloud services enable cloudresourcemanager.googleapis.com
    ```

1. **Enable [Cloud Build API](https://console.cloud.google.com/apis/library/cloudbuild.googleapis.com)**

    ```bash
    gcloud services enable cloudbuild.googleapis.com
    ```

1. **Provide required roles**

    - Logs Writer
    - Storage Admin
    - Service Usage Admin
    - Cloud Run Admin
    - Service Account User

1. **Create a Cloud Storage bucket to host the Terraform state file**

    ```bash
    PROJECT_ID=$(gcloud config get-value project)
    gsutil mb gs://${PROJECT_ID}-tfstate
    ```

    Enable Object Versioning for the bucket

    ```bash
    gcloud storage buckets update gs://${PROJECT_ID}-tfstate --versioning
    ```

1. **Grant permissions to Cloud Build service account**

    We use the "Editor" role here, where in production you would use more granular roles following the principle of least privilege

    ```bash
    CLOUDBUILD_SA="$(gcloud projects describe $PROJECT_ID \
        --format 'value(projectNumber)')@cloudbuild.gserviceaccount.com"
    ```

    ```bash
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member serviceAccount:$CLOUDBUILD_SA --role roles/editor
    ```

1. **Visit the GitHub Marketplace page for the [Cloud Build app](https://github.com/marketplace/google-cloud-build)**

    - Click on "Set up with Google Cloud Build" at the bottom

    - If you've set this up in the past, go to: Settings > Applications > Google Cloud Build > Configure

    - Add the repo you created above to the list of repos this app can access

    - Follow the wizzard (if no wizzard appears, go to the [Triggers page](console.cloud.google.com/cloud-build/triggers) and create a Trigger from there)

1. **Create the Trigger**

    - Event: Push to a branch
    - Source:
        - Repository: Select the one you created above
        - Branch: `^branch-you-committed-to$`

## How to demo

1. **Run the Trigger**

    In the Trigger overview click on "Run" for the Trigger created above

1. **Monitor the build**

    Click on the Trigger to see logs

1. **Check out the Cloud Run Service**

    Once the run completed successfully it will have created a Cloud Run Service
    
    Note that this Service requires authentication to access

1. **Make Cloud Run Service public**

    - Uncomment the `data.google_iam_policy.noauth` and `google_cloud_run_service_iam_policy.noauth` resources in `main.tf`

    - Commit and push

1. **Check out the public Cloud Run Service**

    The previous step's push should have triggered a new build after which the Service should allow unauthenticated access