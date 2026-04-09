-- Databricks SQL setup script for Free Edition (SQL Warehouse)
-- Creates a demo table and inserts synthetic metrics data.

CREATE SCHEMA IF NOT EXISTS metrics_demo;
USE SCHEMA metrics_demo;

CREATE TABLE IF NOT EXISTS metrics (
  id BIGINT GENERATED ALWAYS AS IDENTITY,
  metric_type STRING,
  value DOUBLE,
  source STRING,
  ts TIMESTAMP
)
USING DELTA;

-- Optional reset for reruns
TRUNCATE TABLE metrics;

-- Generate 720 rows per metric type (last 24h, every 2 minutes)
-- 8 metric types total => 5760 rows
INSERT INTO metrics (metric_type, value, source, ts)
SELECT
  metric_type,
  CASE metric_type
    WHEN 'cpu' THEN round(20 + rand() * 70, 2)
    WHEN 'memory' THEN round(30 + rand() * 60, 2)
    WHEN 'temperature' THEN round(22 + rand() * 12, 2)
    WHEN 'humidity' THEN round(45 + rand() * 40, 2)
    WHEN 'soil_moisture' THEN round(25 + rand() * 60, 2)
    WHEN 'light_intensity' THEN round(100 + rand() * 900, 2)
    WHEN 'pressure' THEN round(990 + rand() * 40, 2)
    WHEN 'request_count' THEN round(rand() * 500, 0)
  END AS value,
  CASE metric_type
    WHEN 'cpu' THEN 'server_a'
    WHEN 'memory' THEN 'server_a'
    WHEN 'temperature' THEN 'iot_lab_1'
    WHEN 'humidity' THEN 'iot_lab_1'
    WHEN 'soil_moisture' THEN 'iot_greenhouse_1'
    WHEN 'light_intensity' THEN 'iot_greenhouse_1'
    WHEN 'pressure' THEN 'iot_barometer_1'
    WHEN 'request_count' THEN 'api_gateway_1'
  END AS source,
  timestampadd(MINUTE, -2 * seq_id, current_timestamp()) AS ts
FROM (
  SELECT explode(array(
    'cpu',
    'memory',
    'temperature',
    'humidity',
    'soil_moisture',
    'light_intensity',
    'pressure',
    'request_count'
  )) AS metric_type
) m
CROSS JOIN (
  SELECT posexplode(sequence(0, 719)) AS (seq_id, seq_val)
) t;

-- Quick sanity checks
SELECT count(*) AS total_rows FROM metrics;
SELECT min(ts) AS min_ts, max(ts) AS max_ts FROM metrics;
SELECT metric_type, count(*) AS rows_per_type FROM metrics GROUP BY metric_type ORDER BY metric_type;
