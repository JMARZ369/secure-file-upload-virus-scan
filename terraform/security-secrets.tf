resource "aws_secretsmanager_secret" "virustotal_api_key" {
  name        = "virustotal-api-key"
  description = "API key for VirusTotal"
}

resource "aws_secretsmanager_secret_version" "virustotal_api_key_version" {
  secret_id     = aws_secretsmanager_secret.virustotal_api_key.id
  secret_string = jsonencode({
    api_key = var.virustotal_api_key_value
  })
}
