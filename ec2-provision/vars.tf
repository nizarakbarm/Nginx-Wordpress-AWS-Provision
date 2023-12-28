variable "sg_ingress_rules" {
    type = list(object({
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_block  = string
        description = string
    }))
    default = [ 
      {
        description   = "Port SSH"
        from_port     = 5522
        to_port       = 5522
        cidr_block    = "0.0.0.0/0"
        protocol      = "TCP"
      },
      {
        description   = "Port HTTP"
        from_port     = 80
        to_port       = 80
        cidr_block    = "0.0.0.0/0"
        protocol      = "TCP"
      },
      {
        description   = "Port HTTPS"
        from_port     = 443
        to_port       = 443
        cidr_block    = "0.0.0.0/0"
        protocol      = "TCP"
      },
      {
        description   = "Port needed for apt"
        from_port     = 32768
        to_port       = 65535
        cidr_block    = "0.0.0.0/0"
        protocol      = "TCP"
      }, 
    ]
}