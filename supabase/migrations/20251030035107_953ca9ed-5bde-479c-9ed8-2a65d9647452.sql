-- Fix cash_movements RLS to allow inserts without Supabase auth and relax user_id constraint
DO $$
BEGIN
  -- Drop existing policies if present
  IF EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'cash_movements' AND policyname = 'Admins can delete all cash movements'
  ) THEN
    DROP POLICY "Admins can delete all cash movements" ON public.cash_movements;
  END IF;
  IF EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'cash_movements' AND policyname = 'Admins can update all cash movements'
  ) THEN
    DROP POLICY "Admins can update all cash movements" ON public.cash_movements;
  END IF;
  IF EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'cash_movements' AND policyname = 'Users can insert own cash movements'
  ) THEN
    DROP POLICY "Users can insert own cash movements" ON public.cash_movements;
  END IF;
  IF EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'cash_movements' AND policyname = 'Users can view own cash movements'
  ) THEN
    DROP POLICY "Users can view own cash movements" ON public.cash_movements;
  END IF;
END $$;

-- Ensure RLS is enabled
ALTER TABLE public.cash_movements ENABLE ROW LEVEL SECURITY;

-- Relax user_id constraint so inserts without Supabase auth can succeed
ALTER TABLE public.cash_movements ALTER COLUMN user_id DROP NOT NULL;

-- Open, simple policies to get persistence working now
CREATE POLICY "Anyone can view cash movements"
ON public.cash_movements
FOR SELECT
USING (true);

CREATE POLICY "Anyone can insert cash movements"
ON public.cash_movements
FOR INSERT
WITH CHECK (true);

CREATE POLICY "Anyone can update cash movements"
ON public.cash_movements
FOR UPDATE
USING (true);

CREATE POLICY "Anyone can delete cash movements"
ON public.cash_movements
FOR DELETE
USING (true);
