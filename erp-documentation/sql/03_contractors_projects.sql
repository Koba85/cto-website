-- =====================================================
-- ERP СИСТЕМА: Контрагенти та проекти (Рівень 4-5)
-- =====================================================
-- Виконувати ПІСЛЯ 02_materials_equipment.sql
-- =====================================================

-- =====================================================
-- РІВЕНЬ 4: Контрагенти
-- =====================================================

-- Контрагенти (постачальники, клієнти)
CREATE TABLE contractors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    full_name TEXT, -- повна юридична назва
    contractor_type_id UUID REFERENCES contractor_types(id),

    -- Юридичні реквізити
    edrpou VARCHAR(10), -- ЄДРПОУ
    inn VARCHAR(12), -- ІПН
    vat_number VARCHAR(20), -- номер платника ПДВ
    is_vat_payer BOOLEAN DEFAULT true,

    -- Адреса
    country_id UUID REFERENCES countries(id),
    region VARCHAR(100),
    city VARCHAR(100),
    address TEXT,
    postal_code VARCHAR(10),

    -- Контакти
    phone VARCHAR(50),
    email VARCHAR(255),
    website VARCHAR(255),

    -- Банківські реквізити
    bank_name VARCHAR(200),
    bank_mfo VARCHAR(6),
    bank_account VARCHAR(29), -- IBAN

    -- Умови роботи
    payment_terms INT DEFAULT 30, -- термін оплати (днів)
    credit_limit DECIMAL(15,2), -- кредитний ліміт
    currency_id UUID REFERENCES currencies(id), -- основна валюта
    discount_percent DECIMAL(5,2) DEFAULT 0, -- знижка %

    -- Класифікація
    is_supplier BOOLEAN DEFAULT false,
    is_customer BOOLEAN DEFAULT false,
    is_subcontractor BOOLEAN DEFAULT false, -- субпідрядник (давальницька схема)

    -- Статус
    status VARCHAR(20) DEFAULT 'active', -- active, blocked, inactive
    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE contractors IS 'Контрагенти (постачальники, клієнти)';
CREATE INDEX idx_contractors_type ON contractors(contractor_type_id);
CREATE INDEX idx_contractors_country ON contractors(country_id);
CREATE INDEX idx_contractors_supplier ON contractors(is_supplier) WHERE is_supplier = true;
CREATE INDEX idx_contractors_customer ON contractors(is_customer) WHERE is_customer = true;
CREATE INDEX idx_contractors_edrpou ON contractors(edrpou);

-- Контактні особи
CREATE TABLE contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contractor_id UUID NOT NULL REFERENCES contractors(id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    position VARCHAR(100), -- посада
    department VARCHAR(100), -- відділ
    phone VARCHAR(50),
    mobile VARCHAR(50),
    email VARCHAR(255),
    is_primary BOOLEAN DEFAULT false, -- основний контакт
    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE contacts IS 'Контактні особи контрагентів';
CREATE INDEX idx_contacts_contractor ON contacts(contractor_id);
CREATE UNIQUE INDEX idx_contacts_primary ON contacts(contractor_id, is_primary)
    WHERE is_primary = true;

-- Ціни постачальників
CREATE TABLE contractor_prices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contractor_id UUID NOT NULL REFERENCES contractors(id) ON DELETE CASCADE,
    material_id UUID NOT NULL REFERENCES materials(id),
    currency_id UUID NOT NULL REFERENCES currencies(id),
    price DECIMAL(15,4) NOT NULL,
    min_quantity DECIMAL(15,3) DEFAULT 0,
    lead_time INT, -- термін поставки (днів)
    valid_from DATE NOT NULL,
    valid_to DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(contractor_id, material_id, currency_id, valid_from, min_quantity)
);

COMMENT ON TABLE contractor_prices IS 'Ціни постачальників на матеріали';
CREATE INDEX idx_contractor_prices_contractor ON contractor_prices(contractor_id);
CREATE INDEX idx_contractor_prices_material ON contractor_prices(material_id);

