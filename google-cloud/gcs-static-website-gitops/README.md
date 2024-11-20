# Google Cloud Snippets: Host a static website on GCS

How to automatically and continuously deploy a static website on Google Cloud Storage

Based on the [official documentation](https://cloud.google.com/storage/docs/hosting-static-website)

## How to demo

1. **Store Bucket name in an environment variable**

    ```bash
    export BUCKET_NAME=[BUCKET_NAME]
    ```
1. **Create a GCS bucket**

    ```bash
    gcloud storage buckets create gs://$BUCKET_NAME --no-public-access-prevention
    ```

1. **Make the bucket public**

    ```bash
    gcloud storage buckets add-iam-policy-binding  gs://$BUCKET_NAME --member=allUsers --role=roles/storage.objectViewer
    ```

1. **Set `index.html` as the main page**

    ```bash
    gcloud storage buckets update gs://$BUCKET_NAME --web-main-page-suffix=index.html
    ```

1. **Create a Load Balancer**

    - **Frontend**: For this demo, the Frontend only needs a name, leave everything else to default
    - **Backend**: Click on "Create a Backend Bucket" and select your bucket
    - **Routing**: Leave everything to default

1. **Create a Service Account**

    Provide it with the following roles:
      - Logs Writer
      - Storage Admin

1. **Create a Cloud Build trigger**

    - Select your repo and branch
    - For "Configuration" select "Cloud Build"
    - Under "Advanced > Substitution variables" set:
      - `_BUCKET_NAME=YOUR_BUCKET_NAME`
    - Select the Service Account you created above

1. **Visit the website**

    In a browser, go to `http://YOUR_LB_IP`

    You should be greeted by `Hello, World!`

1. **Update the website**

    Update the `index.html` in your repository to display something else and commit

1. **See the website being updated**

    You can monitor the build process in the [Cloud Build Dashboard](https://console.cloud.google.com/cloud-build/builds)

    After the build is complete, visit the site again. It should have updated.
    
    If it didn't, there might be some caching going on. However, you can check for the updated file directly in the GCS Bucket