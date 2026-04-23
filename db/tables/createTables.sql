-- Create all tables
CREATE TYPE sensor_event_type AS ENUM (
  'ARRIVAL',
  'DEPARTURE'
);

CREATE TYPE parking_type_enum AS ENUM (
  'STUDENT',
  'GUEST',
  'STAFF',
  'UNKNOWN'
);

CREATE TABLE lot_info (
  id uuid PRIMARY KEY DEFAULT uuidv7 (),
  name text NOT NULL, -- lot info i.e. "Lot A", "Lot C"
  lot_type parking_type_enum NOT NULL -- what type of lot it is!
  CHECK (lot_type <> 'UNKNOWN')
);

CREATE TABLE user_info (
  id uuid PRIMARY KEY DEFAULT uuidv7 (),
  first_name text NOT NULL,
  last_name text NOT NULL,
  phone text UNIQUE NOT NULL, -- I'm assuming that phone and email
  email text UNIQUE NOT NULL, -- will be validated in the frontend
  parking_type parking_type_enum NOT NULL CHECK (parking_type <> 'UNKNOWN')
);

CREATE TABLE car_info (
  id uuid PRIMARY KEY DEFAULT uuidv7 (),
  owner_id uuid REFERENCES user_info (id),
  plate text UNIQUE NOT NULL,
  model text NOT NULL,
  color text NOT NULL
);

CREATE TABLE parking_spot (
  id uuid PRIMARY KEY DEFAULT uuidv7 (),
  lot_id uuid REFERENCES lot_info (id),
  space int NOT NULL,
  is_occupied boolean NOT NULL DEFAULT FALSE,
  UNIQUE (lot_id, space)
);

CREATE TABLE reservation (
  id uuid PRIMARY KEY DEFAULT uuidv7 (),
  user_id uuid REFERENCES user_info (id),
  car_id uuid REFERENCES car_info (id),
  parking_spot_id uuid REFERENCES parking_spot (id),
  start_time timestamptz NOT NULL,
  end_time timestamptz NOT NULL,
  CHECK (start_time < end_time)
);

CREATE TABLE sensor_events (
  id uuid PRIMARY KEY DEFAULT uuidv7 (),
  parking_spot_id uuid REFERENCES parking_spot (id),
  event_type sensor_event_type NOT NULL,
  event_time timestamptz NOT NULL
);

CREATE TABLE permits (
  id uuid PRIMARY KEY DEFAULT uuidv7 (),
  user_id uuid REFERENCES user_info (id),
  permit_type parking_type_enum NOT NULL,
  issued_date timestamptz NOT NULL,
  expiration_date timestamptz NOT NULL,
  CHECK (expiration_date > issued_date)
);

CREATE TABLE payments (
  id uuid PRIMARY KEY DEFAULT uuidv7 (),
  user_id uuid REFERENCES user_info (id),
  amount_cents int NOT NULL CHECK (amount_cents > 0 AND amount_cents < 50000),
  date timestamptz NOT NULL
);

CREATE TABLE violations (
  code text PRIMARY KEY,
  description text NOT NULL,
  amount_cents int NOT NULL CHECK (amount_cents > 0)
);

-- we're not gonna implement "late fees" because it's too much work!
CREATE TABLE tickets (
  id uuid PRIMARY KEY DEFAULT uuidv7 (),
  car_id uuid REFERENCES car_info (id),
  parking_spot_id uuid REFERENCES parking_spot (id),
  issue_time timestamptz NOT NULL,
  violation_code text NOT NULL REFERENCES violations (code), -- We get amount from here
  is_resolved boolean NOT NULL
);

-- view to get CurrentActivePermits
CREATE VIEW view_active_permits AS
SELECT u.first_name, u.last_name, u.email, p.permit_type, p.expiration_date
FROM user_info u
JOIN permits p ON u.id = p.user_id
WHERE p.expiration_date > NOW();

-- view to get CurrentLotAvailability
CREATE VIEW view_lot_availability AS
SELECT l.name, l.lot_type, 
       COUNT(s.id) FILTER (WHERE s.is_occupied = FALSE) AS available_spots,
       COUNT(s.id) AS total_spots
FROM lot_info l
JOIN parking_spot s ON l.id = s.lot_id
GROUP BY l.id, l.name, l.lot_type;

-- 1. Function: Permit Issuance Eligibility
-- Checks if a student is trying to buy a STAFF permit (Business Rule)
CREATE OR REPLACE FUNCTION issue_permit(p_user_id UUID, p_type parking_type_enum) 
RETURNS VOID AS $$
DECLARE
    user_role parking_type_enum;
BEGIN
    SELECT parking_type INTO user_role FROM user_info WHERE id = p_user_id;
    
    IF user_role = 'STUDENT' AND p_type = 'STAFF' THEN
        RAISE EXCEPTION 'Eligibility Error: Students cannot hold Staff permits.';
    END IF;

    INSERT INTO permits (user_id, permit_type, issued_date, expiration_date)
    VALUES (p_user_id, p_type, NOW(), NOW() + INTERVAL '1 year');
END;
$$ LANGUAGE plpgsql;

-- 2. Trigger: Update Spot Occupancy on Sensor Event
CREATE OR REPLACE FUNCTION fn_update_occupancy()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE parking_spot 
    SET is_occupied = (NEW.event_type = 'ARRIVAL')
    WHERE id = NEW.parking_spot_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sensor_occupancy
AFTER INSERT ON sensor_events
FOR EACH ROW EXECUTE FUNCTION fn_update_occupancy();

-- 3. Stored Procedure: Auto-Ticketing
-- Scans for cars parked in spots where they don't have a reservation or permit
CREATE OR REPLACE PROCEDURE pr_generate_tickets() AS $$
BEGIN
    INSERT INTO tickets (car_id, parking_spot_id, issue_time, violation_code, is_resolved)
    SELECT 
        r.car_id, 
        s.id, 
        NOW(), 
        'NO_PERMIT', 
        FALSE
    FROM parking_spot s
    -- Link the spot to an active reservation to find the specific car
    JOIN reservation r ON s.id = r.parking_spot_id 
    JOIN car_info c ON r.car_id = c.id
    WHERE s.is_occupied = TRUE 
    -- Check if the owner of that specific car lacks a valid permit
    AND NOT EXISTS (
        SELECT 1 
        FROM permits p 
        WHERE p.user_id = c.owner_id 
          AND p.expiration_date > NOW()
    );
END;
$$ LANGUAGE plpgsql;