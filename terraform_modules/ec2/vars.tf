variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cert_private_key" {
  type = string
}

variable "cert_body" {
  type = string
}

variable "key_name" {
  type = string
}

variable "ecs_instance_profile_name" {
  type = string
}