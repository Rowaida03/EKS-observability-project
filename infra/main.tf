module "vpc" {
    source = "./modules/vpc"

    vpc_cidr = "10.0.0.0/16"
    azs = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
    public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

}

module "eks" {
    source = "./modules/eks"

    cluster_name = "eks-observability-cluster"
    k8_version = "1.30"
    node_group_name = "general-node-group"
    private_subnet_ids = module.vpc.private_subnet_ids
}