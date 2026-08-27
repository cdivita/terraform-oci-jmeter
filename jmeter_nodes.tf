locals {
  compute_flexible_shapes = toset([for s in data.oci_core_shapes.flexible_shapes.shapes : s.name if s.is_flexible])
  jmeter_jvm_heap_size    = max(512, (var.nodes_memory / 4) * 1024)
}

locals {
  is_nodes_shape_flexible = contains(local.compute_flexible_shapes, var.nodes_shape)
  jmeter_jvm_permgen_size = max(128, local.jmeter_jvm_heap_size / 4)
}