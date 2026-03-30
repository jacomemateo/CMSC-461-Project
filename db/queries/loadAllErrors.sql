-- Failure: end_time is BEFORE start_time
INSERT INTO reservation (user_id, car_id, parking_spot_id, start_time, end_time)
VALUES (
    (SELECT id FROM user_info LIMIT 1),
    (SELECT id FROM car_info LIMIT 1),
    (SELECT id FROM parking_spot LIMIT 1),
    '2026-05-01 12:00:00',
    '2026-05-01 10:00:00'
);

-- Failure: 'MAT345' already exists in the system
INSERT INTO car_info (owner_id, plate, model, color)
VALUES (
    (SELECT id FROM user_info LIMIT 1),
    'MAT345',
    'Fake Car',
    'Invisible'
);

-- Failure: lot_type is set to 'UNKNOWN'
INSERT INTO lot_info (name, lot_type)
VALUES ('Forbidden Lot', 'UNKNOWN');

-- Failure: amount is over the 50,000 cent limit
INSERT INTO payments (user_id, amount_cents, date)
VALUES (
    (SELECT id FROM user_info LIMIT 1),
    99999,
    NOW()
);

-- Failure: Lot A, Space 1 already exists
INSERT INTO parking_spot (lot_id, space)
VALUES (
    (SELECT id FROM lot_info WHERE name = 'Lot A'),
    1
);

-- Failure: Using a random UUID that is not in the car_info table
INSERT INTO tickets (car_id, parking_spot_id, issue_time, violation_code, is_resolved)
VALUES (
    '00000000-0000-0000-0000-000000000000', 
    (SELECT id FROM parking_spot LIMIT 1),
    NOW(),
    'NO_PERMIT',
    FALSE
);