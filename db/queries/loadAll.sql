-- Insert test data

-- Clean reset of all data
TRUNCATE TABLE tickets, payments, permits, sensor_events, reservation, car_info, parking_spot, user_info, lot_info, violations RESTART IDENTITY CASCADE;

-- 1. Violations (10 rows)
INSERT INTO violations (code, description, amount_cents) VALUES
    ('NO_PERMIT', 'Parking without a valid permit', 5000),
    ('EXPIRED_METER', 'Meter expired', 2500),
    ('INVALID_ZONE', 'Parked in wrong zone', 3000),
    ('OVER_TIME', 'Exceeded allowed parking time', 2000),
    ('BLOCKING', 'Blocking another vehicle or lane', 4000),
    ('FIRE_HYDRANT', 'Parked within 15ft of hydrant', 10000),
    ('HANDICAP_ONLY', 'Unauthorized parking in accessible spot', 25000),
    ('SIDEWALK_BLOCK', 'Vehicle blocking pedestrian walkway', 4500),
    ('WRONG_WAY', 'Parked against the flow of traffic', 3500),
    ('ABANDONED', 'Vehicle left for over 72 hours', 15000);

-- 2. Lot Info (10 rows)
INSERT INTO lot_info (name, lot_type) VALUES
    ('Lot A', 'STUDENT'), ('Lot B', 'STAFF'), ('Lot C', 'GUEST'),
    ('Lot D', 'STUDENT'), ('Lot E', 'STAFF'), ('Lot F', 'GUEST'),
    ('Lot G', 'STUDENT'), ('Lot H', 'STAFF'), ('Lot I', 'GUEST'),
    ('Lot J', 'STUDENT');

-- 3. User Info (10 rows)
INSERT INTO user_info (first_name, last_name, phone, email, parking_type) VALUES
    ('Ian', 'Wright', '123-456-7890', 'ian.wright@nyu.edu', 'STUDENT'),
    ('Jane', 'Smith', '234-567-8901', 'jane.smith@mit.edu', 'STAFF'),
    ('Mateo', 'Jacome', '345-678-9012', 'mateo.jacome@harvard.edu', 'STUDENT'),
    ('Isaac', 'Samuel', '456-789-0123', 'isaac.samuel@gmail.com', 'GUEST'),
    ('Jason', 'Chen', '567-890-1234', 'jason.chen@mit.edu', 'STUDENT'),
    ('Lawrence', 'Kemp', '678-901-2345', 'lawrence.kemp@mit.edu', 'STAFF'),
    ('James', 'Taylor', '789-012-3456', 'james.taylor@example.com', 'GUEST'),
    ('Sophia', 'Anderson', '890-123-4567', 'sophia.anderson@example.com', 'STUDENT'),
    ('William', 'Thomas', '901-234-5678', 'william.thomas@example.com', 'STAFF'),
    ('Ava', 'Martinez', '012-345-6789', 'ava.martinez@example.com', 'GUEST');

-- 4. Car Info (10 rows)
INSERT INTO car_info (owner_id, plate, model, color) VALUES
    ((SELECT id FROM user_info WHERE email = 'ian.wright@nyu.edu'), '2EWX5D', 'Toyota Camry', 'Blue'),
    ((SELECT id FROM user_info WHERE email = 'jane.smith@mit.edu'), '3EWP5D', 'Honda Accord', 'Grey'),
    ((SELECT id FROM user_info WHERE email = 'mateo.jacome@harvard.edu'), 'MAT345', 'Honda Accord', 'Black'),
    ((SELECT id FROM user_info WHERE email = 'isaac.samuel@gmail.com'), 'ISA456', 'Toyota Corolla', 'White'),
    ((SELECT id FROM user_info WHERE email = 'jason.chen@mit.edu'), 'JAS567', 'Tesla Model 3', 'Red'),
    ((SELECT id FROM user_info WHERE email = 'lawrence.kemp@mit.edu'), 'LAW678', 'Ford Explorer', 'Gray'),
    ((SELECT id FROM user_info WHERE email = 'james.taylor@example.com'), 'JAM789', 'Chevrolet Malibu', 'Blue'),
    ((SELECT id FROM user_info WHERE email = 'sophia.anderson@example.com'), 'SOP890', 'Hyundai Elantra', 'Silver'),
    ((SELECT id FROM user_info WHERE email = 'william.thomas@example.com'), 'WIL901', 'BMW 3 Series', 'Black'),
    ((SELECT id FROM user_info WHERE email = 'ava.martinez@example.com'), 'AVA012', 'Nissan Altima', 'White');

