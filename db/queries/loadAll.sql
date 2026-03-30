TRUNCATE TABLE
    tickets,
    payments,
    permits,
    sensor_events,
    reservation,
    car_info,
    parking_spot,
    user_info,
    lot_info,
    violations
RESTART IDENTITY
CASCADE;

INSERT INTO violations (code, description, amount_cents)
VALUES
    ('NO_PERMIT', 'Parking without a valid permit', 5000),
    ('EXPIRED_METER', 'Meter expired', 2500),
    ('INVALID_ZONE', 'Parked in wrong zone', 3000),
    ('OVER_TIME', 'Exceeded allowed parking time', 2000),
    ('BLOCKING', 'Blocking another vehicle or lane', 4000);

INSERT INTO lot_info (name, lot_type)
VALUES
    ('Lot A', 'STUDENT'),
    ('Lot B', 'STAFF'),
    ('Lot D', 'STUDENT'),
    ('Lot E', 'STAFF'),
    ('Lot F', 'GUEST'),
    ('Lot G', 'STUDENT'),
    ('Lot H', 'STAFF'),
    ('Lot I', 'GUEST'),
    ('Lot J', 'STUDENT'),
    ('Lot C', 'GUEST');

INSERT INTO user_info (first_name, last_name, phone, email, parking_type)
VALUES
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

INSERT INTO CAR_INFO (owner_id, plate, model, color)
VALUES
    ((
            SELECT
                id
            FROM
                user_info
            WHERE
                email = 'ian.wright@nyu.edu'), '2EWX5D', 'Toyota Camry', 'Blue'), ((
        SELECT
            id
        FROM user_info
        WHERE
            email = 'jane.smith@mit.edu'), '3EWP5D', 'Honda Accord', 'Grey'), ((
        SELECT
            id
        FROM user_info
    WHERE
        email = 'mateo.jacome@harvard.edu'), 'MAT345', 'Honda Accord', 'Black'), ((
        SELECT
            id
        FROM user_info
    WHERE
        email = 'isaac.samuel@gmail.com'), 'ISA456', 'Toyota Corolla', 'White'), ((
        SELECT
            id
        FROM user_info
    WHERE
        email = 'jason.chen@mit.edu'), 'JAS567', 'Tesla Model 3', 'Red'), ((
        SELECT
            id
        FROM user_info
    WHERE
        email = 'lawrence.kemp@mit.edu'), 'LAW678', 'Ford Explorer', 'Gray'), ((
        SELECT
            id
        FROM user_info
    WHERE
        email = 'james.taylor@example.com'), 'JAM789', 'Chevrolet Malibu', 'Blue'), ((
        SELECT
            id
        FROM user_info
    WHERE
        email = 'sophia.anderson@example.com'), 'SOP890', 'Hyundai Elantra', 'Silver'), ((
        SELECT
            id
        FROM user_info
    WHERE
        email = 'william.thomas@example.com'), 'WIL901', 'BMW 3 Series', 'Black'), ((
        SELECT
            id
        FROM user_info
    WHERE
        email = 'ava.martinez@example.com'), 'AVA012', 'Nissan Altima', 'White');

INSERT INTO parking_spot (lot_id, space)
VALUES
    ((
            SELECT
                id
            FROM
                lot_info
            WHERE
                name = 'Lot A'), 1), ((
        SELECT
            id
        FROM lot_info
        WHERE
            name = 'Lot A'), 2), ((
        SELECT
            id
        FROM lot_info
    WHERE
        name = 'Lot A'), 3), ((
        SELECT
            id
        FROM lot_info
    WHERE
        name = 'Lot B'), 1), ((
        SELECT
            id
        FROM lot_info
    WHERE
        name = 'Lot B'), 2), ((
        SELECT
            id
        FROM lot_info
    WHERE
        name = 'Lot C'), 1), ((
        SELECT
            id
        FROM lot_info
    WHERE
        name = 'Lot C'), 2), ((
        SELECT
            id
        FROM lot_info
    WHERE
        name = 'Lot C'), 3), ((
        SELECT
            id
        FROM lot_info
    WHERE
        name = 'Lot C'), 4), ((
        SELECT
            id
        FROM lot_info
    WHERE
        name = 'Lot D'), 1), ((
        SELECT
            id
        FROM lot_info
    WHERE
        name = 'Lot D'), 2);

