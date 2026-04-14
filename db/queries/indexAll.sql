-- 1. Unique index on Email (already handled by UNIQUE constraint, but good for explicit practice)
CREATE INDEX idx_user_email ON user_info(email);

-- 2. Index on Foreign Keys (Crucial for joins)
CREATE INDEX idx_car_owner ON car_info(owner_id);

-- 3. Composite Index: Lot and Occupancy (For the 'Availability' view)
CREATE INDEX idx_spot_lot_occupancy ON parking_spot(lot_id, is_occupied);

-- 4. B-Tree on timestamps (For the 'Heatmap' query)
CREATE INDEX idx_sensor_time ON sensor_events(event_time);

-- 5. Partial Index: Only track unresolved tickets
CREATE INDEX idx_unresolved_tickets ON tickets(issue_time) WHERE is_resolved = FALSE;