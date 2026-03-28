CREATE TYPE sensor_event_type AS ENUM ('ARRIVAL', 'DEPARTURE');

CREATE TYPE parking_type_enum AS ENUM ('STUDENT', 'GUEST', 'STAFF', 'UNKNOWN');

CREATE TABLE lot_info (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    name TEXT NOT NULL, -- lot info i.e. "Lot A", "Lot C"
    lot_type parking_type_enum NOT NULL -- what type of lot it is!
        CHECK (parking_type <> 'UNKNOWN')
);

CREATE TABLE user_info (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone TEXT UNIQUE NOT NULL, -- I'm assuming that phone and email
    email TEXT UNIQUE NOT NULL, -- will be validated in the frontend
    parking_type parking_type_enum NOT NULL
        CHECK (parking_type <> 'UNKNOWN')
);

CREATE TABLE car_info (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    owner_id UUID REFERENCES user_info(id),
    plate TEXT UNIQUE NOT NULL,
    model TEXT NOT NULL,
    color TEXT NOT NULL
);

CREATE TABLE parking_spot (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    lot_id UUID REFERENCES lot_info(id),
    space INT NOT NULL,
    UNIQUE (lot_id, space)
);

CREATE TABLE reservation (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id UUID REFERENCES user_info(id),
    car_id UUID REFERENCES car_info(id),
    parking_spot_id UUID REFERENCES parking_spot(id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    CHECK (start_time < end_time)
);

CREATE TABLE sensor_events(
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    parking_spot_id UUID REFERENCES parking_spot(id),
    event_type sensor_event_type NOT NULL,
    event_time TIMESTAMPTZ NOT NULL
);

CREATE TABLE permits(
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id UUID REFERENCES user_info(id),
    permit_type parking_type_enum NOT NULL,
    issued_date TIMESTAMPTZ NOT NULL,
    expiration_date TIMESTAMPTZ NOT NULL,
    CHECK (expiration_date > issued_date)
);

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id UUID REFERENCES user_info(id),
    amount_cents INT NOT NULL
        CHECK (amount_cents > 0 AND amount_cents < 50000),
    date TIMESTAMPTZ NOT NULL
);

-- we're not gonna implement "late fees" because it's too much work!
CREATE TABLE tickets (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    car_id UUID REFERENCES car_info(id),
    parking_spot_id UUID REFERENCES parking_spot(id),
    issue_time TIMESTAMPTZ NOT NULL,
    violation_code TEXT NOT NULL REFERENCES violations(code), -- We get amount from here
    is_resolved BOOLEAN NOT NULL
);

CREATE TABLE violations (
    code TEXT PRIMARY KEY,
    description TEXT NOT NULL,
    amount_cents INT NOT NULL CHECK (amount_cents > 0)
);