-- Scenario: Two users attempt to reserve 'Lot A - Space 1' for overlapping times.

-------------------------------------------------------------------------
-- SESSION 1 (User A)
-------------------------------------------------------------------------
BEGIN;

-- Step 1: Check availability and lock the spot for the duration of the transaction
-- This prevents Session 2 from even 'checking' this spot until we are done.
SELECT id, is_occupied 
FROM parking_spot 
WHERE lot_id = (SELECT id FROM lot_info WHERE name = 'Lot A') 
  AND space = 1 
FOR UPDATE;

-- Step 2: Insert the reservation
INSERT INTO reservation (user_id, car_id, parking_spot_id, start_time, end_time)
VALUES (
    (SELECT id FROM user_info WHERE email = 'mateo.jacome@harvard.edu'),
    (SELECT id FROM car_info WHERE plate = 'MAT345'),
    (SELECT id FROM parking_spot WHERE space = 1 AND lot_id = (SELECT id FROM lot_info WHERE name = 'Lot A')),
    '2026-05-01 09:00:00',
    '2026-05-01 12:00:00'
);

-- STOP HERE AND SWITCH TO SESSION 2
-- Step 3: Commit after Session 2 is blocked
COMMIT;


-------------------------------------------------------------------------
-- SESSION 2 (User B)
-------------------------------------------------------------------------
BEGIN;

-- Step 1: Attempt to check the same spot
-- NOTICE: This query will HANG/WAIT because Session 1 holds a FOR UPDATE lock.
SELECT id, is_occupied 
FROM parking_spot 
WHERE lot_id = (SELECT id FROM lot_info WHERE name = 'Lot A') 
  AND space = 1 
FOR UPDATE;

-- Step 2: Once Session 1 commits, this query finally executes.
-- The application logic would check if an overlap exists in 'reservation' table.
-- Since the start/end times overlap with the row Session 1 just inserted, 
-- Session 2 should ROLLBACK.
ROLLBACK;