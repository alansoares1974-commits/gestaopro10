import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { User as SupabaseUser, Session } from '@supabase/supabase-js';

export type Permission = 
  | 'dashboard' 
  | 'products' 
  | 'sales' 
  | 'reports' 
  | 'customers' 
  | 'materials' 
  | 'services' 
  | 'expenses' 
  | 'production' 
  | 'marketplace-orders' 
  | 'suppliers' 
  | 'employees' 
  | 'invoices' 
  | 'assets';

interface User {
  id: string;
  email: string;
  username: string;
  role: 'admin' | 'user';
  permissions?: Permission[];
}

interface AuthContextType {
  user: User | null;
  session: Session | null;
  login: (email: string, password: string) => Promise<{ success: boolean; error?: string }>;
  signup: (email: string, password: string, username: string) => Promise<{ success: boolean; error?: string }>;
  logout: () => Promise<void>;
  isAuthenticated: boolean;
  loading: boolean;
  hasPermission: (permission: Permission) => boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Set up auth state listener FIRST
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (event, currentSession) => {
        setSession(currentSession);
        
        if (currentSession?.user) {
          // Defer profile fetch to avoid blocking
          setTimeout(() => {
            fetchUserProfile(currentSession.user);
          }, 0);
        } else {
          setUser(null);
          setLoading(false);
        }
      }
    );

    // THEN check for existing session
    supabase.auth.getSession().then(({ data: { session: currentSession } }) => {
      setSession(currentSession);
      
      if (currentSession?.user) {
        fetchUserProfile(currentSession.user);
      } else {
        setLoading(false);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  const fetchUserProfile = async (supabaseUser: SupabaseUser) => {
    try {
      // Fetch profile (use maybeSingle to handle missing profiles gracefully)
      const { data: profile } = await supabase
        .from('profiles')
        .select('username')
        .eq('id', supabaseUser.id)
        .maybeSingle();

      // Check if user has admin role
      const { data: userRoles } = await supabase
        .from('user_roles')
        .select('role')
        .eq('user_id', supabaseUser.id);

      const isAdmin = userRoles?.some(r => r.role === 'admin');

      setUser({
        id: supabaseUser.id,
        email: supabaseUser.email || '',
        username: profile?.username || supabaseUser.email?.split('@')[0] || '',
        role: isAdmin ? 'admin' : 'user',
        permissions: []
      });
    } catch (error) {
      console.error('Error fetching user profile:', error);
      // Even on error, set basic user data so login can proceed
      setUser({
        id: supabaseUser.id,
        email: supabaseUser.email || '',
        username: supabaseUser.email?.split('@')[0] || '',
        role: 'user',
        permissions: []
      });
    } finally {
      setLoading(false);
    }
  };

  const signup = async (email: string, password: string, username: string) => {
    try {
      const redirectUrl = `${window.location.origin}/`;
      
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          emailRedirectTo: redirectUrl,
          data: {
            username
          }
        }
      });

      if (error) {
        return { success: false, error: error.message };
      }

      // Profile is now created automatically by database trigger
      return { success: true };
    } catch (error: any) {
      return { success: false, error: error.message };
    }
  };

  const login = async (email: string, password: string) => {
    try {
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password
      });

      if (error) {
        return { success: false, error: error.message };
      }

      return { success: true };
    } catch (error: any) {
      return { success: false, error: error.message };
    }
  };

  const logout = async () => {
    await supabase.auth.signOut();
    setUser(null);
    setSession(null);
  };

  const hasPermission = (permission: Permission): boolean => {
    if (!user) return false;
    if (user.role === 'admin') return true;
    return user.permissions?.includes(permission) || false;
  };

  return (
    <AuthContext.Provider value={{ 
      user, 
      session,
      login, 
      signup,
      logout, 
      isAuthenticated: !!session && !!user, 
      loading,
      hasPermission 
    }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}