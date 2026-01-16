-- Migration 003: Add indexes for common query patterns
-- Purpose: Speed up analytics queries
-- Author: mac
-- Date: 2026-01-16

-- Index on timestamp (DESC for recent-first queries)
CREATE INDEX IF NOT EXISTS idx_tile_requests_timestamp
ON tile_requests (timestamp DESC);

-- Index on IP address (for per-user analytics)
CREATE INDEX IF NOT EXISTS idx_tile_requests_ip
ON tile_requests (ip_address);

-- Index on zoom level (for zoom distribution queries)
-- Partial index: only indexes rows where zoom_level is not null
CREATE INDEX IF NOT EXISTS idx_tile_requests_zoom
ON tile_requests (zoom_level)
WHERE zoom_level IS NOT NULL;

-- Index on cache status (for cache performance queries)
CREATE INDEX IF NOT EXISTS idx_tile_requests_cache
ON tile_requests (cache_status)
WHERE cache_status IS NOT NULL;

-- Index on session_id (for session tracking queries)
CREATE INDEX IF NOT EXISTS idx_tile_requests_session
ON tile_requests (session_id)
WHERE session_id IS NOT NULL;

-- Composite index on timestamp + ip_address (for per-user timeseries)
CREATE INDEX IF NOT EXISTS idx_tile_requests_timestamp_ip
ON tile_requests (timestamp DESC, ip_address);

-- Index on status_code (for error rate queries)
CREATE INDEX IF NOT EXISTS idx_tile_requests_status
ON tile_requests (status_code);

-- Composite index on zoom_level + timestamp (for zoom trends over time)
CREATE INDEX IF NOT EXISTS idx_tile_requests_zoom_timestamp
ON tile_requests (zoom_level, timestamp DESC)
WHERE zoom_level IS NOT NULL;
