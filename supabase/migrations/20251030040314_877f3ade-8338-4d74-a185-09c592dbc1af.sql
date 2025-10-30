-- Fix profiles RLS and auto-creation (handling duplicates)

-- 1. Add INSERT policy for profiles (allow users to create their own profile)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'profiles' 
    AND policyname = 'Users can create their own profile'
  ) THEN
    CREATE POLICY "Users can create their own profile"
    ON public.profiles
    FOR INSERT
    WITH CHECK (auth.uid() = id);
  END IF;
END $$;

-- 2. Create function to automatically create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  base_username TEXT;
  final_username TEXT;
  counter INT := 0;
BEGIN
  -- Get base username from metadata or email
  base_username := COALESCE(
    NEW.raw_user_meta_data->>'username',
    split_part(NEW.email, '@', 1)
  );
  
  final_username := base_username;
  
  -- Make username unique if it already exists
  WHILE EXISTS (SELECT 1 FROM public.profiles WHERE username = final_username) LOOP
    counter := counter + 1;
    final_username := base_username || '_' || counter;
  END LOOP;
  
  -- Insert profile with unique username
  INSERT INTO public.profiles (id, username, full_name)
  VALUES (NEW.id, final_username, base_username);
  
  RETURN NEW;
END;
$$;

-- 3. Create trigger to run the function on user creation (drop first to avoid duplicates)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 4. Create profiles for existing users who don't have one (with unique usernames)
DO $$
DECLARE
  user_record RECORD;
  base_username TEXT;
  final_username TEXT;
  counter INT;
BEGIN
  FOR user_record IN 
    SELECT au.id, au.email, au.raw_user_meta_data
    FROM auth.users au
    LEFT JOIN public.profiles p ON p.id = au.id
    WHERE p.id IS NULL
  LOOP
    base_username := COALESCE(
      user_record.raw_user_meta_data->>'username',
      split_part(user_record.email, '@', 1)
    );
    
    final_username := base_username;
    counter := 0;
    
    -- Make username unique
    WHILE EXISTS (SELECT 1 FROM public.profiles WHERE username = final_username) LOOP
      counter := counter + 1;
      final_username := base_username || '_' || counter;
    END LOOP;
    
    -- Insert profile
    INSERT INTO public.profiles (id, username, full_name)
    VALUES (user_record.id, final_username, base_username);
  END LOOP;
END $$;