-- 5. Parking Spots (11 rows)
INSERT INTO parking_spot (lot_id, space) VALUES
    ((SELECT id FROM lot_info WHERE name = 'Lot A'), 1),
    ((SELECT id FROM lot_info WHERE name = 'Lot A'), 2),
    ((SELECT id FROM lot_info WHERE name = 'Lot B'), 1),
    ((SELECT id FROM lot_info WHERE name = 'Lot B'), 2),
    ((SELECT id FROM lot_info WHERE name = 'Lot C'), 1),
    ((SELECT id FROM lot_info WHERE name = 'Lot C'), 2),
    ((SELECT id FROM lot_info WHERE name = 'Lot D'), 1),
    ((SELECT id FROM lot_info WHERE name = 'Lot E'), 1),
    ((SELECT id FROM lot_info WHERE name = 'Lot F'), 1),
    ((SELECT id FROM lot_info WHERE name = 'Lot G'), 1),
    ((SELECT id FROM lot_info WHERE name = 'Lot H'), 1);

-- 6. Reservations (10 rows)
-- Uses multiple users and spots to demonstrate volume
INSERT INTO reservation (user_id, car_id, parking_spot_id, start_time, end_time) VALUES
    ((SELECT id FROM user_info WHERE email = 'mateo.jacome@harvard.edu'), (SELECT id FROM car_info WHERE plate = 'MAT345'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 0), '2026-03-26 09:00:00', '2026-03-26 12:00:00'),
    ((SELECT id FROM user_info WHERE email = 'jason.chen@mit.edu'), (SELECT id FROM car_info WHERE plate = 'JAS567'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 1), '2026-03-26 10:00:00', '2026-03-26 13:00:00'),
    ((SELECT id FROM user_info WHERE email = 'sophia.anderson@example.com'), (SELECT id FROM car_info WHERE plate = 'SOP890'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 2), '2026-03-26 08:30:00', '2026-03-26 11:30:00'),
    ((SELECT id FROM user_info WHERE email = 'isaac.samuel@gmail.com'), (SELECT id FROM car_info WHERE plate = 'ISA456'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 3), '2026-03-26 14:00:00', '2026-03-26 16:00:00'),
    ((SELECT id FROM user_info WHERE email = 'ava.martinez@example.com'), (SELECT id FROM car_info WHERE plate = 'AVA012'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 4), '2026-03-27 09:00:00', '2026-03-27 17:00:00'),
    ((SELECT id FROM user_info WHERE email = 'james.taylor@example.com'), (SELECT id FROM car_info WHERE plate = 'JAM789'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 5), '2026-03-27 10:00:00', '2026-03-27 12:00:00'),
    ((SELECT id FROM user_info WHERE email = 'ian.wright@nyu.edu'), (SELECT id FROM car_info WHERE plate = '2EWX5D'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 6), '2026-03-28 08:00:00', '2026-03-28 10:00:00'),
    ((SELECT id FROM user_info WHERE email = 'jane.smith@mit.edu'), (SELECT id FROM car_info WHERE plate = '3EWP5D'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 7), '2026-03-28 11:00:00', '2026-03-28 13:00:00'),
    ((SELECT id FROM user_info WHERE email = 'william.thomas@example.com'), (SELECT id FROM car_info WHERE plate = 'WIL901'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 8), '2026-03-29 09:00:00', '2026-03-29 11:00:00'),
    ((SELECT id FROM user_info WHERE email = 'lawrence.kemp@mit.edu'), (SELECT id FROM car_info WHERE plate = 'LAW678'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 9), '2026-03-29 13:00:00', '2026-03-29 15:00:00');

-- 7. Sensor Events (10 rows)
INSERT INTO sensor_events (parking_spot_id, event_type, event_time) VALUES
    ((SELECT id FROM parking_spot LIMIT 1 OFFSET 0), 'ARRIVAL', '2026-03-26 09:05:00'),
    ((SELECT id FROM parking_spot LIMIT 1 OFFSET 0), 'DEPARTURE', '2026-03-26 11:55:00'),
    ((SELECT id FROM parking_spot LIMIT 1 OFFSET 1), 'ARRIVAL', '2026-03-26 10:05:00'),
    ((SELECT id FROM parking_spot LIMIT 1 OFFSET 2), 'ARRIVAL', '2026-03-26 08:35:00'),
    ((SELECT id FROM parking_spot LIMIT 1 OFFSET 3), 'ARRIVAL', '2026-03-26 14:10:00'),
    ((SELECT id FROM parking_spot LIMIT 1 OFFSET 4), 'ARRIVAL', '2026-03-27 09:02:00'),
    ((SELECT id FROM parking_spot LIMIT 1 OFFSET 5), 'ARRIVAL', '2026-03-27 10:15:00'),
    ((SELECT id FROM parking_spot LIMIT 1 OFFSET 6), 'ARRIVAL', '2026-03-28 08:05:00'),
    ((SELECT id FROM parking_spot LIMIT 1 OFFSET 7), 'ARRIVAL', '2026-03-28 11:10:00'),
    ((SELECT id FROM parking_spot LIMIT 1 OFFSET 8), 'ARRIVAL', '2026-03-29 09:05:00');

