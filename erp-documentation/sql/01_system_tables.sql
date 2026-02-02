-- =====================================================
-- ERP СИСТЕМА: Системні таблиці (Рівень 0-1)
-- =====================================================
-- Виконувати ПЕРШИМ при створенні бази даних
-- =====================================================

-- Розширення для UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- РІВЕНЬ 0: Таблиці без залежностей
-- =====================================================

-- Системні налаштування
CREATE TABLE system_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT,
    description TEXT,
    data_type VARCHAR(20) DEFAULT 'string', -- string, number, boolean, json
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE system_settings IS 'Системні налаштування підприємства';

-- Одиниці виміру
CREATE TABLE units (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    short_name VARCHAR(10) NOT NULL,
    unit_type VARCHAR(20), -- weight, length, area, volume, quantity, time
    base_unit_id UUID REFERENCES units(id),
    conversion_factor DECIMAL(15,6) DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE units IS 'Одиниці виміру';
CREATE INDEX idx_units_type ON units(unit_type);
CREATE INDEX idx_units_active ON units(is_active);

-- Валюти
CREATE TABLE currencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(3) UNIQUE NOT NULL, -- UAH, USD, EUR
    name VARCHAR(50) NOT NULL,
    symbol VARCHAR(5),
    decimal_places INT DEFAULT 2,
    is_base BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE currencies IS 'Валюти';
CREATE UNIQUE INDEX idx_currencies_base ON currencies(is_base) WHERE is_base = true;

-- Країни
CREATE TABLE countries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(2) UNIQUE NOT NULL, -- UA, PL, DE
    code3 VARCHAR(3) UNIQUE NOT NULL, -- UKR, POL, DEU
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE countries IS 'Країни';

-- Ставки ПДВ
CREATE TABLE vat_rates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL,
    rate DECIMAL(5,2) NOT NULL, -- 20.00, 7.00, 0.00
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    valid_from DATE,
    valid_to DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE vat_rates IS 'Ставки ПДВ';
CREATE UNIQUE INDEX idx_vat_default ON vat_rates(is_default) WHERE is_default = true AND is_active = true;

-- Ролі користувачів
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    permissions JSONB DEFAULT '{}',
    is_system BOOLEAN DEFAULT false, -- системні ролі не можна видалити
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE roles IS 'Ролі користувачів';

-- =====================================================
-- РІВЕНЬ 1: Залежать від рівня 0
-- =====================================================

-- Курси валют
CREATE TABLE exchange_rates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    currency_id UUID NOT NULL REFERENCES currencies(id),
    rate DECIMAL(15,6) NOT NULL,
    rate_date DATE NOT NULL,
    source VARCHAR(50), -- НБУ, manual
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(currency_id, rate_date)
);

COMMENT ON TABLE exchange_rates IS 'Курси валют';
CREATE INDEX idx_exchange_rates_date ON exchange_rates(rate_date DESC);

-- Підрозділи (ДЕРЕВО)
CREATE TABLE departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    short_name VARCHAR(50),
    parent_id UUID REFERENCES departments(id),
    level INT DEFAULT 0,
    path TEXT, -- 'DEP01/DEP02/DEP03'
    sort_order INT DEFAULT 0,
    is_production BOOLEAN DEFAULT false, -- виробничий підрозділ
    cost_center VARCHAR(20), -- центр витрат
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE departments IS 'Підрозділи підприємства';
CREATE INDEX idx_departments_parent ON departments(parent_id);
CREATE INDEX idx_departments_path ON departments(path);
CREATE INDEX idx_departments_level ON departments(level);

-- Склади
CREATE TABLE warehouses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    warehouse_type VARCHAR(20) NOT NULL, -- material, product, tool, scrap
    department_id UUID REFERENCES departments(id),
    address TEXT,
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE warehouses IS 'Склади';
CREATE INDEX idx_warehouses_type ON warehouses(warehouse_type);

-- Групи матеріалів (ДЕРЕВО)
CREATE TABLE material_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    parent_id UUID REFERENCES material_groups(id),
    level INT DEFAULT 0,
    path TEXT,
    sort_order INT DEFAULT 0,
    account_code VARCHAR(20), -- бухгалтерський рахунок
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE material_groups IS 'Групи матеріалів';
CREATE INDEX idx_material_groups_parent ON material_groups(parent_id);
CREATE INDEX idx_material_groups_path ON material_groups(path);

-- Марки сталі / матеріалів
CREATE TABLE material_grades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    standard VARCHAR(50), -- ДСТУ, ГОСТ, EN
    density DECIMAL(10,4), -- г/см³
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE material_grades IS 'Марки сталі та матеріалів';

-- Типи контрагентів
CREATE TABLE contractor_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    is_supplier BOOLEAN DEFAULT false,
    is_customer BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE contractor_types IS 'Типи контрагентів';

-- Категорії документів (ДЕРЕВО)
CREATE TABLE document_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    parent_id UUID REFERENCES document_categories(id),
    level INT DEFAULT 0,
    path TEXT,
    sort_order INT DEFAULT 0,
    template_path TEXT, -- шлях до шаблону
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE document_categories IS 'Категорії документів';
CREATE INDEX idx_doc_categories_parent ON document_categories(parent_id);

-- =====================================================
-- Функція автоматичного оновлення updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Тригери для автооновлення
CREATE TRIGGER update_system_settings_updated_at
    BEFORE UPDATE ON system_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_departments_updated_at
    BEFORE UPDATE ON departments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Функція для автоматичного оновлення path в деревах
-- =====================================================

CREATE OR REPLACE FUNCTION update_tree_path()
RETURNS TRIGGER AS $$
DECLARE
    parent_path TEXT;
BEGIN
    IF NEW.parent_id IS NULL THEN
        NEW.path := NEW.code;
        NEW.level := 0;
    ELSE
        SELECT path INTO parent_path FROM departments WHERE id = NEW.parent_id;
        NEW.path := parent_path || '/' || NEW.code;
        NEW.level := array_length(string_to_array(NEW.path, '/'), 1) - 1;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_departments_path
    BEFORE INSERT OR UPDATE OF parent_id, code ON departments
    FOR EACH ROW EXECUTE FUNCTION update_tree_path();

-- =====================================================
-- КІНЕЦЬ ФАЙЛУ 01
-- =====================================================
