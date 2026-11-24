-- Your fix goes here. Then run ./check.sh
-- Create the tables from "Your task" in notes.md and move the data from bookings_raw into them.

create table customers (
  id int primary key,
  name text not null,
  email text not null
);

create table staff (
  id int primary key,
  name text not null
);

create table bookings (
  id int primary key,
  customer_id int not null references customers(id),
  staff_id int not null references staff(id),
  service text not null,
  price numeric(8,2) not null,
  starts_at timestamptz not null
);

insert into customers (id, name, email)
select row_number() over (order by email), name, email
from (
  select distinct
    coalesce(doc->'customer'->>'name', doc->>'customer_name') as name,
    coalesce(doc->'customer'->>'email', doc->>'customer_email') as email
  from bookings_raw
) c;

insert into staff (id, name)
-- initcap is used to convert the name to uppercase
-- trim is used to remove the whitespace from the name
-- coalesce is used to handle the case where the name is null
-- doc->>'staff' is used to get the staff name from the json

select row_number() over (order by name), name
from (
  select distinct initcap(trim(coalesce(doc->>'staff', doc->>'stylist'))) as name
  from bookings_raw
) s;

insert into bookings (id, customer_id, staff_id, service, price, starts_at)
select r.id, c.id, s.id, r.doc->>'service', (r.doc->>'price')::numeric, (r.doc->>'starts_at')::timestamptz
from bookings_raw r
join customers c on c.email = coalesce(r.doc->'customer'->>'email', r.doc->>'customer_email')
join staff s on s.name = initcap(trim(coalesce(r.doc->>'staff', r.doc->>'stylist')));
