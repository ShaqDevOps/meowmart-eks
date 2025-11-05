#########################################
# Route 53 Alias Record for MeowMart
#########################################

data "aws_route53_zone" "shaqserver" {
  name         = "shaqserver.com."
  private_zone = false


}


data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "meowmart_alias" {
  depends_on = [kubernetes_service.meowmart_service]

  zone_id         = data.aws_route53_zone.shaqserver.zone_id
  name            = "shaqserver.com"
  type            = "A"
  allow_overwrite = true

  alias {
    # Automatically use the NLB/ALB hostname created by your Kubernetes service
    name                   = replace(kubernetes_service.meowmart_service.status[0].load_balancer[0].ingress[0].hostname, "/\\.$/", "")
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = false
  }
}

# Request an ACM certificate
resource "aws_acm_certificate" "meowmart_cert" {
  domain_name       = "shaqserver.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS validation record automatically
resource "aws_route53_record" "meowmart_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.meowmart_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.value]
  ttl             = 300
  type            = each.value.type
  zone_id         = data.aws_route53_zone.shaqserver.zone_id
}

# Validate the certificate once DNS record exists
resource "aws_acm_certificate_validation" "meowmart_cert_validation" {
  certificate_arn         = aws_acm_certificate.meowmart_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.meowmart_cert_validation : record.fqdn]
}
