-- ============================================
-- SISTEMA DE GESTÃO EMPRESARIAL
-- Estrutura Completa do Banco de Dados
-- Compatível com: MySQL 8.0+ / PostgreSQL 12+
-- ============================================

-- ============================================
-- 1. ENUMERAÇÕES E TIPOS
-- ============================================

-- Para PostgreSQL, descomente:
-- CREATE TYPE app_role AS ENUM ('admin', 'user');
-- CREATE TYPE movement_type AS ENUM ('entrada', 'saida');
-- CREATE TYPE order_status AS ENUM ('pendente', 'em_preparacao', 'pronto', 'concluido');

-- Para MySQL, usar VARCHAR com CHECK constraints


-- ============================================
-- 2. TABELA DE PERFIS DE USUÁRIO
-- ============================================

CREATE TABLE profiles (
    id CHAR(36) PRIMARY KEY,  -- UUID no formato string
    username VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username)
);




-- ============================================
-- 3. TABELA DE ROLES (FUNÇÕES)
-- ============================================

CREATE TABLE user_roles (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'user')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_user_role (user_id, role),
    FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE,
    INDEX idx_user_roles (user_id, role)
);




-- ============================================
-- 4. TABELA DE CLIENTES
-- ============================================

CREATE TABLE customers (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    address TEXT,
    document VARCHAR(50),  -- CPF/CNPJ
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_customer_name (name),
    INDEX idx_customer_document (document),
    INDEX idx_customer_email (email)
);




-- ============================================
-- 5. TABELA DE PRODUTOS
-- ============================================

CREATE TABLE products (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    cost DECIMAL(10, 2),
    stock INT DEFAULT 0,
    category VARCHAR(100),
    barcode VARCHAR(100),
    image_url VARCHAR(500),
    image_url_2 VARCHAR(500),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_product_name (name),
    INDEX idx_product_barcode (barcode),
    INDEX idx_product_category (category),
    INDEX idx_product_stock (stock),
    INDEX idx_product_active (active)
);




-- ============================================
-- 6. TABELA DE VENDAS
-- ============================================

CREATE TABLE sales (
    id CHAR(36) PRIMARY KEY,
    customer_id CHAR(36),
    total_amount DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(10, 2) DEFAULT 0,
    payment_method VARCHAR(50),
    items JSON NOT NULL,  -- Array de itens: [{product_id, quantity, price, name}]
    notes TEXT,
    created_by CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE SET NULL,
    INDEX idx_sales_date (created_at),
    INDEX idx_sales_customer (customer_id),
    INDEX idx_sales_payment (payment_method)
);




-- ============================================
-- 7. TABELA DE MOVIMENTOS DE CAIXA
-- ============================================

CREATE TABLE cash_movements (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('entrada', 'saida')),
    amount DECIMAL(10, 2) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    payment_method VARCHAR(50),
    proof_url VARCHAR(500),  -- URL do comprovante
    created_by VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE,
    INDEX idx_cash_user (user_id),
    INDEX idx_cash_type (type),
    INDEX idx_cash_date (created_at),
    INDEX idx_cash_category (category)
);




-- ============================================
-- 8. TABELA DE PEDIDOS MARKETPLACE
-- ============================================

CREATE TABLE marketplace_orders (
    id CHAR(36) PRIMARY KEY,
    order_number VARCHAR(100) NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(50),
    items JSON NOT NULL,  -- Array de produtos do pedido
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'pendente' 
        CHECK (status IN ('pendente', 'em_preparacao', 'pronto', 'concluido')),
    notes TEXT,
    completed_by VARCHAR(255),
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_order_number (order_number),
    INDEX idx_order_status (status),
    INDEX idx_order_date (created_at)
);




-- ============================================
-- 9. TABELA DE DESPESAS
-- ============================================

CREATE TABLE expenses (
    id CHAR(36) PRIMARY KEY,
    description TEXT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    category VARCHAR(100),
    payment_method VARCHAR(50),
    date DATE NOT NULL,
    notes TEXT,
    created_by CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE SET NULL,
    INDEX idx_expense_date (date),
    INDEX idx_expense_category (category),
    INDEX idx_expense_created (created_at)
);




-- ============================================
-- 10. TABELA DE FORNECEDORES
-- ============================================

CREATE TABLE suppliers (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    address TEXT,
    document VARCHAR(50),
    notes TEXT,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_supplier_name (name),
    INDEX idx_supplier_active (active)
);




-- ============================================
-- 11. TABELA DE FUNCIONÁRIOS
-- ============================================

CREATE TABLE employees (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    document VARCHAR(50),
    email VARCHAR(255),
    phone VARCHAR(50),
    position VARCHAR(100),
    salary DECIMAL(10, 2),
    hire_date DATE,
    termination_date DATE,
    active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_employee_name (name),
    INDEX idx_employee_active (active),
    INDEX idx_employee_document (document)
);




