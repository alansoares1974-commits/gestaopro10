# 🔗 Guia de Integração Frontend com Backend

> Como conectar o frontend React ao seu novo backend REST API

---

## 🎯 1. VISÃO GERAL

O frontend foi preparado para se conectar facilmente com o backend REST. Todas as referências ao Supabase e Base44 foram removidas, e um sistema de API service foi implementado.

---

## ⚙️ 2. CONFIGURAÇÃO INICIAL

### 2.1 Variáveis de Ambiente

Crie um arquivo `.env` na raiz do frontend:

```env
# Backend API
VITE_API_BASE_URL=http://localhost:3000/api/v1

# Upload de arquivos (se aplicável)
VITE_MAX_FILE_SIZE=5242880

# Outras configurações
VITE_APP_NAME=Sistema de Gestão
```

### 2.2 Arquivo de Configuração

O arquivo `src/config/api.ts` já está configurado:

```typescript
export const API_CONFIG = {
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api/v1',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
};
```

---

## 📦 3. SERVIÇO DE API (API Service)

O frontend usa um serviço centralizado para todas as chamadas HTTP.

### 3.1 Estrutura do API Service

```
src/
├── services/
│   ├── api.ts              # Cliente HTTP base
│   ├── auth.service.ts     # Autenticação
│   ├── products.service.ts # Produtos
│   ├── sales.service.ts    # Vendas
│   └── ...                 # Outros serviços
```

### 3.2 Cliente HTTP Base (`src/services/api.ts`)

```typescript
import axios from 'axios';
import { API_CONFIG } from '@/config/api';

// Criar instância do axios
export const apiClient = axios.create({
  baseURL: API_CONFIG.baseURL,
  timeout: API_CONFIG.timeout,
  headers: API_CONFIG.headers,
});

// Interceptor para adicionar token JWT
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Interceptor para tratamento de erros
apiClient.interceptors.response.use(
  (response) => response.data,
  (error) => {
    if (error.response?.status === 401) {
      // Token expirado - redirecionar para login
      localStorage.removeItem('auth_token');
      window.location.href = '/login';
    }
    return Promise.reject(error.response?.data || error);
  }
);
```

---

## 🔐 4. AUTENTICAÇÃO

### 4.1 Auth Service (`src/services/auth.service.ts`)

```typescript
import { apiClient } from './api';

export interface LoginData {
  username: string;
  password: string;
}

export interface RegisterData {
  username: string;
  password: string;
  full_name?: string;
}

export const authService = {
  async register(data: RegisterData) {
    const response = await apiClient.post('/auth/register', data);
    if (response.data.token) {
      localStorage.setItem('auth_token', response.data.token);
    }
    return response.data;
  },

  async login(data: LoginData) {
    const response = await apiClient.post('/auth/login', data);
    if (response.data.token) {
      localStorage.setItem('auth_token', response.data.token);
    }
    return response.data;
  },

  async getMe() {
    return apiClient.get('/auth/me');
  },

  logout() {
    localStorage.removeItem('auth_token');
    window.location.href = '/login';
  },
};
```

### 4.2 Auth Context (`src/contexts/AuthContext.tsx`)

O AuthContext já está configurado para usar o auth service:

```typescript
import { createContext, useContext, useState, useEffect } from 'react';
import { authService } from '@/services/auth.service';

interface User {
  id: string;
  username: string;
  full_name?: string;
  roles: string[];
}

interface AuthContextType {
  user: User | null;
  login: (username: string, password: string) => Promise<void>;
  logout: () => void;
  isLoading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    checkAuth();
  }, []);

  const checkAuth = async () => {
    try {
      const token = localStorage.getItem('auth_token');
      if (token) {
        const response = await authService.getMe();
        setUser(response.data);
      }
    } catch (error) {
      localStorage.removeItem('auth_token');
    } finally {
      setIsLoading(false);
    }
  };

  const login = async (username: string, password: string) => {
    const response = await authService.login({ username, password });
    setUser(response.data.user);
  };

  const logout = () => {
    authService.logout();
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};
```

---

## 📦 5. EXEMPLO: SERVIÇO DE PRODUTOS

### `src/services/products.service.ts`

```typescript
import { apiClient } from './api';

export interface Product {
  id: string;
  name: string;
  description?: string;
  price: number;
  cost?: number;
  stock: number;
  category?: string;
  barcode?: string;
  image_url?: string;
  image_url_2?: string;
  active: boolean;
  created_at: string;
  updated_at: string;
}

export interface CreateProductData {
  name: string;
  description?: string;
  price: number;
  cost?: number;
  stock?: number;
  category?: string;
  barcode?: string;
  image_url?: string;
  image_url_2?: string;
  active?: boolean;
}

export const productsService = {
  async list(params?: {
    page?: number;
    limit?: number;
    search?: string;
    category?: string;
    active?: boolean;
    low_stock?: boolean;
  }) {
    return apiClient.get('/products', { params });
  },

  async getById(id: string) {
    return apiClient.get(`/products/${id}`);
  },

  async create(data: CreateProductData) {
    return apiClient.post('/products', data);
  },

  async update(id: string, data: Partial<CreateProductData>) {
    return apiClient.put(`/products/${id}`, data);
  },

  async delete(id: string) {
    return apiClient.delete(`/products/${id}`);
  },

  async updateStock(id: string, quantity: number, operation: 'add' | 'set') {
    return apiClient.patch(`/products/${id}/stock`, { quantity, operation });
  },
};
```

---

## 🛒 6. EXEMPLO: USANDO O SERVIÇO NOS COMPONENTES

### Componente de Lista de Produtos