INSERT INTO reservation (user_id, car_id, parking_spot_id, start_time, end_time)
VALUES
    ((
            SELECT
                id
            FROM
                user_info
            WHERE
                email = 'mateo.jacome@harvard.edu'), (
                SELECT
                    id
                FROM
                    car_info
                WHERE
                    plate = 'MAT345'), (
                    SELECT
                        ps.id
                    FROM
                        parking_spot ps
                        JOIN lot_info l ON ps.lot_id = l.id
                    WHERE
                        l.name = 'Lot A'
                        AND ps.space = 1),
                    '2026-03-26 09:00:00-04',
                    '2026-03-26 12:00:00-04'),
            ((
                SELECT
                    id
                FROM user_info
            WHERE
                email = 'jason.chen@mit.edu'), (
            SELECT
                id
            FROM car_info
        WHERE
            plate = 'JAS567'), (
        SELECT
            ps.id
        FROM parking_spot ps
        JOIN lot_info l ON ps.lot_id = l.id
    WHERE
        l.name = 'Lot B'
        AND ps.space = 1), '2026-03-26 10:00:00-04', '2026-03-26 13:00:00-04'),
        ((
            SELECT
                id
            FROM user_info
        WHERE
            email = 'sophia.anderson@example.com'), (
        SELECT
            id
        FROM car_info
    WHERE
        plate = 'SOP890'), (
    SELECT
        ps.id
    FROM parking_spot ps
    JOIN lot_info l ON ps.lot_id = l.id
WHERE
    l.name = 'Lot C'
    AND ps.space = 2), '2026-03-26 08:30:00-04', '2026-03-26 11:30:00-04');

INSERT INTO sensor_events (parking_spot_id, event_type, event_time)
VALUES
    ((
            SELECT
                ps.id
            FROM
                parking_spot ps
                JOIN lot_info l ON ps.lot_id = l.id
            WHERE
                l.name = 'Lot A'
                AND ps.space = 1),
            'ARRIVAL',
            '2026-03-26 09:05:00-04'),
    ((
        SELECT
            ps.id
        FROM parking_spot ps
        JOIN lot_info l ON ps.lot_id = l.id
        WHERE
            l.name = 'Lot B'
            AND ps.space = 1), 'ARRIVAL', '2026-03-26 10:05:00-04'),
    ((
        SELECT
            ps.id
        FROM parking_spot ps
        JOIN lot_info l ON ps.lot_id = l.id
    WHERE
        l.name = 'Lot C'
        AND ps.space = 2), 'ARRIVAL', '2026-03-26 08:35:00-04');

INSERT INTO permits (user_id, permit_type, issued_date, expiration_date)
VALUES
    ((
            SELECT
                id
            FROM
                user_info
            WHERE
                email = 'mateo.jacome@harvard.edu'), 'STUDENT', '2026-03-01', '2027-02-28'), ((
        SELECT
            id
        FROM user_info
        WHERE
            email = 'jason.chen@mit.edu'), 'STAFF', '2026-03-01', '2027-02-28'), ((
        SELECT
            id
        FROM user_info
    WHERE
        email = 'sophia.anderson@example.com'), 'STUDENT', '2026-03-01', '2027-02-28');

INSERT INTO payments (user_id, amount_cents, date)
VALUES
    ((
            SELECT
                id
            FROM
                user_info
            WHERE
                email = 'mateo.jacome@harvard.edu'), 1500, '2026-03-20 10:15:00-04'), ((
        SELECT
            id
        FROM user_info
        WHERE
            email = 'isaac.samuel@gmail.com'), 800, '2026-03-21 12:30:00-04'), ((
        SELECT
            id
        FROM user_info
    WHERE
        email = 'jason.chen@mit.edu'), 2000, '2026-03-22 09:45:00-04'), ((
        SELECT
            id
        FROM user_info
    WHERE
        email = 'lawrence.kemp@mit.edu'), 2500, '2026-03-22 14:00:00-04'), ((
        SELECT
            id
        FROM user_info
    WHERE
        email = 'james.taylor@example.com'), 1200, '2026-03-23 11:20:00-04'), ((
        SELECT
            id
        FROM user_info
    WHERE
        email = 'sophia.anderson@example.com'), 1800, '2026-03-24 08:10:00-04'), ((
        SELECT
            id
        FROM user_info
    WHERE
        email = 'william.thomas@example.com'), 2200, '2026-03-24 16:45:00-04'), ((
        SELECT
            id
        FROM user_info
    WHERE
        email = 'ava.martinez@example.com'), 900, '2026-03-25 13:05:00-04');

INSERT INTO tickets (car_id, parking_spot_id, issue_time, violation_code, is_resolved)
VALUES
    ((
            SELECT
                id
            FROM
                car_info
            WHERE
                plate = 'MAT345'), (
                SELECT
                    ps.id
                FROM
                    parking_spot ps
                    JOIN lot_info l ON ps.lot_id = l.id
                WHERE
                    l.name = 'Lot A'
                    AND ps.space = 1),
                '2026-03-27 10:00:00-04',
                'NO_PERMIT',
                FALSE),
        ((
            SELECT
                id
            FROM car_info
        WHERE
            plate = 'ISA456'), (
        SELECT
            ps.id
        FROM parking_spot ps
        JOIN lot_info l ON ps.lot_id = l.id
    WHERE
        l.name = 'Lot C'
        AND ps.space = 2), '2026-03-27 11:30:00-04', 'EXPIRED_METER', TRUE),
    ((
        SELECT
            id
        FROM car_info
    WHERE
        plate = 'WIL901'), (
    SELECT
        ps.id
    FROM parking_spot ps
    JOIN lot_info l ON ps.lot_id = l.id
WHERE
    l.name = 'Lot B'
    AND ps.space = 2), '2026-03-27 09:15:00-04', 'INVALID_ZONE', FALSE);

