variable "state_passphrase" {
  description = "Passphrase to encrypt the state."
  type        = string
  sensitive   = true
}

variable "account_id" {
  description = "The Cloudflare account everything here belongs to."
  type        = string
}

variable "zones" {
  description = "Every domain on the account."
  type        = set(string)
}
