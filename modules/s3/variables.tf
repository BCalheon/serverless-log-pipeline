variable "bucket_name" {
  description = "Name of the bucket that will be created"
  type        = string
}

variable "tags" {
  description = "Resource tags (FinOps)"
  type        = map(string)
  default     = {}
}

variable "allow_force_destroy" {
  description = "Permission to delete the bucket even with archives inside" #use only in lab's :)
  type        = bool
  default     = false # Safe pattern
}