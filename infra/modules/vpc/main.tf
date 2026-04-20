# VPC
resource "aws_vpc" "my_vpc" {
    cidr_block           = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = merge(local.common_tags, {
        Name ="${var.name}-vpc"
})
}

# Public subnets for internet facing load balancer and ingress

resource "aws_subnet" "public"{
    count = length(var.azs)

    vpc_id                  = aws_vpc.my_vpc.id
    cidr_block              = var.public_subnet_cidrs[count.index]
    availability_zone       = var.azs[count.index]
    map_public_ip_on_launch = true

    tags = merge(local.common_tags, {
        Name = "${var.name}-public_subnets-${count.index + 1}"

        "kubernetes.io/role/elb" = "1"    # This subnet is allowed to be used by Kubernetes to create PUBLIC load balancers

    })
}

# Private subnets for EKS

resource "aws_subnet" "private" {
    count = length(var.azs)

    vpc_id            = aws_vpc.my_vpc.id
    cidr_block        = var.private_subnet_cidrs[count.index]
    availability_zone = var.azs[count.index]

    tags = merge(local.common_tags, {
        Name = "${var.name}-private_subnets-${count.index + 1}"

        "kubernetes.io/role/internal-elb" = "1"      # This subnet is for internal (private) load balancers 
    })
}


# Internet gateway for access to the internet

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.my_vpc.id

    tags = local.common_tags
}

# Allocated IP for Nat gateway 

resource "aws_eip" "nat_ip" {
    domain = "vpc"

    tags = local.common_tags

}

# Nat Gateway for outbound internet access from private subnets

resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.nat_ip.id
    subnet_id     = aws_subnet.public[0].id     # Placed in the first public subnet
    depends_on    = [aws_internet_gateway.igw]


    tags = local.common_tags 
}

# Private route table

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gw.id
    }

    tags = local.common_tags
  
}

# Associate all private subnets with the private route table

resource "aws_route_table_association" "private" {
    count = length(var.azs)

    subnet_id      = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
}

# Public route table

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = local.common_tags

}

# Associate all public subnets with public route table

resource "aws_route_table_association" "public" {
    count = length(var.azs)

    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}