-- Оновлення FK для material_prices.supplier_id
ALTER TABLE material_prices
    ADD CONSTRAINT fk_material_prices_supplier
    FOREIGN KEY (supplier_id) REFERENCES contractors(id);

-- Оновлення FK для material_batches.supplier_id
ALTER TABLE material_batches
    ADD CONSTRAINT fk_material_batches_supplier
    FOREIGN KEY (supplier_id) REFERENCES contractors(id);

-- =====================================================
-- РІВЕНЬ 5: Проекти та позиції
-- =====================================================

-- Коефіцієнти партійності
CREATE TABLE batch_coefficients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    quantity_from INT NOT NULL,
    quantity_to INT,
    coefficient DECIMAL(5,3) NOT NULL, -- 1.0, 0.8, 0.6...
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(quantity_from, quantity_to)
);

COMMENT ON TABLE batch_coefficients IS 'Коефіцієнти партійності';

-- Проекти / Замовлення
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    number VARCHAR(20) UNIQUE NOT NULL, -- номер замовлення
    name VARCHAR(200) NOT NULL,
    description TEXT,

    -- Замовник
    customer_id UUID REFERENCES contractors(id),
    customer_contact_id UUID REFERENCES contacts(id),

    -- Тип та статус
    project_type VARCHAR(30) NOT NULL, -- inquiry, order, production
    status VARCHAR(30) DEFAULT 'draft', -- draft, calculation, approved, production, completed, cancelled

    -- Дати
    inquiry_date DATE, -- дата запиту
    order_date DATE, -- дата замовлення
    deadline DATE, -- термін виконання
    completion_date DATE, -- фактична дата завершення

    -- Фінанси
    currency_id UUID REFERENCES currencies(id),
    vat_rate_id UUID REFERENCES vat_rates(id),
    estimated_cost DECIMAL(15,2), -- планова собівартість
    estimated_price DECIMAL(15,2), -- планова ціна продажу
    actual_cost DECIMAL(15,2), -- фактична собівартість
    final_price DECIMAL(15,2), -- фінальна ціна

    -- Коефіцієнти
    batch_size INT DEFAULT 1, -- розмір партії
    batch_coefficient DECIMAL(5,3) DEFAULT 1.0,
    urgency_coefficient DECIMAL(5,3) DEFAULT 1.0, -- коеф. терміновості
    complexity_coefficient DECIMAL(5,3) DEFAULT 1.0, -- коеф. складності
    margin_coefficient DECIMAL(5,3) DEFAULT 1.0, -- коеф. маржі

    -- Відповідальні
    manager_id UUID REFERENCES users(id), -- менеджер
    engineer_id UUID REFERENCES users(id), -- технолог

    -- Службові
    priority INT DEFAULT 5, -- 1-10 (1 = найвищий)
    is_export BOOLEAN DEFAULT false, -- експортне замовлення
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE projects IS 'Проекти / Замовлення';
CREATE INDEX idx_projects_customer ON projects(customer_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_type ON projects(project_type);
CREATE INDEX idx_projects_deadline ON projects(deadline);
CREATE INDEX idx_projects_number ON projects(number);

-- Позиції / Деталі виробу (ДЕРЕВО)
CREATE TABLE items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,

    -- Ідентифікація
    designation VARCHAR(50) NOT NULL, -- позначення (креслення)
    name VARCHAR(200) NOT NULL,
    position_number VARCHAR(20), -- позиція в специфікації

    -- Ієрархія (дерево)
    parent_id UUID REFERENCES items(id),
    level INT DEFAULT 0,
    path TEXT, -- 'I001/I002/I003'
    sort_order INT DEFAULT 0,

    -- Тип позиції
    item_type VARCHAR(20) NOT NULL, -- assembly, part, standard, purchased

    -- Кількість
    quantity DECIMAL(15,3) NOT NULL DEFAULT 1,
    unit_id UUID REFERENCES units(id),

    -- Матеріал (для деталей)
    material_id UUID REFERENCES materials(id),
    blank_length DECIMAL(10,3), -- довжина заготовки
    blank_width DECIMAL(10,3), -- ширина заготовки
    blank_weight DECIMAL(15,6), -- вага заготовки
    calculated_weight DECIMAL(15,6), -- розрахована чиста вага
    waste_percent DECIMAL(5,2) DEFAULT 0, -- % відходу

    -- Вартість (розрахована)
    material_cost DECIMAL(15,4), -- вартість матеріалу
    labor_cost DECIMAL(15,4), -- вартість роботи
    overhead_cost DECIMAL(15,4), -- накладні
    total_cost DECIMAL(15,4), -- загальна собівартість
    unit_price DECIMAL(15,4), -- ціна за одиницю

    -- DXF дані
    dxf_file_path TEXT, -- шлях до файлу
    dxf_area DECIMAL(15,6), -- площа з DXF
    dxf_perimeter DECIMAL(15,6), -- периметр з DXF
    dxf_holes_count INT, -- кількість отворів

    -- Статус
    status VARCHAR(20) DEFAULT 'draft', -- draft, calculated, approved, production, completed

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(project_id, designation)
);