```typescript
import { useState, useEffect } from 'react';
import { productsService, Product } from '@/services/products.service';
import { useToast } from '@/hooks/use-toast';

export function ProductsList() {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const { toast } = useToast();

  useEffect(() => {
    loadProducts();
  }, []);

  const loadProducts = async () => {
    try {
      setLoading(true);
      const response = await productsService.list({
        page: 1,
        limit: 20,
        active: true,
      });
      setProducts(response.data);
    } catch (error: any) {
      toast({
        title: 'Erro ao carregar produtos',
        description: error.error?.message || 'Tente novamente',
        variant: 'destructive',
      });
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: string) => {
    try {
      await productsService.delete(id);
      toast({
        title: 'Produto deletado com sucesso',
      });
      loadProducts();
    } catch (error: any) {
      toast({
        title: 'Erro ao deletar produto',
        description: error.error?.message,
        variant: 'destructive',
      });
    }
  };

  if (loading) return <div>Carregando...</div>;

  return (
    <div>
      {products.map((product) => (
        <div key={product.id}>
          <h3>{product.name}</h3>
          <p>R$ {product.price.toFixed(2)}</p>
          <button onClick={() => handleDelete(product.id)}>Deletar</button>
        </div>
      ))}
    </div>
  );
}
```

---

## 💾 7. TODOS OS SERVIÇOS NECESSÁRIOS

Crie serviços para cada entidade seguindo o mesmo padrão:

### Serviços a Criar:

1. ✅ `auth.service.ts` - Já criado
2. ✅ `products.service.ts` - Exemplo acima
3. 📝 `sales.service.ts`
4. 📝 `customers.service.ts`
5. 📝 `cash-movements.service.ts`
6. 📝 `marketplace-orders.service.ts`
7. 📝 `expenses.service.ts`
8. 📝 `suppliers.service.ts`
9. 📝 `employees.service.ts`
10. 📝 `materials.service.ts`
11. 📝 `services.service.ts`
12. 📝 `contracts.service.ts`
13. 📝 `invoices.service.ts`
14. 📝 `assets.service.ts`
15. 📝 `production-orders.service.ts`
16. 📝 `dashboard.service.ts`

### Template para Novos Serviços:

```typescript
import { apiClient } from './api';

export interface EntityType {
  // Defina os campos da entidade
}

export const entityService = {
  async list(params?: any) {
    return apiClient.get('/entity', { params });
  },

  async getById(id: string) {
    return apiClient.get(`/entity/${id}`);
  },

  async create(data: any) {
    return apiClient.post('/entity', data);
  },

  async update(id: string, data: any) {
    return apiClient.put(`/entity/${id}`, data);
  },

  async delete(id: string) {
    return apiClient.delete(`/entity/${id}`);
  },
};
```

---

## 🔄 8. MIGRAÇÃO DE DADOS

Se você tinha dados no localStorage, crie um script de migração:

### `src/utils/migrate-data.ts`

```typescript
import { productsService } from '@/services/products.service';
import { customersService } from '@/services/customers.service';
// ... outros serviços

export async function migrateLocalStorageToAPI() {
  try {
    // Produtos
    const localProducts = JSON.parse(localStorage.getItem('products') || '[]');
    for (const product of localProducts) {
      await productsService.create(product);
    }

    // Clientes
    const localCustomers = JSON.parse(localStorage.getItem('customers') || '[]');
    for (const customer of localCustomers) {
      await customersService.create(customer);
    }

    // ... migrar outras entidades

    console.log('✅ Migração concluída!');
  } catch (error) {
    console.error('❌ Erro na migração:', error);
  }
}
```

---

## 🧪 9. TESTANDO A INTEGRAÇÃO

### 9.1 Usar o Postman/Insomnia

1. Importar as rotas do `API_SPECIFICATION.md`
2. Testar cada endpoint
3. Verificar responses

### 9.2 Console do Navegador

```javascript
// Testar login
const response = await fetch('http://localhost:3000/api/v1/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ username: 'admin', password: 'senha' })
});
const data = await response.json();
console.log(data);
```

---

## 🚀 10. CHECKLIST DE INTEGRAÇÃO

- [ ] Configurar `.env` com URL do backend
- [ ] Criar todos os services necessários
- [ ] Atualizar `AuthContext` para usar `auth.service`
- [ ] Substituir chamadas antigas nos componentes
- [ ] Testar login/logout
- [ ] Testar CRUD de produtos
- [ ] Testar CRUD de vendas
- [ ] Testar movimentos de caixa
- [ ] Testar pedidos marketplace
- [ ] Migrar dados do localStorage (se necessário)
- [ ] Remover código antigo não utilizado
- [ ] Testar em produção

---

## 📝 11. PRÓXIMOS PASSOS

1. **Backend rodando:**
   ```bash
   cd backend
   npm run dev
   ```

2. **Frontend rodando:**
   ```bash
   npm run dev
   ```

3. **Testar fluxo completo:**
   - Registrar usuário
   - Fazer login
   - Criar produto
   - Fazer venda
   - Ver dashboard

---

## 💡 DICAS IMPORTANTES

1. **Sempre trate erros:**
   ```typescript
   try {
     await service.method();
   } catch (error: any) {
     toast({
       title: 'Erro',
       description: error.error?.message || 'Erro desconhecido',
       variant: 'destructive',
     });
   }
   ```

2. **Use loading states:**
   ```typescript
   const [loading, setLoading] = useState(false);
   ```

3. **Valide antes de enviar:**
   ```typescript
   const schema = z.object({
     name: z.string().min(1),
     price: z.number().positive(),
   });
   ```

4. **Cache inteligente:**
   - Use React Query para cache automático
   - Ou implemente cache manual no service

---

**✅ Frontend pronto para conectar ao backend!**
