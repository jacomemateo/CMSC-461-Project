-- DROP TABLES (children first)
DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS permits;
DROP TABLE IF EXISTS sensor_events;
DROP TABLE IF EXISTS reservation;
DROP TABLE IF EXISTS parking_spot;
DROP TABLE IF EXISTS car_info;
DROP TABLE IF EXISTS user_info;
DROP TABLE IF EXISTS lot_info;
DROP TABLE IF EXISTS violations;

-- DROP TYPES (after tables)

DROP TYPE IF EXISTS sensor_event_type;
DROP TYPE IF EXISTS parking_type_enum;