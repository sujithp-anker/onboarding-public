provider "aws" {
  region = "eu-central-1"
  assume_role {
    role_arn     = "arn:aws:iam::546010718980:role/AdminAccessRole"
    session_name = "gaia-session"
  }
}