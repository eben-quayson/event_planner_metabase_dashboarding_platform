-- Purpose: Track virtual events with join links.

SELECT
    e.id AS event_id,
    e.title,
    e.date,
    e.time,
    vo.meeting_link,
    u.name AS organizer_name
FROM events e
JOIN virtual_options vo ON e.id = vo.event_id
JOIN users u ON e.organizer_id = u.id;
