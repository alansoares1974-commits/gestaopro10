import { Navigate } from 'react-router-dom';
import { useAuth, Permission } from '@/contexts/AuthContext';

interface PermissionRouteProps {
  children: React.ReactNode;
  permission: Permission;
}

export default function PermissionRoute({ children, permission }: PermissionRouteProps) {
  const { isAuthenticated, hasPermission } = useAuth();

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (!hasPermission(permission)) {
    // Permitir acesso ao Dashboard para qualquer usuário autenticado
    if (permission === 'dashboard') {
      return <>{children}</>;
    }
    return <Navigate to="/dashboard" replace />;
  }

  return <>{children}</>;
}
