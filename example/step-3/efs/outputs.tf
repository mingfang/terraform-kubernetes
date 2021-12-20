output "storage_class_name" {
  value = k8s_storage_k8s_io_v1_storage_class.efs.metadata[0].name
}