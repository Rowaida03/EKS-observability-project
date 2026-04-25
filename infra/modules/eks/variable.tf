variable "cluster_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "k8_version" {
  type = string
}

variable "node_group_name" {
  type = string
}