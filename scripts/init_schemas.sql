-- ============================================================
-- Data Warehouse Database Setup
-- MySQL version: 8.0+
-- Purpose:
--   Create logical warehouse layers:
--   - Bronze: raw/staging data
--   - Silver: cleaned/transformed data
--   - Gold: analytics/reporting data
-- ============================================================

CREATE SCHEMA IF NOT EXISTS Bronze;

CREATE SCHEMA IF NOT EXISTS Silver;

CREATE SCHEMA IF NOT EXISTS Gold;
