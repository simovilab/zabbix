# Monitoring & Security Requirements

## Monitoring Requirements (Zabbix)

### 1. Infrastructure Monitoring

#### Host-Level Metrics
- CPU utilization, load average, I/O wait
- Memory usage, swap usage, OOM events
- Disk space, IOPS, throughput, latency, inode usage
- Network throughput, packet loss, TCP connections, latency

#### Docker Container Monitoring
- Per-container CPU and memory usage
- Container restart counts and uptime
- Network and block I/O per container
- Container health status monitoring
- Discovery and auto-registration of containers

### 2. Database Monitoring (PostgreSQL + PostGIS)

#### Connection Management
- Active connections vs. max connections
- Idle-in-transaction connections
- Connection pool utilization

#### Performance Metrics
- Transaction throughput (commits/rollbacks)
- Cache hit ratio
- Slow query detection (>1 second)
- Deadlock monitoring
- Database size and growth rate
- Replication lag (if applicable)

#### PostGIS Specific
- Spatial index usage
- Geospatial query performance

### 3. Cache Monitoring (Redis)

#### Memory & Performance
- Memory usage vs. maxmemory limit
- Connected and blocked clients
- Operations per second
- Keyspace hit/miss ratio

#### Data Management
- Evicted and expired keys
- Persistence status (last save time)
- Database key count

### 4. Web Server Monitoring (Nginx)

#### Connection Metrics
- Active connections
- Request rate and total requests
- Connection states (reading, writing, waiting)

#### HTTP Performance
- Status code distribution (2xx, 3xx, 4xx, 5xx)
- Average response time
- Error rate trends

### 5. Application Monitoring (Django)

#### Health & Availability
- Application health endpoint status (/health/)
- Service uptime and availability

#### Application Metrics
- API endpoint response times
- Application error counts (ERROR, CRITICAL logs)
- Active user sessions
- WebSocket connection count

#### Background Processing (Celery)
- Queue depth per queue
- Active task count
- Task success/failure rates
- Worker availability and status
- Registered tasks inventory

### 6. GTFS Transit Data Monitoring

#### Data Freshness
- Time since last GTFS Realtime update
- Active vehicle count vs. expected
- Trip updates received per hour

#### Data Quality
- GTFS validation error count
- Feed fetch success rate
- Data completeness percentage

#### Transit Operations
- Active transit agencies count
- Active routes and alerts
- Display network connectivity
- Connected displays vs. total displays

### 7. Service Availability Monitoring

#### Service Status Checks
- Docker service status per container
- Port availability monitoring
- Process count monitoring
- DNS resolution time

#### SSL/TLS Monitoring
- Certificate expiration tracking
- SSL handshake performance

#### External Dependencies
- GTFS feed source availability
- Third-party API endpoint status

### 8. Alerting & Notifications

#### Multi-Channel Alerts
- Email notifications
- SMS for critical alerts
- Slack/Teams integration
- Webhook integrations

#### Alert Management
- Severity-based routing (Disaster, High, Average, Warning, Info)
- Alert escalation policies
- Alert correlation and deduplication
- Recovery notifications

---
