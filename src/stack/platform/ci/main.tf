terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_openid_connect_provider" "github" {
  count = var.manage_github_oidc_provider ? 0 : 1
  url   = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.manage_github_oidc_provider ? 1 : 0

  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = distinct([
    for cert in data.tls_certificate.github.certificates :
    replace(cert.sha1_fingerprint, ":", "")
  ])

  tags = merge(var.tags, {
    Component = "github-oidc"
  })
}

locals {
  oidc_provider_arn = (
    var.manage_github_oidc_provider
    ? aws_iam_openid_connect_provider.github[0].arn
    : data.aws_iam_openid_connect_provider.github[0].arn
  )
}
