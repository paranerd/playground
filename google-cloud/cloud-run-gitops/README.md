# Google Cloud Snippets: Cloud Run GitOps

How to automatically and continuously deploy a Cloud Run Service from a Git repository

Based on the [official documentation](https://cloud.google.com/run/docs/quickstarts/deploy-continuously)

## Prerequisites

1. Create a GitHub repository and add the files from this folder

## How to demo

1. Go to [Cloud Run](https://console.cloud.google.com/run)
1. Click on "Deploy Container" > Service
1. Select "Continuously deploy from a repository"
1. Click on "Set up with Cloud Build"
1. Select your repository
    - If it does not show up, you may need to set up Cloud Build for GitHub
1. For "Build Type" select "Google Cloud Buildpacks"
1. Save
1. Give the service a name
1. Allow unauthenticated invocations
1. Wait for the service to be deployed
1. Click on the URL provided to open the service in the browser
    - This should show "Hello, World!"
1. Edit the `index.js`
    - For example: `res.send('Hello, World v2!');`
1. Commit your change
1. See your [build](https://console.cloud.google.com/cloud-build/builds) running
1. Once deployed, refresh the service's website to see the updated text