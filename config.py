import os

CONFIG_ID = os.environ.get("CONFIG_ID") 

# You can get from `gcloud auth print-access-token`
JWT_OR_OAUTH = os.environ.get("JWT_OR_OAUTH")
