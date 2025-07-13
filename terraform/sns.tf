resource "aws_sns_topic" "threat_alerts" {
  name = "${var.project_name}-threat-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.threat_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
