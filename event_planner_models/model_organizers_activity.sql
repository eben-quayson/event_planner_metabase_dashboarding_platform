-- Purpose: Aggregate organizer activity including total events and capacity.
SELECT
    u.id AS organizer_id,
    u.name AS organizer_name,
    u.email AS organizer_email,
    r.name AS role_name,
    COUNT(e.id) AS total_events,
    COALESCE(SUM(eo.capacity), 0) AS total_capacity
FROM users u
JOIN roles r ON u.role_id = r.id
LEFT JOIN events e ON u.id = e.organizer_id
LEFT JOIN event_options eo ON e.id = eo.event_id
GROUP BY u.id, u.name, u.email, r.name;
