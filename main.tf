#  VPC
resource "aws_vpc" "test-vpc" {
    cidr_block = "10.0.0.0/16"
}

#  Internet Gateway
resource "aws_internet_gateway" "test-ig" {
    vpc_id = aws_vpc.test-vpc.id
    tags = {
        Name = "gateway1"
    }
}

#  route table
resource "aws_route_table" "test-rt" {
    vpc_id = aws_vpc.test-vpc.id
    route {
        # pointing to the internet
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.test-ig.id
    }
    route {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.test-ig.id
    }
    tags = {
        Name = "rt1"
    }
}



#  subnet
resource "aws_subnet" "test-subnet" {
    vpc_id = aws_vpc.test-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "subnet1"
    }
}

# Associating the subnet
resource "aws_route_table_association" "test-rt-sub-assoc" {
    subnet_id = aws_subnet.test-subnet.id
    route_table_id = aws_route_table.test-rt.id
}

#  Security Group
resource "aws_security_group" "test-sg" {
    name = "test-sg"
    description = "Enable web traffic for the project"
    vpc_id = aws_vpc.test-vpc.id
    ingress {
        description = "HTTPS traffic"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "HTTP traffic"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "SSH port"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    tags = {
        Name = "test-sg1"
    }
}

#  network interface
resource "aws_network_interface" "test-ni" {
    subnet_id = aws_subnet.test-subnet.id
    private_ips = ["10.0.1.10"]
    security_groups = [aws_security_group.test-sg.id]
}

# Attaching an elastic IP
resource "aws_eip" "test-eip" {
    vpc = true
    network_interface = aws_network_interface.test-ni.id
    associate_with_private_ip = "10.0.1.10"
}

#  redhat EC2 instance
resource "aws_instance" "test-instance" {
    ami = "ami-06640050dc3f556bb"
    instance_type = "t2.micro"
    availability_zone = "us-east-1b"
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.test-ni.id
    }

}