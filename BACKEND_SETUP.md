# 🚀 Guia Completo de Implementação do Backend

> Este guia contém TUDO que você precisa para criar o backend completo do sistema de gestão empresarial.

---

## 📦 1. STACK TECNOLÓGICO RECOMENDADO

### Opção A: Node.js + Express (Recomendado)
```json
{
  "runtime": "Node.js 18+",
  "framework": "Express 4.18+",
  "database": "MySQL 8.0+ ou PostgreSQL 14+",
  "orm": "Prisma ou TypeORM",
  "auth": "JWT (jsonwebtoken)",
  "validation": "Zod ou Joi",
  "upload": "Multer",
  "cors": "cors"
}
```

### Opção B: Node.js + Fastify
```json
{
  "framework": "Fastify 4+",
  "plugins": "@fastify/jwt, @fastify/cors, @fastify/multipart"
}
```

---

## 📁 2. ESTRUTURA DE PASTAS

```
backend/
├── src/
│   ├── config/
│   │   ├── database.ts        # Configuração do banco
│   │   ├── jwt.ts             # Configuração JWT
│   │   └── env.ts             # Variáveis de ambiente
│   │
│   ├── middlewares/
│   │   ├── auth.ts            # Middleware de autenticação
│   │   ├── validate.ts        # Validação de requests
│   │   ├── errorHandler.ts   # Tratamento de erros
│   │   └── cors.ts            # CORS config
│   │
│   ├── models/
│   │   ├── User.ts
│   │   ├── Product.ts
│   │   ├── Sale.ts
│   │   └── ... (todos os modelos)
│   │
│   ├── controllers/
│   │   ├── auth.controller.ts
│   │   ├── products.controller.ts
│   │   ├── sales.controller.ts
│   │   └── ...
│   │
│   ├── services/
│   │   ├── auth.service.ts
│   │   ├── products.service.ts
│   │   └── ...
│   │
│   ├── routes/
│   │   ├── auth.routes.ts
│   │   ├── products.routes.ts
│   │   ├── sales.routes.ts
│   │   └── index.ts           # Centralizador de rotas
│   │
│   ├── utils/
│   │   ├── hash.ts            # Bcrypt helpers
│   │   ├── jwt.ts             # JWT helpers
│   │   └── validators.ts      # Validadores customizados
│   │
│   ├── types/
│   │   └── index.ts           # Tipos TypeScript
│   │
│   ├── app.ts                 # Configuração do Express
│   └── server.ts              # Entrada da aplicação
│
├── prisma/                     # Se usar Prisma
│   ├── schema.prisma
│   └── migrations/
│
├── uploads/                    # Upload de arquivos
├── .env.example
├── .gitignore
├── package.json
├── tsconfig.json
└── README.md
```

---

## 📄 3. PACKAGE.JSON

```json
{
  "name": "gestao-backend",
  "version": "1.0.0",
  "description": "Backend do Sistema de Gestão Empresarial",
  "main": "dist/server.js",
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "prisma:migrate": "prisma migrate dev",
    "prisma:generate": "prisma generate"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "jsonwebtoken": "^9.0.2",
    "bcrypt": "^5.1.1",
    "zod": "^3.22.4",
    "prisma": "^5.8.0",
    "@prisma/client": "^5.8.0",
    "multer": "^1.4.5-lts.1",
    "uuid": "^9.0.1"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/node": "^20.10.6",
    "@types/cors": "^2.8.17",
    "@types/jsonwebtoken": "^9.0.5",
    "@types/bcrypt": "^5.0.2",
    "@types/multer": "^1.4.11",
    "typescript": "^5.3.3",
    "tsx": "^4.7.0"
  }
}
```

---

## 🔧 4. ARQUIVOS DE CONFIGURAÇÃO

### .env.example
```env
# Server
NODE_ENV=development
PORT=3000
API_VERSION=v1

# Database
DATABASE_URL="mysql://user:password@localhost:3306/gestao_db"
# ou PostgreSQL:
# DATABASE_URL="postgresql://user:password@localhost:5432/gestao_db"

# JWT
JWT_SECRET=seu_secret_super_seguro_aqui_min_32_caracteres
JWT_EXPIRES_IN=24h

# Upload
MAX_FILE_SIZE=5242880  # 5MB em bytes
UPLOAD_DIR=./uploads

# CORS
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000

# Rate Limiting
RATE_LIMIT_WINDOW=15m
RATE_LIMIT_MAX=100
```

