-- Step 1: Create lh_users table
CREATE TABLE IF NOT EXISTS public.lh_users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  username TEXT UNIQUE NOT NULL CHECK (char_length(username) >= 3),

  profile_image_url TEXT CHECK (
    profile_image_url IS NULL OR profile_image_url ~ '^https?://'
  ),

  account_type TEXT CHECK (
    account_type IN ('verifiedUser', 'verifiedArtist')
  ),

  is_public_account BOOLEAN NOT NULL DEFAULT false,

  created_at TIMESTAMPTZ DEFAULT now()
);

-- Step 2: Create trigger function to auto-insert on auth.users signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  new_username TEXT;
  suffix TEXT;
BEGIN
  LOOP
    suffix := substring(md5(random()::text), 1, 16);
    new_username := 'user_' || suffix;

    BEGIN
      INSERT INTO public.lh_users (id, username)
      VALUES (NEW.id, new_username);
      EXIT;
    EXCEPTION WHEN unique_violation THEN
      -- Retry on username collision
    END;
  END LOOP;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 3: Create trigger on auth.users insert
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();

-- Step 4: Enable Row-Level Security (RLS)
ALTER TABLE public.lh_users ENABLE ROW LEVEL SECURITY;

-- Step 5: Add policy - allow users to SELECT their own profile
CREATE POLICY "Users can view their own profile"
ON public.lh_users
FOR SELECT
USING (auth.uid() = id);

-- Step 6: Add policy - allow users to UPDATE their own profile
CREATE POLICY "Users can update their own profile"
ON public.lh_users
FOR UPDATE
USING (auth.uid() = id);

-- Step 7: Add policy - allow users to DELETE their own profile
CREATE POLICY "Users can delete their own profile"
ON public.lh_users
FOR DELETE
USING (auth.uid() = id);
