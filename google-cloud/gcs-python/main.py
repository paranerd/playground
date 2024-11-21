import os
from google.cloud import storage

os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = '/path/to/sa-key.json'


def create_bucket(bucket_name):
  """Creates a new bucket."""

  storage_client = storage.Client()

  bucket = storage_client.create_bucket(bucket_name)

  print(f"Bucket {bucket.name} created")