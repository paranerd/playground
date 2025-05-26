# Google Cloud Snippets: VPC Service Controls

VPC Service Controls is a Google Cloud feature that lets you set up a secure perimeter to guard against data exfiltration.

The following demonstrates how to protect a file in GCS from being accessed outside of its project.

## How to demo

1. Have 2 projects (e.g. `project-a` and `project-b`)

1. In `project-a` create a Cloud Storage Bucket and upload any file to it

1. In the GCS Bucket browser click on the three dots for the file just uploaded

1. Click on "Copy gsutil URI"

1. In `project-b` create a Compute Engine Instance

1. Get the E-Mail from the default Compute Engine [Service Account](https://console.cloud.google.com/iam-admin/serviceaccounts) (ends with "compute@developer.gserviceaccount.com")

1. In `project-a` go to the [GCS browser](https://console.cloud.google.com/storage/browser)

1. Select the Bucket you created earlier and click "Permissions" > Add principal

1. Add the Compute Engine Service Account's E-Mail with the role of "Storage Object Viewer"

1. SSH into the Compute Engine Instance

1. Use `gsutil` to access the file

    ```bash
    gsutil ls [gs://...]
    ```

    This should simply output the URI again which shows that it has permission to do so

1. In the project selector select the Organization (not a project)

1. Go to Security > [VPC Service Controls](https://console.cloud.google.com/security/service-perimeter)

1. Click on "Manage Policies" > "Create" (only if there's none already)

1. Enter a name and click "Create Access Policy"

1. Back in the overview click on "New Perimeter" under "Enforced Mode"

1. Give it a title

1. Under "Resources to protect" add `project-a` (where the GCS Bucket is)

1. Under "Restricted Services" click "Add Services" and look for "storage.googleapis.com" to be added

1. Leave the rest at default and click "Create"

1. Give it a moment to propagate

1. Try accessing the file again from within the Compute Engine Instance
