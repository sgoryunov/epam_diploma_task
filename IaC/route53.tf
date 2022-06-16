# data "aws_route53_zone" "selected" {
#   name         = "itunes-gr.ru."
#   private_zone = false
# }

# resource "aws_route53_record" "acm_verification" {
#   zone_id = data.aws_route53_zone.selected.zone_id
#   type    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_type
#   name    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_name
#   ttl     = "300"
#   records = [aws_acm_certificate.cert.domain_validation_options[0].resource_record_value]
# }

# // This resource doesn't create anything
# // it just waits for the certificate to be created, and validation to succeed, before being created
# resource "aws_acm_certificate_validation" "cert" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [aws_route53_record.acm_verification.fqdn]
# }