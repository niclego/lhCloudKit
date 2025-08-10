CREATE TABLE IF NOT EXISTS public.lh_user_follower_requests (
  id uuid primary key default uuid_generate_v4(),
  follower uuid not null references lh_users(id) on delete cascade,
  followee uuid not null references lh_users(id) on delete cascade,
  created_at TIMESTAMPTZ DEFAULT now(),
  constraint unique_follower_followee_pair unique (follower, followee)
);

-- Enable RLS
alter table lh_user_follower_requests enable row level security;

-- Policy: Allow delete if auth.uid() matches follower or followee
create policy "Allow delete if user is follower or followee"
on lh_user_follower_requests
for delete
using (
  auth.uid() = follower OR auth.uid() = followee
);

-- Policy: Allow SELECT for users reading their own follow request
create policy "Allow users to select their own profile"
on lh_user_follower_requests
for select
using (
  auth.uid() = follower OR auth.uid() = followee
);

-- Policy: Allow INSERT for users inserting their own follow request
create policy "Allow insert if user is the follower"
on lh_user_follower_requests
for insert
with check (
  auth.uid() = follower
);