COMMENT ON TABLE items IS 'Позиції / Деталі виробу';
CREATE INDEX idx_items_project ON items(project_id);
CREATE INDEX idx_items_parent ON items(parent_id);
CREATE INDEX idx_items_path ON items(path);
CREATE INDEX idx_items_material ON items(material_id);
CREATE INDEX idx_items_type ON items(item_type);
CREATE INDEX idx_items_designation ON items(designation);

-- Документи
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    number VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    category_id UUID NOT NULL REFERENCES document_categories(id),

    -- Зв'язки
    project_id UUID REFERENCES projects(id),
    item_id UUID REFERENCES items(id),
    contractor_id UUID REFERENCES contractors(id),

    -- Тип документа
    document_type VARCHAR(30) NOT NULL, -- inquiry, proposal, contract, invoice, act, etc.
    status VARCHAR(20) DEFAULT 'draft', -- draft, pending, approved, signed, cancelled

    -- Дати
    document_date DATE NOT NULL,
    valid_from DATE,
    valid_to DATE,

    -- Суми
    amount DECIMAL(15,2),
    currency_id UUID REFERENCES currencies(id),
    vat_amount DECIMAL(15,2),
    total_amount DECIMAL(15,2),

    -- Файли
    file_path TEXT,
    file_name VARCHAR(255),

    -- Відповідальні
    created_by UUID REFERENCES users(id),
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP,

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE documents IS 'Документи';
CREATE INDEX idx_documents_category ON documents(category_id);
CREATE INDEX idx_documents_project ON documents(project_id);
CREATE INDEX idx_documents_contractor ON documents(contractor_id);
CREATE INDEX idx_documents_type ON documents(document_type);
CREATE INDEX idx_documents_status ON documents(status);
CREATE INDEX idx_documents_date ON documents(document_date);

-- Тригери
CREATE TRIGGER update_contractors_updated_at
    BEFORE UPDATE ON contractors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at
    BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_items_updated_at
    BEFORE UPDATE ON items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_documents_updated_at
    BEFORE UPDATE ON documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Функція для оновлення path в items
CREATE OR REPLACE FUNCTION update_items_path()
RETURNS TRIGGER AS $$
DECLARE
    parent_path TEXT;
BEGIN
    IF NEW.parent_id IS NULL THEN
        NEW.path := NEW.designation;
        NEW.level := 0;
    ELSE
        SELECT path INTO parent_path FROM items WHERE id = NEW.parent_id;
        NEW.path := parent_path || '/' || NEW.designation;
        NEW.level := array_length(string_to_array(NEW.path, '/'), 1) - 1;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_items_path_trigger
    BEFORE INSERT OR UPDATE OF parent_id, designation ON items
    FOR EACH ROW EXECUTE FUNCTION update_items_path();

-- =====================================================
-- КІНЕЦЬ ФАЙЛУ 03
-- =====================================================
