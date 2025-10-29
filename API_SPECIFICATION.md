# 📡 API REST - Especificação Completa

> **Base URL:** `http://localhost:3000/api/v1`
> 
> **Autenticação:** JWT Bearer Token em todas as rotas protegidas
> 
> **Content-Type:** `application/json`

---

## 🔐 1. AUTENTICAÇÃO

### 1.1 Registro de Usuário
```http
POST /auth/register
```

**Request Body:**
```json
{
  "username": "string (3-100 chars, único)",
  "password": "string (min 8 chars)",
  "full_name": "string (opcional)"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "username": "joao",
      "full_name": "João Silva"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Erros:**
- 400: Dados inválidos
- 409: Usuário já existe

---

### 1.2 Login
```http
POST /auth/login
```

**Request Body:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "username": "joao",
      "full_name": "João Silva",
      "roles": ["admin"]
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

### 1.3 Verificar Token
```http
GET /auth/me
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "username": "joao",
    "full_name": "João Silva",
    "roles": ["admin"]
  }
}
```

---

## 👥 2. USUÁRIOS E PERFIS

### 2.1 Listar Usuários
```http
GET /users
Authorization: Bearer {token}
```

**Query Params:**
- `page` (int, default: 1)
- `limit` (int, default: 20)
- `search` (string, opcional)

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "username": "joao",
      "full_name": "João Silva",
      "roles": ["admin"],
      "created_at": "2024-01-01T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45
  }
}
```

---

### 2.2 Atualizar Perfil
```http
PUT /users/:id
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "full_name": "João da Silva"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "username": "joao",
    "full_name": "João da Silva"
  }
}
```

---

### 2.3 Atribuir Role
```http
POST /users/:id/roles
Authorization: Bearer {token} (apenas admin)
```

**Request Body:**
```json
{
  "role": "admin" // ou "user"
}
```

---

## 📦 3. PRODUTOS

### 3.1 Listar Produtos
```http
GET /products
Authorization: Bearer {token}
```

**Query Params:**
- `page`, `limit`
- `search` (busca em name, description, barcode)
- `category` (filtro)
- `active` (boolean)
- `low_stock` (boolean, retorna produtos com stock < 10)

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Produto X",
      "description": "Descrição",
      "price": 99.90,
      "cost": 50.00,
      "stock": 25,
      "category": "Eletrônicos",
      "barcode": "7891234567890",
      "image_url": "https://...",
      "image_url_2": "https://...",
      "active": true,
      "created_at": "2024-01-01T10:00:00Z"
    }
  ],
  "pagination": {...}
}
```

---

### 3.2 Criar Produto
```http
POST /products
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "name": "string (obrigatório)",
  "description": "string (opcional)",
  "price": number (obrigatório, > 0),
  "cost": number (opcional),
  "stock": number (default: 0),
  "category": "string (opcional)",
  "barcode": "string (opcional, único)",
  "image_url": "string (opcional)",
  "image_url_2": "string (opcional)",
  "active": boolean (default: true)
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Produto X",
    ...
  }
}
```

**Validações:**
- `name`: 1-255 caracteres
- `price`: > 0
- `barcode`: se fornecido, deve ser único
- `stock`: >= 0

---

### 3.3 Atualizar Produto
```http
PUT /products/:id
Authorization: Bearer {token}
```

**Request Body:** (mesmos campos do POST, todos opcionais)

---

### 3.4 Deletar Produto
```http
DELETE /products/:id
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Produto deletado"
}
```

---

### 3.5 Atualizar Estoque
```http
PATCH /products/:id/stock
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "quantity": number,  // pode ser negativo para diminuir
  "operation": "add" | "set"  // add: incrementa/decrementa, set: define valor
}
```

---

## 💰 4. MOVIMENTOS DE CAIXA

### 4.1 Listar Movimentos
```http
GET /cash-movements
Authorization: Bearer {token}
```

**Query Params:**
- `page`, `limit`
- `type` (entrada | saida)
- `category`
- `start_date` (ISO 8601)
- `end_date` (ISO 8601)
- `user_id` (apenas admin pode ver de outros)

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "type": "entrada",
      "amount": 1500.00,
      "description": "Venda de produtos",
      "category": "Vendas",
      "payment_method": "Pix",
      "proof_url": "https://...",
      "created_by": "João Silva",
      "created_at": "2024-01-01T10:00:00Z"
    }
  ],
  "summary": {
    "total_income": 15000.00,
    "total_expenses": 8000.00,
    "balance": 7000.00
  },
  "pagination": {...}
}
```

---

