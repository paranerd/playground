# Kubernetes Snippets: Binary Authentication

## Prerequisites

1. **Set some environment variables**

    Replace where appropriate

    ```bash
    PROJECT_ID=[PROJECT_ID]
    ```

    ```bash
    LOCATION=us-central1
    ```

1. **Enable the Binary Authorization API**

    ```bash
    gcloud services enable binaryauthorization.googleapis.com
    ```

1. **Create a PKIX key pair**

    [Documentation](https://cloud.google.com/binary-authorization/docs/creating-attestors-console#create_a_pkix_key_pair)

1. **Create an attestor**

    [Documentation](https://cloud.google.com/binary-authorization/docs/creating-attestors-console#create-the-attestor)

    Notes:

    - To get the key resource ID (for configuring the attestor), go to your [keyrings](https://console.cloud.google.com/security/kms/keyrings), click on the one you just created, then click on the three-dot action menu and select "Copy resource name"

1. **Create Artifact Registry repo**

    ```bash
    gcloud artifacts repositories create hello-world --repository-format=docker --location=${LOCATION}
    ```

1. **Set proper IAM permissions**

    The GKE service account (per default that's the Compute Engine SA) must have the following roles:

    - Artifact Registry Reader

    **Important:** This must be done BEFORE creating the Cluster!

1. **Create a GKE cluster**

    ```bash
    gcloud container clusters create cluster-1 --region=${LOCATION} --binauthz-evaluation-mode=project-singleton-policy-enforce
    ```

## How to demo

### Manually

1. **Pull Nginx image**

    ```bash
    docker pull nginx
    ```

1. **Tag the image**

    ```bash
    docker tag nginx "${LOCATION}-docker.pkg.dev/${PROJECT_ID}/hello-world/nginx"
    ```

1. **Push the image to private repo**

    ```bash
    docker push ${LOCATION}-docker.pkg.dev/${PROJECT_ID}/hello-world/nginx
    ```

1. **Create a Pod**

    ```bash
    kubectl run my-nginx --image=${LOCATION}-docker.pkg.dev/${PROJECT_ID}/hello-world/nginx
    ```

1. **See the pod running**

    ```bash
    kubectl get pods
    ```

1. **Update the Binary Auth Policy**

    Edit [the policy](https://console.cloud.google.com/security/binary-authorization/policy) and set it to "Disallow all images"

1. **Delete the Pod**

    ```bash
    kubectl delete pod my-nginx
    ```

1. **See the pod gone**

    ```bash
    kubectl get pods
    ```

1. **Try re-creating the Pod**

    ```bash
    kubectl run my-nginx --image=${LOCATION}-docker.pkg.dev/${PROJECT_ID}/hello-world/nginx
    ```

    This should produce an error message stating "Denied by always_deny admission rule"

1. **Create an exception**

    Edit [the policy](https://console.cloud.google.com/security/binary-authorization/policy/edit) and add "Images excempt from this policy"

    The image pattern is as follows:

    `[YOUR_LOCATION_HERE]-docker.pkg.dev/[YOUR_PROJECT_ID_HERE]/hello-world/nginx`

1. **Try re-creating the Pod**

    ```bash
    kubectl run my-nginx --image=${LOCATION}-docker.pkg.dev/${PROJECT_ID}/hello-world/nginx
    ```

    This should work fine

1. **Delete the pod again**

1. **Use attestation**

    - Remove the exemption created above
    - Set the default policy rule to "Require attestations"
    - Add the Attestor created above
    - Save
    - Store the digest of the private `nginx` image
        ```bash
        IMAGE_DIGEST=$(gcloud artifacts docker images list ${LOCATION}-docker.pkg.dev/${PROJECT_ID}/hello-world/nginx --format 'value(DIGEST)' --quiet)
        ```
    - Create the attestation

        ```bash
        gcloud beta container binauthz attestations sign-and-create \
            --project="${PROJECT_ID}" \
            --artifact-url="${LOCATION}-docker.pkg.dev/${PROJECT_ID}/hello-world/nginx@${IMAGE_DIGEST}" \
            --attestor="my-attestor" \
            --attestor-project="${PROJECT_ID}" \
            --keyversion-project="${KMS_KEY_PROJECT_ID}" \
            --keyversion-location="${KMS_KEY_LOCATION}" \
            --keyversion-keyring="${KMS_KEYRING_NAME}" \
            --keyversion-key="${KMS_KEY_NAME}" \
            --keyversion="${KMS_KEY_VERSION}"
        ```

1. **Create Pod**

    ```bash
    kubectl run my-nginx --image="${LOCATION}-docker.pkg.dev/${PROJECT_ID}/hello-world/nginx@${IMAGE_DIGEST}"
    ```

    **Note:** This time we need to attach the digest to be specific about the image

### Cloud Build

1. **Enable the Binary Authorization API**

    ```bash
    gcloud services enable cloudbuild.googleapis.com
    ```

1. **Build and register the custom attestation build step**

    Follow the two steps of [the documentation](https://cloud.google.com/binary-authorization/docs/cloud-build#build_and_register_the_custom_build_step_with)

1. **Execute Cloud Build**

    ```bash
    gcloud builds submit . --config cloudbuild.yaml --substitutions _LOCATION=${LOCATION}
    ```