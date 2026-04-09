-- Databricks SQL dashboard queries for Free Edition
USE SCHEMA metrics_demo;

-- 1) Latest value per metric type
SELECT
  metric_type,
  source,
  value,
  ts
FROM (
  SELECT
    metric_type,
    source,
    value,
    ts,
    row_number() OVER (PARTITION BY metric_type ORDER BY ts DESC) AS rn
  FROM metrics
) x
WHERE rn = 1
ORDER BY metric_type;

-- 2) Average CPU & memory in last 15 minutes
SELECT
  round(avg(CASE WHEN metric_type = 'cpu' THEN value END), 2) AS avg_cpu_15m,
  round(avg(CASE WHEN metric_type = 'memory' THEN value END), 2) AS avg_memory_15m
FROM metrics
WHERE ts >= timestampadd(MINUTE, -15, current_timestamp());

-- 3) Time series for server metrics (last 2h)
SELECT
  date_trunc('minute', ts) AS minute_bucket,
  metric_type,
  round(avg(value), 2) AS avg_value
FROM metrics
WHERE metric_type IN ('cpu', 'memory', 'request_count')
  AND ts >= timestampadd(HOUR, -2, current_timestamp())
GROUP BY 1, 2
ORDER BY 1, 2;

-- 4) Time series for IoT metrics (last 6h)
SELECT
  date_trunc('minute', ts) AS minute_bucket,
  metric_type,
  round(avg(value), 2) AS avg_value
FROM metrics
WHERE metric_type IN ('temperature', 'humidity', 'soil_moisture', 'light_intensity', 'pressure')
  AND ts >= timestampadd(HOUR, -6, current_timestamp())
GROUP BY 1, 2
ORDER BY 1, 2;

-- 5) Simple alert count in last 1h
SELECT
  sum(CASE WHEN metric_type = 'cpu' AND value >= 85 THEN 1 ELSE 0 END) AS cpu_alerts,
  sum(CASE WHEN metric_type = 'memory' AND value >= 90 THEN 1 ELSE 0 END) AS memory_alerts,
  sum(CASE WHEN metric_type = 'temperature' AND value >= 32 THEN 1 ELSE 0 END) AS temperature_alerts,
  sum(CASE WHEN metric_type = 'humidity' AND value >= 80 THEN 1 ELSE 0 END) AS humidity_alerts
FROM metrics
WHERE ts >= timestampadd(HOUR, -1, current_timestamp());

-- 6) Top sources by data volume
SELECT
  source,
  count(*) AS total_points
FROM metrics
GROUP BY source
ORDER BY total_points DESC;
