-- Migration 004: Add compression policy
-- Purpose: Automatically compress data older than 7 days (saves 90% disk space)
-- Author: mac
-- Date: 2026-01-16

-- Enable automatic compression for data older than 7 days
SELECT add_compression_policy('tile_requests', INTERVAL '7 days');

-- What this does:
-- - Compresses chunks older than 7 days automatically
-- - Reduces storage by ~90% (1GB becomes ~100MB)
-- - No performance loss on queries
-- - Compressed data is read-only (can't INSERT/UPDATE)
-- - Decompression happens automatically when queried

-- Check compression status:
-- SELECT * FROM timescaledb_information.compression_settings;
