Postgresql.conf has been optimized following [pgtune](https://pgtune.leopard.in.ua/)'s proposed parameters:

### INPUT PARAMETERS
* DB Version: 13
* OS Type: linux
* DB Type: oltp
* Total Memory (RAM): 1000 GB
* CPUs num: 140
* Connections num: 320
* Data Storage: ssd

### OUTPUT PARAMETERS
* max_connections = 320
* shared_buffers = 250GB
* effective_cache_size = 750GB
* maintenance_work_mem = 2GB
* checkpoint_completion_target = 0.9
* wal_buffers = 16MB
* default_statistics_target = 100
* random_page_cost = 1.1
* effective_io_concurrency = 200
* work_mem = 200MB
* min_wal_size = 2GB
* max_wal_size = 8GB
* max_worker_processes = 140
* max_parallel_workers_per_gather = 4
* max_parallel_workers = 140
* max_parallel_maintenance_workers = 4
* 
