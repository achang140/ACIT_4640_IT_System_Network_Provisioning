resource "aws_security_group_rule" "inbound_http_private_sg" {
    security_group_id = aws_security_group.private_sg.id
    type        = "ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    source_security_group_id = aws_security_group.public_sg.id
}