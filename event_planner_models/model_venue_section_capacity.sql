-- Purpose: Join venue sections with events to show section capacities and event details.
SELECT
    vs.id AS section_id,
    vs.section_name,
    vs.capacity_per_section,
    vs.shape_type,
    vs.color,
    e.id AS event_id,
    e.title AS event_title,
    e.date,
    e.status
FROM venue_sections vs
JOIN events e ON vs.event_id = e.id;
