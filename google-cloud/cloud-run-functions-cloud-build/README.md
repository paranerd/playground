# Google Cloud Snippets: Deploy Cloud Run Function via Cloud Build

How to automatically and continuously deploy a Cloud Run Function from a Git repository

## Prerequisites

1. Fork this repository or create a new GitHub repository and add the files from this folder
    
    Important: If you create a new repo 2 things are important:
    
    1. Make sure to update `--source` in `cloudbuild.yaml` according to the path in your repository (or remove it entirely if everything is in the root directory)
    1. If the `cloudbuild.yaml` is NOT in the root directory, update the `Cloud Build configuration file location` accordingly when creating the Trigger below

## How to demo

1. Go to [Cloud Build Triggers](https://console.cloud.google.com/cloud-build/triggers)
1. Click on "Connect repository" and follow the wizzard
1. Go to [Create Trigger](https://console.cloud.google.com/cloud-build/triggers/add) to create a Trigger
1. Fill out the required fields, select your repo and leave everything to default
1. Trigger the build
      Click "Run" in the Triggers overview to manually trigger the build
1. Call the function
    - In the browser
      
      In the [Cloud Functions Overview](https://console.cloud.google.com/functions/list) click on the `hello-1` function to find its URL
    
    - In the CLI

      ```bash
      gcloud functions call hello-1 --region=europe-west3
      ```
1. Change the code and commit
    For example, swap the `!` in the response for a `?`. Doing this will trigger another build.

    See the build's status in the [Build history](https://console.cloud.google.com/cloud-build/builds)

1. Call the function again

    Check out the updated output in the browser or CLI.