### tsconfig.json
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node",
    "types": ["node"]
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

---

## 🗄️ 5. SCHEMA DO PRISMA (Opcional)

Se optar por usar Prisma, crie `prisma/schema.prisma`:

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "mysql"  // ou "postgresql"
  url      = env("DATABASE_URL")
}

model Profile {
  id         String   @id @default(uuid())
  username   String   @unique
  password   String
  fullName   String?  @map("full_name")
  createdAt  DateTime @default(now()) @map("created_at")
  updatedAt  DateTime @updatedAt @map("updated_at")
  
  roles      UserRole[]
  sales      Sale[]
  cashMovements CashMovement[]
  
  @@map("profiles")
}

model UserRole {
  id        String   @id @default(uuid())
  userId    String   @map("user_id")
  role      Role
  createdAt DateTime @default(now()) @map("created_at")
  
  user      Profile  @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@unique([userId, role])
  @@map("user_roles")
}

enum Role {
  admin
  user
}

model Product {
  id          String   @id @default(uuid())
  name        String
  description String?  @db.Text
  price       Decimal  @db.Decimal(10, 2)
  cost        Decimal? @db.Decimal(10, 2)
  stock       Int      @default(0)
  category    String?
  barcode     String?  @unique
  imageUrl    String?  @map("image_url")
  imageUrl2   String?  @map("image_url_2")
  active      Boolean  @default(true)
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")
  
  @@map("products")
}

// Adicione os outros modelos seguindo o mesmo padrão...
```

---

## 💻 6. IMPLEMENTAÇÃO DOS PRINCIPAIS ARQUIVOS

### src/server.ts
```typescript
import app from './app';
import { config } from './config/env';

const PORT = config.port || 3000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 API: http://localhost:${PORT}/api/${config.apiVersion}`);
  console.log(`🌍 Environment: ${config.nodeEnv}`);
});
```

### src/app.ts
```typescript
import express from 'express';
import cors from 'cors';
import { errorHandler } from './middlewares/errorHandler';
import routes from './routes';
import { config } from './config/env';

const app = express();

// Middlewares
app.use(cors({
  origin: config.allowedOrigins.split(','),
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use(`/api/${config.apiVersion}`, routes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Error handling
app.use(errorHandler);

export default app;
```

### src/config/env.ts
```typescript
import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().transform(Number).default('3000'),
  API_VERSION: z.string().default('v1'),
  DATABASE_URL: z.string(),
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRES_IN: z.string().default('24h'),
  ALLOWED_ORIGINS: z.string(),
});

const env = envSchema.parse(process.env);

export const config = {
  nodeEnv: env.NODE_ENV,
  port: env.PORT,
  apiVersion: env.API_VERSION,
  databaseUrl: env.DATABASE_URL,
  jwtSecret: env.JWT_SECRET,
  jwtExpiresIn: env.JWT_EXPIRES_IN,
  allowedOrigins: env.ALLOWED_ORIGINS,
};
```

### src/middlewares/auth.ts
```typescript
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config/env';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    username: string;
    roles: string[];
  };
}

export const authenticate = (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Token não fornecido'
        }
      });
    }

    const decoded = jwt.verify(token, config.jwtSecret) as {
      id: string;
      username: string;
      roles: string[];
    };

    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      error: {
        code: 'INVALID_TOKEN',
        message: 'Token inválido ou expirado'
      }
    });
  }
};

export const requireRole = (role: string) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user?.roles.includes(role)) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: 'Acesso negado'
        }
      });
    }
    next();
  };
};
```

### src/middlewares/errorHandler.ts
```typescript
import { Request, Response, NextFunction } from 'express';

export class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string,
    public details?: any
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export const errorHandler = (
  error: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error('❌ Error:', error);

  if (error instanceof AppError) {
    return res.status(error.statusCode).json({
      success: false,
      error: {
        code: error.code,
        message: error.message,
        details: error.details
      }
    });
  }

  return res.status(500).json({
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: 'Erro interno do servidor'
    }
  });
};
```

### src/controllers/auth.controller.ts
```typescript
import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import { config } from '../config/env';
import { AppError } from '../middlewares/errorHandler';
// import { prisma } from '../config/database'; // ou seu ORM

const registerSchema = z.object({
  username: z.string().min(3).max(100),
  password: z.string().min(8),
  full_name: z.string().optional(),
});

const loginSchema = z.object({
  username: z.string(),
  password: z.string(),
});

