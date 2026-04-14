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
