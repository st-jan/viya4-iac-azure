# Copyright © 2020-2023, SAS Institute Inc., Cary, NC, USA. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

variable "prefix" {
  description = "A prefix used in the name for all the Azure resources created by this script."
  type        = string
}

variable "name" {
  description = "The name to assign to the acr."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Azure Container Registry"
  type        = string
}

variable "network_resource_group_name" {
  description = "The name of the resource group in which to create network related resources"
  type        = string
}

variable "location" {
  description = "The Azure Region to provision all resources in this script"
  type        = string
}

variable "vnet_name" {
  description = "Azure Virtual Network"
  type        = string
}

variable "virtual_network_id" {
  description = "The ID of the Virtual Network that should be linked to the DNS Zone. Changing this forces a new resource to be created."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the virtual network subnet to create the private endpoint in."
  type        = string
}

variable "tags" {
  description = "Map of tags to be placed on the Resources"
  type        = map(any)
}

variable "sku" {
  description = "Container Registry SKU"
  type        = string
  default     = "Basic"
}

variable "admin_enabled" {
  description = "Enable admin user"
  type        = bool
  default     = false
}

variable "public_access_enabled" {
  description = "Enable admin user"
  type        = bool
  default     = false
}

variable "geo_replica_locs" {
  description = "A location where the container registry should be geo-replicated."
  type        = list(any)
  default     = null
}

variable "public_access_cidrs" {
  description = "Container Registry access IP ranges"
  type        = list(any)
}

variable "nsg_name" {
  description = "Name of the network security group to add the access cidrs to"
  type        = string
}

variable "aks_principal_id" {
  description = "Principal id used by the AKS cluster that needs to be granted Pull permissions"
  type        = string
}