export const authController = {
  async register(req: Request, res: Response) {
    try {
      const data = registerSchema.parse(req.body);
      
      // Verificar se usuário já existe
      // const existingUser = await prisma.profile.findUnique({
      //   where: { username: data.username }
      // });
      
      // if (existingUser) {
      //   throw new AppError(409, 'USER_EXISTS', 'Usuário já existe');
      // }

      // Hash da senha
      const hashedPassword = await bcrypt.hash(data.password, 10);

      // Criar usuário
      // const user = await prisma.profile.create({
      //   data: {
      //     username: data.username,
      //     password: hashedPassword,
      //     fullName: data.full_name,
      //   }
      // });

      // Criar role padrão 'user'
      // await prisma.userRole.create({
      //   data: {
      //     userId: user.id,
      //     role: 'user'
      //   }
      // });

      // Gerar token
      const token = jwt.sign(
        {
          id: 'user.id',
          username: data.username,
          roles: ['user']
        },
        config.jwtSecret,
        { expiresIn: config.jwtExpiresIn }
      );

      res.status(201).json({
        success: true,
        data: {
          user: {
            id: 'user.id',
            username: data.username,
            full_name: data.full_name
          },
          token
        }
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        throw new AppError(400, 'VALIDATION_ERROR', 'Dados inválidos', error.errors);
      }
      throw error;
    }
  },

  async login(req: Request, res: Response) {
    try {
      const data = loginSchema.parse(req.body);
      
      // Buscar usuário
      // const user = await prisma.profile.findUnique({
      //   where: { username: data.username },
      //   include: { roles: true }
      // });

      // if (!user) {
      //   throw new AppError(401, 'INVALID_CREDENTIALS', 'Credenciais inválidas');
      // }

      // Verificar senha
      // const isPasswordValid = await bcrypt.compare(data.password, user.password);
      // if (!isPasswordValid) {
      //   throw new AppError(401, 'INVALID_CREDENTIALS', 'Credenciais inválidas');
      // }

      // Gerar token
      const token = jwt.sign(
        {
          id: 'user.id',
          username: data.username,
          roles: ['user'] // user.roles.map(r => r.role)
        },
        config.jwtSecret,
        { expiresIn: config.jwtExpiresIn }
      );

      res.json({
        success: true,
        data: {
          user: {
            id: 'user.id',
            username: data.username,
            roles: ['user']
          },
          token
        }
      });
    } catch (error) {
      throw error;
    }
  },
};
```

---

## 🎯 7. PRÓXIMOS PASSOS

1. **Instalar dependências:**
   ```bash
   npm install
   ```

2. **Configurar banco de dados:**
   - Criar database no MySQL/PostgreSQL
   - Copiar `.env.example` para `.env`
   - Preencher variáveis de ambiente
   - Executar `DATABASE_SCHEMA.sql` para criar tabelas

3. **Se usar Prisma:**
   ```bash
   npx prisma generate
   npx prisma migrate dev
   ```

4. **Implementar controllers e services:**
   - Seguir padrão do `auth.controller.ts`
   - Implementar para: products, sales, customers, etc.
   - Consultar `API_SPECIFICATION.md` para todos endpoints

5. **Testar:**
   ```bash
   npm run dev
   ```

6. **Deploy:**
   - Configurar variáveis de ambiente no servidor
   - Build: `npm run build`
   - Executar: `npm start`

---

## 📚 RECURSOS ADICIONAIS

- **Prisma Docs:** https://www.prisma.io/docs
- **Express Best Practices:** https://expressjs.com/en/advanced/best-practice-security.html
- **JWT:** https://jwt.io/
- **Zod Validation:** https://zod.dev/

---

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

- [ ] Configurar estrutura de pastas
- [ ] Instalar dependências
- [ ] Configurar banco de dados
- [ ] Implementar autenticação (register/login)
- [ ] Implementar middleware de auth
- [ ] Implementar CRUD de produtos
- [ ] Implementar CRUD de vendas
- [ ] Implementar movimentos de caixa
- [ ] Implementar clientes
- [ ] Implementar pedidos marketplace
- [ ] Implementar despesas
- [ ] Implementar relatórios
- [ ] Implementar upload de arquivos
- [ ] Testes com Postman/Insomnia
- [ ] Documentação adicional
- [ ] Deploy

---

**🤖 Com este guia, qualquer IA consegue implementar o backend completo!**
