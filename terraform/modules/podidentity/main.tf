resource "aws_iam_role" "cert-manager-role" {
  name = "cert-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

resource "aws_iam_role_policy" "cert-manager-policy" {
  name = "cert-manager-policy"
  role = aws_iam_role.cert-manager-role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "route53:GetChange",
        "Effect" : "Allow",
        "Resource" : "arn:aws:route53:::change/*"
      },
      {
        "Action" : [
          "route53:ListResourceRecordSets",
          "route53:ChangeResourceRecordSets"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:route53:::hostedzone/${var.route53_zone_id}"
      },
      {
        "Action" : "route53:ListHostedZonesByName",
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}


resource "aws_iam_role" "external-dns-role" {
  name = "external-dns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = ["sts:AssumeRole", "sts:TagSession"]

    }]
  })
}


resource "aws_iam_role_policy" "external-dns-policy" {
  name = "external-dns-policy"
  role = aws_iam_role.external-dns-role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "route53:ChangeResourceRecordSets",
        "Effect" : "Allow",
        "Resource" : "arn:aws:route53:::hostedzone/${var.route53_zone_id}"
      },
      {
        "Action" : [
          "route53:ListTagsForResource",
          "route53:ListResourceRecordSets",
          "route53:ListHostedZones"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "external-secrets-role" {
  name = "external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

resource "aws_iam_role_policy" "external-secrets-policy" {
  name = "external-secrets-policy"
  role = aws_iam_role.external-secrets-role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "secretsmanager:ListSecrets",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        "Effect" : "Allow",
        "Resource" : "*" # to be updated to the specific secret store
      }
    ]
  })
}

resource "aws_eks_pod_identity_association" "cert-manager" {
  cluster_name    = var.cluster_name
  namespace       = var.cert_manager_namespace
  service_account = "cert-manager"
  role_arn        = aws_iam_role.cert-manager-role.arn
}

resource "aws_eks_pod_identity_association" "external-dns" {
  cluster_name    = var.cluster_name
  namespace       = var.external_dns_namespace
  service_account = "external-dns"
  role_arn        = aws_iam_role.external-dns-role.arn
}

resource "aws_eks_pod_identity_association" "external-secrets" {
  cluster_name    = var.cluster_name
  namespace       = var.external_secrets_namespace
  service_account = "external-secrets"
  role_arn        = aws_iam_role.external-secrets-role.arn
}