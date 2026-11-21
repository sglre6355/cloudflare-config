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

variable "ilink_web" {
  description = "Cloudflare zone, public hostname, and permitted email addresses for ilink-web."
  type = object({
    zone           = string
    hostname       = string
    allowed_emails = set(string)
  })
}
