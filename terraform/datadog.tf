resource "datadog_monitor" "app_health" {
  name    = "Nginx Health Alert"
  type    = "metric alert"
  message = "Nginx is not responding on {{host.name}}"
  query   = "avg(last_5m):avg:http.can_connect{url:http://localhost/} < 1"
  monitor_thresholds {
    critical = 1
  }
  notify_no_data = false
  tags          = ["service:nginx", "env:production"]
}
