-- Migration 001: Create tile_requests table
-- Purpose: Store all tile request data from nginx access logs
-- Author: mac
-- Date: 2026-01-16

CREATE TABLE IF NOT EXISTS tile_requests (
    -- Primary key
    id BIGSERIAL,

    -- Time information
    timestamp TIMESTAMPTZ NOT NULL,

    -- Request information
    ip_address INET NOT NULL,
    method VARCHAR(10) NOT NULL,
    path TEXT NOT NULL,
    http_version VARCHAR(10),
    status_code INTEGER NOT NULL,

    -- Tile coordinates (extracted from path /tiles/z/x/y.png)
    zoom_level INTEGER,
    tile_x INTEGER,
    tile_y INTEGER,

    -- Geographic coordinates (converted from tile coordinates)
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,

    -- Performance metrics
    response_time_ms INTEGER,
    bytes_sent BIGINT,

    -- Cache information
    cache_status VARCHAR(20), -- HIT, MISS, BYPASS

    -- Session tracking
    session_id UUID,

    -- Client information
    user_agent TEXT,
    referer TEXT,

    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Comments for documentation
COMMENT ON TABLE tile_requests IS 'Stores all tile request analytics from nginx access logs';
COMMENT ON COLUMN tile_requests.timestamp IS 'When the request was made (from nginx log)';
COMMENT ON COLUMN tile_requests.ip_address IS 'Client IP address';
COMMENT ON COLUMN tile_requests.zoom_level IS 'Map zoom level (0-18)';
COMMENT ON COLUMN tile_requests.tile_x IS 'Tile X coordinate';
COMMENT ON COLUMN tile_requests.tile_y IS 'Tile Y coordinate';
COMMENT ON COLUMN tile_requests.latitude IS 'Approximate latitude of tile center';
COMMENT ON COLUMN tile_requests.longitude IS 'Approximate longitude of tile center';
COMMENT ON COLUMN tile_requests.cache_status IS 'nginx cache status: HIT, MISS, or BYPASS';
COMMENT ON COLUMN tile_requests.session_id IS 'Session identifier (groups requests from same user)';
