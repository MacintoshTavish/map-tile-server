-- Migration 002: Convert tile_requests to TimescaleDB hypertable
-- Purpose: Enable time-series optimizations (partitioning, compression)
-- Author: mac
-- Date: 2026-01-16

-- Convert to hypertable (partitions data by time for faster queries)
SELECT create_hypertable(
    'tile_requests',
    'timestamp',
    if_not_exists => TRUE,
    chunk_time_interval => INTERVAL '1 day'
);

-- This converts tile_requests into a hypertable:
-- - Data is automatically partitioned into 1-day chunks
-- - Queries on recent data only scan relevant chunks
-- - Old chunks can be compressed automatically
-- - Much faster for time-based queries

COMMENT ON TABLE tile_requests IS 'TimescaleDB hypertable storing tile request analytics (partitioned by timestamp)';
