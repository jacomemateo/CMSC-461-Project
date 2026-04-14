-- 1. Simple: List all cars for a specific user
SELECT plate, model FROM car_info WHERE owner_id = (SELECT id FROM user_info LIMIT 1);

-- 2. Join: List all permits with owner names
SELECT u.last_name, p.permit_type FROM user_info u JOIN permits p ON u.id = p.user_id;

-- 3. Group By: Revenue per violation type
SELECT violation_code, SUM(fine_amount_cents) FROM tickets GROUP BY violation_code;

-- 4. Subquery: Find users with more than 1 car
SELECT email FROM user_info WHERE id IN (SELECT owner_id FROM car_info GROUP BY owner_id HAVING COUNT(*) > 1);

-- 5. Set Operation: Users who have made payments but have no permits
SELECT id FROM user_info EXCEPT SELECT user_id FROM permits;

-- 6. Aggregate: Average fine amount per lot
SELECT l.name, AVG(v.amount_cents) 
FROM lot_info l 
JOIN parking_spot s ON l.id = s.lot_id 
JOIN tickets t ON s.id = t.parking_spot_id
JOIN violations v ON t.violation_code = v.code
GROUP BY l.name;

-- 7. Window Function: Rank users by total payment amount
SELECT email, SUM(amount_cents), RANK() OVER (ORDER BY SUM(amount_cents) DESC) 
FROM user_info u JOIN payments p ON u.id = p.user_id GROUP BY u.email;

-- 8. EXPENSIVE: Heatmap of lot usage (Joins 4 tables + Time math)
-- Logic: Finding spots that were occupied for > 4 hours in the last month
EXPLAIN ANALYZE
SELECT l.name, COUNT(se.id) 
FROM lot_info l
JOIN parking_spot ps ON l.id = ps.lot_id
JOIN sensor_events se ON ps.id = se.parking_spot_id
WHERE se.event_time > NOW() - INTERVAL '30 days'
GROUP BY l.name;

-- 9. EXPENSIVE: Find "Overstayers" (Reservation end_time vs actual departure)
EXPLAIN ANALYZE
SELECT u.email, r.end_time, se.event_time as actual_departure
FROM reservation r
JOIN user_info u ON r.user_id = u.id
JOIN sensor_events se ON r.parking_spot_id = se.parking_spot_id
WHERE se.event_type = 'DEPARTURE' AND se.event_time > r.end_time;

-- 10. EXPENSIVE: Complex violation Audit
EXPLAIN ANALYZE
SELECT c.plate, l.name, t.issue_time
FROM tickets t
JOIN car_info c ON t.car_id = c.id
JOIN parking_spot s ON t.parking_spot_id = s.id
JOIN lot_info l ON s.lot_id = l.id
WHERE t.is_resolved = FALSE AND l.lot_type = 'STAFF';