### 4.2 Criar Movimento
```http
POST /cash-movements
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "type": "entrada" | "saida" (obrigatório),
  "amount": number (obrigatório, > 0),
  "description": "string (opcional)",
  "category": "string (opcional)",
  "payment_method": "string (opcional)",
  "proof_url": "string (opcional)"
}
```

**Regras:**
- `user_id` é preenchido automaticamente com o usuário logado
- `created_by` é preenchido com o nome do usuário
- Apenas admin pode criar movimentos para outros usuários

---

### 4.3 Atualizar Movimento
```http
PUT /cash-movements/:id
Authorization: Bearer {token} (apenas admin)
```

---

### 4.4 Deletar Movimento
```http
DELETE /cash-movements/:id
Authorization: Bearer {token} (apenas admin)
```

---

## 🛒 5. VENDAS

### 5.1 Listar Vendas
```http
GET /sales
Authorization: Bearer {token}
```

**Query Params:**
- `page`, `limit`
- `customer_id`
- `start_date`, `end_date`
- `payment_method`

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "customer_id": "uuid",
      "customer": {
        "id": "uuid",
        "name": "Cliente X"
      },
      "total_amount": 299.90,
      "discount": 20.00,
      "payment_method": "Cartão de Crédito",
      "items": [
        {
          "product_id": "uuid",
          "product_name": "Produto X",
          "quantity": 2,
          "unit_price": 149.95,
          "subtotal": 299.90
        }
      ],
      "notes": "Observações",
      "created_by": "uuid",
      "created_at": "2024-01-01T10:00:00Z"
    }
  ],
  "pagination": {...}
}
```

---

### 5.2 Criar Venda
```http
POST /sales
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "customer_id": "uuid (opcional)",
  "items": [
    {
      "product_id": "uuid",
      "quantity": number,
      "unit_price": number
    }
  ],
  "discount": number (opcional, default: 0),
  "payment_method": "string (opcional)",
  "notes": "string (opcional)"
}
```

**Validações:**
- `items`: array não vazio
- `quantity`: > 0
- `unit_price`: > 0
- `total_amount`: calculado automaticamente
- **Regra de negócio:** Atualizar estoque dos produtos automaticamente

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "total_amount": 299.90,
    ...
  }
}
```

---

## 👤 6. CLIENTES

### 6.1 Listar Clientes
```http
GET /customers
Authorization: Bearer {token}
```

**Query Params:**
- `page`, `limit`
- `search` (busca em name, email, phone, document)

---

### 6.2 Criar Cliente
```http
POST /customers
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "name": "string (obrigatório)",
  "email": "string (opcional, formato email)",
  "phone": "string (opcional)",
  "address": "string (opcional)",
  "document": "string (opcional)",
  "notes": "string (opcional)"
}
```

**Validações:**
- `name`: 1-255 caracteres
- `email`: formato válido se fornecido
- `document`: pode ser CPF ou CNPJ

---

### 6.3 Atualizar Cliente
```http
PUT /customers/:id
Authorization: Bearer {token}
```

---

### 6.4 Deletar Cliente
```http
DELETE /customers/:id
Authorization: Bearer {token}
```

---

## 🏪 7. PEDIDOS MARKETPLACE

### 7.1 Listar Pedidos
```http
GET /marketplace-orders
Authorization: Bearer {token}
```

