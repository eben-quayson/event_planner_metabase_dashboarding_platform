-- Purpose: Estimate potential revenue from ticket price * capacity.
SELECT
    e.id AS event_id,
    e.title,
    eo.ticket_price::numeric,
    eo.capacity,
    (eo.ticket_price::numeric * eo.capacity) AS potential_revenue,
    e.status
FROM events e
JOIN event_options eo ON e.id = eo.event_id;
