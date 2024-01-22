# Define the Route 53 hosted zone for the domain
resource "aws_route53_zone" "devspace_io" {
  name = "devspace.io"
}

# Define an A record for the domain that maps to the IP address
resource "aws_route53_record" "devspace_io" {
  zone_id = aws_route53_zone.devspace_io.zone_id
  name    = "devspace.io"
  type    = "A"
  ttl     = 300

  records = ["127.0.0.1"]

  depends_on = [aws_route53_zone.devspace_io]
}

# Define a CNAME record for the subdomain that maps to another domain
resource "aws_route53_record" "www_heyvaldemar_com" {
  zone_id = aws_route53_zone.devspace_io.zone_id
  name    = "www.devspace.io"
  type    = "CNAME"
  ttl     = 300

  records = ["devspace.io"]

  depends_on = [aws_route53_zone.devspace_io]
}
