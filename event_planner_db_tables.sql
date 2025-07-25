CREATE TYPE role_name_enum AS ENUM (
  'admin',
  'attendee',
  'organizer',
  'co_organizer',
  'venue_staff'
);

CREATE TYPE event_type_enum AS ENUM (
  'day_event',
  'multi_day'
);

CREATE TYPE meeting_type_enum AS ENUM (
  'virtual',
  'in_person'
);

CREATE TYPE event_status_enum AS ENUM (
  'draft',
  'active',
  'cancelled',
  'completed'
);

CREATE TYPE shape_type_enum AS ENUM (
  'rectangle',
  'circle',
  'polygon'
);