-- 8. Permits (10 rows - including active and expired)
INSERT INTO permits (user_id, permit_type, issued_date, expiration_date) VALUES
    ((SELECT id FROM user_info WHERE email = 'mateo.jacome@harvard.edu'), 'STUDENT', '2026-03-01', '2027-02-28'),
    ((SELECT id FROM user_info WHERE email = 'jason.chen@mit.edu'), 'STUDENT', '2026-03-01', '2027-02-28'),
    ((SELECT id FROM user_info WHERE email = 'jane.smith@mit.edu'), 'STAFF', '2026-03-01', '2027-02-28'),
    ((SELECT id FROM user_info WHERE email = 'ian.wright@nyu.edu'), 'STUDENT', '2024-01-01', '2024-12-31'), -- EXPIRED
    ((SELECT id FROM user_info WHERE email = 'lawrence.kemp@mit.edu'), 'STAFF', '2026-01-01', '2026-12-31'),
    ((SELECT id FROM user_info WHERE email = 'sophia.anderson@example.com'), 'STUDENT', '2026-01-01', '2026-12-31'),
    ((SELECT id FROM user_info WHERE email = 'william.thomas@example.com'), 'STAFF', '2026-01-01', '2026-12-31'),
    ((SELECT id FROM user_info WHERE email = 'ava.martinez@example.com'), 'GUEST', '2026-03-25', '2026-03-26'), -- EXPIRED
    ((SELECT id FROM user_info WHERE email = 'james.taylor@example.com'), 'GUEST', '2026-03-30', '2026-03-31'),
    ((SELECT id FROM user_info WHERE email = 'isaac.samuel@gmail.com'), 'GUEST', '2026-03-30', '2026-03-31');

-- 9. Payments (10 rows)
INSERT INTO payments (user_id, amount_cents, date) VALUES
    ((SELECT id FROM user_info WHERE email = 'mateo.jacome@harvard.edu'), 1500, '2026-03-20'),
    ((SELECT id FROM user_info WHERE email = 'isaac.samuel@gmail.com'), 800, '2026-03-21'),
    ((SELECT id FROM user_info WHERE email = 'jason.chen@mit.edu'), 2000, '2026-03-22'),
    ((SELECT id FROM user_info WHERE email = 'lawrence.kemp@mit.edu'), 2500, '2026-03-22'),
    ((SELECT id FROM user_info WHERE email = 'james.taylor@example.com'), 1200, '2026-03-23'),
    ((SELECT id FROM user_info WHERE email = 'sophia.anderson@example.com'), 1800, '2026-03-24'),
    ((SELECT id FROM user_info WHERE email = 'william.thomas@example.com'), 2200, '2026-03-24'),
    ((SELECT id FROM user_info WHERE email = 'ava.martinez@example.com'), 900, '2026-03-25'),
    ((SELECT id FROM user_info WHERE email = 'ian.wright@nyu.edu'), 5000, '2026-03-26'),
    ((SELECT id FROM user_info WHERE email = 'jane.smith@mit.edu'), 3000, '2026-03-27');

-- 10. Tickets (10 rows)
INSERT INTO tickets (car_id, parking_spot_id, issue_time, violation_code, is_resolved) VALUES
    ((SELECT id FROM car_info WHERE plate = 'MAT345'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 0), '2026-03-27 10:00:00', 'NO_PERMIT', FALSE),
    ((SELECT id FROM car_info WHERE plate = 'ISA456'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 1), '2026-03-27 11:30:00', 'EXPIRED_METER', TRUE),
    ((SELECT id FROM car_info WHERE plate = 'WIL901'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 2), '2026-03-27 09:15:00', 'INVALID_ZONE', FALSE),
    ((SELECT id FROM car_info WHERE plate = '2EWX5D'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 3), '2026-03-27 14:00:00', 'OVER_TIME', FALSE),
    ((SELECT id FROM car_info WHERE plate = '3EWP5D'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 4), '2026-03-28 08:30:00', 'BLOCKING', TRUE),
    ((SELECT id FROM car_info WHERE plate = 'LAW678'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 5), '2026-03-28 10:00:00', 'FIRE_HYDRANT', FALSE),
    ((SELECT id FROM car_info WHERE plate = 'JAM789'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 6), '2026-03-28 12:00:00', 'HANDICAP_ONLY', FALSE),
    ((SELECT id FROM car_info WHERE plate = 'SOP890'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 7), '2026-03-29 09:00:00', 'SIDEWALK_BLOCK', TRUE),
    ((SELECT id FROM car_info WHERE plate = 'AVA012'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 8), '2026-03-29 11:00:00', 'WRONG_WAY', FALSE),
    ((SELECT id FROM car_info WHERE plate = 'MAT345'), (SELECT id FROM parking_spot LIMIT 1 OFFSET 9), '2026-03-29 13:00:00', 'ABANDONED', FALSE);