variable "account_id" {
  description = "Cloudflare account ID."
  type        = string
}

variable "zone_id" {
  description = "Cloudflare zone ID for the application hostname."
  type        = string
}

variable "hostname" {
  description = "Public hostname for ilink-web (e.g. `camera.example.com`)."
  type        = string
}

variable "allowed_emails" {
  description = "Email addresses permitted to access ilink-web."
  type        = set(string)
}

variable "identity_provider_id" {
  description = "Cloudflare Access identity provider ID used for authentication."
  type        = string
}
