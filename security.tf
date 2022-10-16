/*
resource "aws_security_group" "PubSubnet_SG" {
    name = "PubSubnet_SG"
    description = "Public subnet security group"
    vpc_id = aws_vpc.richie_vpc.id

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["68.225.132.20/32"]
    }

    egress [
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    ]
}
*/
