-- Migration 005: Add retention policy
-- Purpose: Automatically delete data older than 90 days
-- Author: mac
-- Date: 2026-01-16

-- Enable automatic deletion of data older than 90 days
SELECT add_retention_policy('tile_requests', INTERVAL '90 days');

-- What this does:
-- - Automatically drops chunks older than 90 days
-- - Runs as a background job
-- - Frees up disk space
-- - No manual cleanup needed

-- Data lifecycle with our policies:
-- Days 1-7:   Uncompressed, writable (fast inserts/updates)
-- Days 8-90:  Compressed, read-only (10x less space)
-- After 90:   Deleted automatically (free disk space)

-- Check retention policy:
-- SELECT * FROM timescaledb_information.jobs WHERE proc_name = 'policy_retention';
