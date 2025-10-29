// Tipos temporários para as tabelas do banco
export interface CashMovement {
  id: string;
  type: string;
  amount: number;
  category: string | null;
  description: string | null;
  payment_method: string | null;
  proof_url: string | null;
  created_at: string;
  user_id: string;
  created_by: string | null;
}

export interface Product {
  id: string;
  name: string;
  description?: string;
  price: number;
  cost?: number;
  stock?: number;
  category?: string;
  barcode?: string;
  image_url?: string;
  image_url_2?: string;
  active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Customer {
  id: string;
  name: string;
  email?: string;
  phone?: string;
  document?: string;
  address?: string;
  notes?: string;
  created_at: string;
  updated_at: string;
}

export interface Sale {
  id: string;
  total_amount: number;
  discount?: number;
  payment_method?: string;
  items: any; // jsonb
  customer_id?: string;
  notes?: string;
  created_by?: string;
  created_at: string;
}

export interface Expense {
  id: string;
  amount: number;
  description: string;
  category?: string;
  payment_method?: string;
  notes?: string;
  date: string;
  created_by?: string;
  created_at: string;
}

export interface MarketplaceOrder {
  id: string;
  order_number: string;
  customer_name: string;
  customer_phone?: string;
  status: string;
  items: any; // jsonb
  total_amount: number;
  notes?: string;
  completed_by?: string;
  completed_at?: string;
  created_at: string;
  updated_at: string;
}
