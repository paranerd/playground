# Google Cloud Snippets: Hugo on Firebase

Continuously deploy a static Hugo website to Firebase using Cloud Build.

## Preparation

1. **Create a Service Account**

    Provide it with the following roles:
      - Logs Writer
      - Storage Admin
      - Firebase Hosting Admin

1. **Create a [Firebase](https://console.firebase.google.com/) project**

    Select "Add Firebase to Google Cloud project" and choose the one you just created the Service Account in

1. **Set up Hugo**

    For this demo it's sufficient to copy all files in this folder into your repository. It contains the bare minimum required to have a running website.

    However, if you want to take it to production, follow the [Quick Start Guide](https://gohugo.io/getting-started/quick-start/) on how to get Hugo installed and set up.

1. **Create a Cloud Build trigger**

    - Go to [Cloud Build Triggers](https://console.cloud.google.com/cloud-build/triggers)
    - Select your repo and branch
    - For "Configuration" select "Cloud Build"
    - Under "Advanced > Substitution variables" set:
      - `_HUGO_VERSION_=YOUR_HUGO_VERSION` (e.g. 0.139.0)
    - Select the Service Account you created above

1. **Visit the website**

    Find the URL of your website at the end of the [Build history](https://console.cloud.google.com/cloud-build/builds) logs output

1. **Update the website**

    Update `layouts/index.html` to your liking and commit

1. **See the website being updated**

    Monitor the build process in the [Cloud Build Dashboard](https://console.cloud.google.com/cloud-build/builds)

    After the build is complete, visit the site again. It should have updated.