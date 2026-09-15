resource "aws_sqs_queue" "this" {
  name                       = var.queue_name
  visibility_timeout_seconds = 60
  message_retention_seconds  = 86400
}
