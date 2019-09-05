output "webhook_url" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}/webhook"
  description = "The Webhook destination URL you should setup within your ControlShift instance at Settings > Integrations > Webhooks"
}
