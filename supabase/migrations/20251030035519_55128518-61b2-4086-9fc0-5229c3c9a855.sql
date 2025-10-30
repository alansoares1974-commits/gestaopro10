-- Fix security vulnerabilities in RLS policies

-- 1. FIX CUSTOMERS TABLE - Require authentication for viewing PII
DROP POLICY IF EXISTS "Authenticated users can view customers" ON public.customers;
CREATE POLICY "Authenticated users can view customers"
ON public.customers
FOR SELECT
USING (auth.uid() IS NOT NULL);

-- 2. FIX CASH_MOVEMENTS TABLE - Remove public access policies
DROP POLICY IF EXISTS "Anyone can view cash movements" ON public.cash_movements;
DROP POLICY IF EXISTS "Anyone can insert cash movements" ON public.cash_movements;
DROP POLICY IF EXISTS "Anyone can update cash movements" ON public.cash_movements;
DROP POLICY IF EXISTS "Anyone can delete cash movements" ON public.cash_movements;

-- Create authenticated policies for cash_movements
CREATE POLICY "Authenticated users can view cash movements"
ON public.cash_movements
FOR SELECT
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can insert cash movements"
ON public.cash_movements
FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update cash movements"
ON public.cash_movements
FOR UPDATE
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can delete cash movements"
ON public.cash_movements
FOR DELETE
USING (auth.uid() IS NOT NULL);

-- 3. FIX EXPENSES TABLE - Remove duplicate public policy
DROP POLICY IF EXISTS "Anyone can view expenses" ON public.expenses;

-- Keep the existing authenticated policies for expenses

-- Note: sales, marketplace_orders already have proper authenticated policies
-- Note: products remain publicly viewable as they don't contain PII