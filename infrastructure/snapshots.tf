resource "yandex_compute_snapshot_schedule" "daily_snapshots" {
  name = "daily-snapshots"
  schedule_policy { expression = "0 3 * * *" }
  snapshot_count = 7

  disk_ids = flatten([
    yandex_compute_instance.web[*].boot_disk[0].disk_id,
    yandex_compute_instance.prometheus.boot_disk[0].disk_id,
    yandex_compute_instance.grafana.boot_disk[0].disk_id,
    yandex_compute_instance.elasticsearch.boot_disk[0].disk_id,
    yandex_compute_instance.kibana.boot_disk[0].disk_id
  ])
}