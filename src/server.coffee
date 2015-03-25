cluster = require 'cluster'
path = require 'path'
log = require 'npmlog'
numCPUs = (require 'os').cpus().length

if cluster.isMaster
    cluster.fork i for i in [1..numCPUs]
    log.info path.basename(__filename), "Started #{numCPUs} workers"
    cluster.on 'exit', (worker) -> log.error path.basename(__filename), "Worker #{worker.process.pid} stopped!"

else (require './app')()