-- ============================================
-- 12. TABELA DE DOCUMENTOS DE FUNCIONÁRIOS
-- ============================================

CREATE TABLE employee_documents (
    id CHAR(36) PRIMARY KEY,
    employee_id CHAR(36) NOT NULL,
    document_type VARCHAR(100) NOT NULL,
    document_url VARCHAR(500) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    INDEX idx_doc_employee (employee_id)
);




-- ============================================
-- 13. TABELA DE MATERIAIS
-- ============================================

CREATE TABLE materials (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    unit VARCHAR(50),  -- kg, litro, unidade, etc
    stock DECIMAL(10, 2) DEFAULT 0,
    min_stock DECIMAL(10, 2),
    cost DECIMAL(10, 2),
    supplier_id CHAR(36),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL,
    INDEX idx_material_name (name),
    INDEX idx_material_stock (stock),
    INDEX idx_material_active (active)
);




-- ============================================
-- 14. TABELA DE SERVIÇOS
-- ============================================

CREATE TABLE services (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    duration_minutes INT,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_service_name (name),
    INDEX idx_service_active (active)
);




-- ============================================
-- 15. TABELA DE CONTRATOS
-- ============================================

CREATE TABLE contracts (
    id CHAR(36) PRIMARY KEY,
    customer_id CHAR(36) NOT NULL,
    service_id CHAR(36),
    contract_number VARCHAR(100),
    start_date DATE NOT NULL,
    end_date DATE,
    value DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'ativo',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE SET NULL,
    INDEX idx_contract_customer (customer_id),
    INDEX idx_contract_status (status),
    INDEX idx_contract_dates (start_date, end_date)
);




-- ============================================
-- 16. TABELA DE NOTAS FISCAIS
-- ============================================

CREATE TABLE invoices (
    id CHAR(36) PRIMARY KEY,
    invoice_number VARCHAR(100) NOT NULL,
    customer_id CHAR(36),
    sale_id CHAR(36),
    issue_date DATE NOT NULL,
    due_date DATE,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pendente',
    file_url VARCHAR(500),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE SET NULL,
    INDEX idx_invoice_number (invoice_number),
    INDEX idx_invoice_customer (customer_id),
    INDEX idx_invoice_status (status),
    INDEX idx_invoice_dates (issue_date, due_date)
);




-- ============================================
-- 17. TABELA DE ATIVOS
-- ============================================

CREATE TABLE assets (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    purchase_date DATE,
    purchase_value DECIMAL(10, 2),
    current_value DECIMAL(10, 2),
    depreciation_rate DECIMAL(5, 2),
    location VARCHAR(255),
    status VARCHAR(50) DEFAULT 'ativo',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_asset_name (name),
    INDEX idx_asset_category (category),
    INDEX idx_asset_status (status)
);




-- ============================================
-- 18. TABELA DE ORDENS DE PRODUÇÃO
-- ============================================

CREATE TABLE production_orders (
    id CHAR(36) PRIMARY KEY,
    order_number VARCHAR(100) NOT NULL,
    product_id CHAR(36),
    quantity INT NOT NULL,
    status VARCHAR(50) DEFAULT 'pendente',
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    notes TEXT,
    created_by CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE SET NULL,
    INDEX idx_production_status (status),
    INDEX idx_production_product (product_id),
    INDEX idx_production_dates (start_date, end_date)
);




-- ============================================
-- DADOS INICIAIS (SEED)
-- ============================================

-- Inserir usuário admin padrão (ajustar ID conforme sistema de autenticação)
-- INSERT INTO profiles (id, username, full_name) 
-- VALUES ('admin-uuid-here', 'admin', 'Administrador');

-- INSERT INTO user_roles (id, user_id, role)
-- VALUES ('role-uuid-here', 'admin-uuid-here', 'admin');


-- ============================================
-- VIEWS ÚTEIS
-- ============================================

-- View de produtos com estoque baixo
CREATE VIEW products_low_stock AS
SELECT 
    id,
    name,
    stock,
    category,
    price
FROM products 
WHERE stock < 10 AND active = TRUE
ORDER BY stock ASC;

-- View de resumo de vendas por dia
CREATE VIEW daily_sales_summary AS
SELECT 
    DATE(created_at) as sale_date,
    COUNT(*) as total_orders,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as average_order_value
FROM sales
GROUP BY DATE(created_at)
ORDER BY sale_date DESC;

-- View de saldo de caixa
CREATE VIEW cash_balance AS
SELECT 
    SUM(CASE WHEN type = 'entrada' THEN amount ELSE 0 END) as total_income,
    SUM(CASE WHEN type = 'saida' THEN amount ELSE 0 END) as total_expenses,
    SUM(CASE WHEN type = 'entrada' THEN amount ELSE -amount END) as balance
FROM cash_movements;




-- ============================================
-- FIM DO SCHEMA
-- ============================================
