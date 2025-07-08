variable "yc_token" {}
variable "yc_cloud_id" {}
variable "yc_folder_id" {}
variable "image_id" {
  default = "fd876gids9srs8ma0592"
}
variable "public_ssh_key" {
  description = "Публичный SSH ключ для подключения"
  type        = string
}