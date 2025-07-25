-- CREATE OR REPLACE VIEW model_events_extended AS
SELECT
    e.id AS event_id,
    e.title,
    e.status,
    e.meeting_type,
    e.event_type,
    e.date,
    e.time,
    eo.ticket_price::numeric,
    eo.capacity AS event_capacity,
    m.start_date,
    m.end_date,
    vo.meeting_link,
    u.name AS organizer_name,
    u.email AS organizer_email,
    r.name AS organizer_role
FROM events e
LEFT JOIN event_options eo ON e.id = eo.event_id
LEFT JOIN multi_day_events m ON e.id = m.event_id
LEFT JOIN virtual_options vo ON e.id = vo.event_id
JOIN users u ON e.organizer_id = u.id
JOIN roles r ON u.role_id = r.id;
