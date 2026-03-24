terraform {
  required_version = ">= 1.5.0"
  
  # For local/lab practice, we use local state.
  # For production, this would be swapped to S3/GCS/Azure Blob.
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    # Using local/null providers as placeholders for learning.
    # Later, this could be aws, google, or kubernetes.
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
