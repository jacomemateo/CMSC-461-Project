-- MORE PARKING SPOTS
INSERT INTO parking_spot (lot_id, space)
VALUES
  ((
      SELECT
        id
      FROM
        lot_info
      WHERE
        name = 'Lot D'), 3), ((
    SELECT
      id
    FROM lot_info
    WHERE
      name = 'Lot D'), 4), ((
    SELECT
      id
    FROM lot_info
  WHERE
    name = 'Lot E'), 1), ((
    SELECT
      id
    FROM lot_info
  WHERE
    name = 'Lot E'), 2), ((
    SELECT
      id
    FROM lot_info
  WHERE
    name = 'Lot F'), 1), ((
    SELECT
      id
    FROM lot_info
  WHERE
    name = 'Lot G'), 1), ((
    SELECT
      id
    FROM lot_info
  WHERE
    name = 'Lot H'), 1), ((
    SELECT
      id
    FROM lot_info
  WHERE
    name = 'Lot I'), 1), ((
    SELECT
      id
    FROM lot_info
  WHERE
    name = 'Lot J'), 1);

-- MORE RESERVATIONS (overlaps + different lots)
INSERT INTO reservation (user_id, car_id, parking_spot_id, start_time, end_time)
VALUES
  ((
      SELECT
        id
      FROM
        user_info
      WHERE
        email = 'ian.wright@nyu.edu'), (
        SELECT
          id
        FROM
          car_info
        WHERE
          plate = '2EWX5D'), (
          SELECT
            ps.id
          FROM
            parking_spot ps
            JOIN lot_info l ON ps.lot_id = l.id
          WHERE
            l.name = 'Lot D'
            AND ps.space = 3),
          '2026-03-26 11:00:00-04',
          '2026-03-26 14:00:00-04'),
      ((
        SELECT
          id
        FROM user_info
      WHERE
        email = 'ava.martinez@example.com'), (
      SELECT
        id
      FROM car_info
    WHERE
      plate = 'AVA012'), (
    SELECT
      ps.id
    FROM parking_spot ps
    JOIN lot_info l ON ps.lot_id = l.id
  WHERE
    l.name = 'Lot E'
    AND ps.space = 1), '2026-03-26 09:30:00-04', '2026-03-26 11:00:00-04'),
    ((
      SELECT
        id
      FROM user_info
    WHERE
      email = 'william.thomas@example.com'), (
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
  l.name = 'Lot F'
  AND ps.space = 1), '2026-03-26 13:00:00-04', '2026-03-26 16:00:00-04');

-- SENSOR EVENTS (ARRIVAL + DEPARTURE)
INSERT INTO sensor_events (parking_spot_id, event_type, event_time)
VALUES
  -- departures for earlier arrivals
  ((
      SELECT
        ps.id
      FROM
        parking_spot ps
        JOIN lot_info l ON ps.lot_id = l.id
      WHERE
        l.name = 'Lot A'
        AND ps.space = 1),
      'DEPARTURE',
      '2026-03-26 11:55:00-04'),
  ((
    SELECT
      ps.id
    FROM parking_spot ps
    JOIN lot_info l ON ps.lot_id = l.id
    WHERE
      l.name = 'Lot B'
      AND ps.space = 1), 'DEPARTURE', '2026-03-26 12:50:00-04'),
  -- new arrivals
  ((
    SELECT
      ps.id
    FROM parking_spot ps
    JOIN lot_info l ON ps.lot_id = l.id
  WHERE
    l.name = 'Lot D'
    AND ps.space = 3), 'ARRIVAL', '2026-03-26 11:05:00-04'),
  ((
    SELECT
      ps.id
    FROM parking_spot ps
    JOIN lot_info l ON ps.lot_id = l.id
  WHERE
    l.name = 'Lot E'
    AND ps.space = 1), 'ARRIVAL', '2026-03-26 09:35:00-04');

-- MORE PERMITS (coverage for others)
INSERT INTO permits (user_id, permit_type, issued_date, expiration_date)
VALUES
  ((
      SELECT
        id
      FROM
        user_info
      WHERE
        email = 'ian.wright@nyu.edu'), 'STUDENT', '2026-01-01', '2026-12-31'), ((
    SELECT
      id
    FROM user_info
    WHERE
      email = 'william.thomas@example.com'), 'STAFF', '2026-01-01', '2026-12-31');

-- MORE PAYMENTS (variety)
INSERT INTO payments (user_id, amount_cents, date)
VALUES
  ((
      SELECT
        id
      FROM
        user_info
      WHERE
        email = 'ian.wright@nyu.edu'), 1000, '2026-03-26 10:00:00-04'), ((
    SELECT
      id
    FROM user_info
    WHERE
      email = 'ava.martinez@example.com'), 700, '2026-03-26 11:10:00-04'), ((
    SELECT
      id
    FROM user_info
  WHERE
    email = 'jane.smith@mit.edu'), 3000, '2026-03-27 09:00:00-04');

-- MORE TICKETS (different violations + states)
INSERT INTO tickets (car_id, parking_spot_id, issue_time, violation_code, is_resolved)
VALUES
  ((
      SELECT
        id
      FROM
        car_info
      WHERE
        plate = 'JAS567'), (
        SELECT
          ps.id
        FROM
          parking_spot ps
          JOIN lot_info l ON ps.lot_id = l.id
        WHERE
          l.name = 'Lot B'
          AND ps.space = 1),
        '2026-03-27 13:30:00-04',
        'OVER_TIME',
        FALSE),
    ((
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
    AND ps.space = 3), '2026-03-27 08:00:00-04', 'NO_PERMIT', TRUE),
  ((
    SELECT
      id
    FROM car_info
  WHERE
    plate = 'LAW678'), (
  SELECT
    ps.id
  FROM parking_spot ps
  JOIN lot_info l ON ps.lot_id = l.id
WHERE
  l.name = 'Lot E'
  AND ps.space = 2), '2026-03-27 15:45:00-04', 'BLOCKING', FALSE);
