variable "environment" {
  description = "App environment"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "App name"
  type        = string
}

variable "subscription_id" {
  description = "Enter the subscription_id"
}

variable "client_id" {
  description = "Enter the client_id"
}

variable "client_secret" {
  description = "Enter the client_secret"
}

variable "tenant_id" {
  description = "Enter the tenant_id"
}


# variable "s3_object_list" {
#   description = "List of objects that will be saved int he s3"
#   type = list(object({
#     key           = string
#     file_location = string
#   }))
#   default = []
# }

# variable "tags" {
#   description = "Tags of the project."
#   type        = map(string)
#   default     = {}
# }

# variable "zip_files" {
#   description = "List of objects that will be zipped"
#   type = list(object({
#     location = string
#     output   = string
#   }))
#   default = []
# }

# variable "s3_lambda_functions" {
#   description = "List of lambda functions that will be saved int he s3"
#   type = list(object({
#     key           = string
#     file_location = string
#     runtime       = string
#     name          = string
#     handler       = string
#   }))
#   default = []
# }