**Query Params:**
- `page`, `limit`
- `status` (pendente | em_preparacao | pronto | concluido)
- `start_date`, `end_date`

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "order_number": "MP-12345",
      "customer_name": "Cliente X",
      "customer_phone": "(11) 99999-9999",
      "items": [
        {
          "product_name": "Produto X",
          "quantity": 2,
          "price": 49.90
        }
      ],
      "total_amount": 99.80,
      "status": "pendente",
      "notes": "Observações",
      "completed_by": null,
      "completed_at": null,
      "created_at": "2024-01-01T10:00:00Z"
    }
  ],
  "pagination": {...}
}
```

---

### 7.2 Criar Pedido
```http
POST /marketplace-orders
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "order_number": "string (obrigatório)",
  "customer_name": "string (obrigatório)",
  "customer_phone": "string (opcional)",
  "items": [
    {
      "product_name": "string",
      "quantity": number,
      "price": number
    }
  ],
  "notes": "string (opcional)"
}
```

---

### 7.3 Atualizar Status
```http
PATCH /marketplace-orders/:id/status
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "status": "pendente" | "em_preparacao" | "pronto" | "concluido"
}
```

**Regra de negócio:**
- Quando status = "concluido", preencher `completed_by` e `completed_at`

---

## 💸 8. DESPESAS

### 8.1 Listar Despesas
```http
GET /expenses
Authorization: Bearer {token}
```

**Query Params:**
- `page`, `limit`
- `category`
- `start_date`, `end_date`
- `payment_method`

---

### 8.2 Criar Despesa
```http
POST /expenses
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "description": "string (obrigatório)",
  "amount": number (obrigatório, > 0),
  "category": "string (opcional)",
  "payment_method": "string (opcional)",
  "date": "YYYY-MM-DD (obrigatório)",
  "notes": "string (opcional)"
}
```

---

## 📊 9. RELATÓRIOS E DASHBOARDS

### 9.1 Dashboard Summary
```http
GET /dashboard/summary
Authorization: Bearer {token}
```

**Query Params:**
- `start_date`, `end_date` (opcional, default: mês atual)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "sales": {
      "total": 15000.00,
      "count": 45,
      "average": 333.33
    },
    "expenses": {
      "total": 8000.00,
      "count": 20
    },
    "cash_balance": 7000.00,
    "products": {
      "total": 150,
      "low_stock": 12
    },
    "customers": {
      "total": 78,
      "new_this_month": 5
    },
    "orders": {
      "pending": 3,
      "in_progress": 5,
      "completed": 42
    }
  }
}
```

---

### 9.2 Top Produtos
```http
GET /reports/top-products
Authorization: Bearer {token}
```

**Query Params:**
- `start_date`, `end_date`
- `limit` (default: 10)

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "product_id": "uuid",
      "product_name": "Produto X",
      "total_quantity": 150,
      "total_revenue": 15000.00
    }
  ]
}
```

---

### 9.3 Vendas por Período
```http
GET /reports/sales-by-period
Authorization: Bearer {token}
```

**Query Params:**
- `start_date`, `end_date`
- `group_by` (day | week | month)

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "period": "2024-01-01",
      "total_sales": 1500.00,
      "order_count": 12
    }
  ]
}
```

---

## 📋 10. OUTRAS ENTIDADES

### Fornecedores (Suppliers)
```
GET /suppliers
POST /suppliers
PUT /suppliers/:id
DELETE /suppliers/:id
```

### Funcionários (Employees)
```
GET /employees
POST /employees
PUT /employees/:id
DELETE /employees/:id
POST /employees/:id/documents (upload documento)
```

### Materiais (Materials)
```
GET /materials
POST /materials
PUT /materials/:id
DELETE /materials/:id
PATCH /materials/:id/stock
```

### Serviços (Services)
```
GET /services
POST /services
PUT /services/:id
DELETE /services/:id
```

### Contratos (Contracts)
```
GET /contracts
POST /contracts
PUT /contracts/:id
DELETE /contracts/:id
```

### Notas Fiscais (Invoices)
```
GET /invoices
POST /invoices
PUT /invoices/:id
DELETE /invoices/:id
```

### Ativos (Assets)
```
GET /assets
POST /assets
PUT /assets/:id
DELETE /assets/:id
```

### Ordens de Produção (Production Orders)
```
GET /production-orders
POST /production-orders
PUT /production-orders/:id
DELETE /production-orders/:id
PATCH /production-orders/:id/status
```

---

## 🔒 SEGURANÇA

### Headers Obrigatórios
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### Validação de Token JWT
- Expiração: 24 horas
- Renovação: POST `/auth/refresh`
- Secret: armazenar em variável de ambiente

### Rate Limiting
- 100 requisições por minuto por IP
- 1000 requisições por hora por usuário

### CORS
```javascript
Access-Control-Allow-Origin: *  // ou domínio específico
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, PATCH
Access-Control-Allow-Headers: Authorization, Content-Type
```

---

## 📝 PADRÕES DE RESPOSTA

### Sucesso
```json
{
  "success": true,
  "data": {...}
}
```

### Erro
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Descrição do erro",
    "details": {
      "field": "Erro específico do campo"
    }
  }
}
```

### Códigos HTTP
- `200` OK
- `201` Created
- `400` Bad Request
- `401` Unauthorized
- `403` Forbidden
- `404` Not Found
- `409` Conflict
- `422` Unprocessable Entity
- `500` Internal Server Error

---

## 🎯 NOTAS IMPORTANTES

1. **Todas as datas** devem estar em formato ISO 8601
2. **Valores monetários** sempre em número com 2 casas decimais
3. **IDs** sempre no formato UUID v4
4. **Paginação** padrão: 20 itens por página
5. **Busca** sempre case-insensitive
6. **Soft Delete** recomendado para dados críticos
