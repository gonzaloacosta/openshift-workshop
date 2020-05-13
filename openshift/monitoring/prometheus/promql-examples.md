## PromQL ejemplos de Codigo

- CPU Usage
```
topk(25, sort_desc(sum(avg_over_time(pod:container_cpu_usage:sum{container="",pod!="",namespace='ns1'}[5m])) BY (pod, namespace)))
```
- Memory Usage
```
topk(25, sort_desc(sum(avg_over_time(container_memory_working_set_bytes{container="",pod!="",namespace='ns1'}[5m])) BY (pod, namespace)))
```

- Filesystem Usage
```
topk(25, sort_desc(sum(pod:container_fs_usage_bytes:sum{container="",pod!="",namespace='ns1'}) BY (pod, namespace)))
```

- Receive Bandwith
```
topk(25, sort_desc(sum(rate(container_network_receive_bytes_total{ container="POD", pod!= "", namespace='ns1'}[5m])) BY (namespace, pod)))
```

- Transmit Bandwith
```
topk(25, sort_desc(sum(rate(container_network_transmit_bytes_total{ container="POD", pod!= "", namespace='ns1'}[5m])) BY (namespace, pod)))
```