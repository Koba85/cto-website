-- =====================================================
-- ERP СИСТЕМА: Матеріали та обладнання (Рівень 2-3)
-- =====================================================
-- Виконувати ПІСЛЯ 01_system_tables.sql
-- =====================================================

-- =====================================================
-- РІВЕНЬ 2: Користувачі, матеріали, обладнання
-- =====================================================

-- Користувачі системи
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    phone VARCHAR(20),
    department_id UUID REFERENCES departments(id),
    role_id UUID REFERENCES roles(id),
    position VARCHAR(100), -- посада
    hourly_rate DECIMAL(10,2), -- погодинна ставка
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE users IS 'Користувачі системи';
CREATE INDEX idx_users_department ON users(department_id);
CREATE INDEX idx_users_role ON users(role_id);
CREATE INDEX idx_users_email ON users(email);

-- Матеріали
CREATE TABLE materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    full_name TEXT, -- повна назва з характеристиками
    group_id UUID NOT NULL REFERENCES material_groups(id),
    grade_id UUID REFERENCES material_grades(id),
    unit_id UUID NOT NULL REFERENCES units(id),
    material_type VARCHAR(30) NOT NULL, -- sheet, round, tube, profile, fastener, other

    -- Характеристики для різних типів
    thickness DECIMAL(10,3), -- товщина (лист, труба)
    width DECIMAL(10,3), -- ширина (лист)
    length DECIMAL(10,3), -- довжина (лист, пруток)
    diameter DECIMAL(10,3), -- діаметр (круг, труба)
    inner_diameter DECIMAL(10,3), -- внутрішній діаметр (труба)
    wall_thickness DECIMAL(10,3), -- товщина стінки (труба, профіль)
    height DECIMAL(10,3), -- висота (профіль)
    flange_width DECIMAL(10,3), -- ширина полки (швелер, двотавр)

    -- Розрахункові параметри
    weight_per_unit DECIMAL(15,6), -- вага на одиницю (кг/м, кг/м², кг/шт)
    density DECIMAL(10,4), -- густина (г/см³)

    -- Складські параметри
    min_stock DECIMAL(15,3) DEFAULT 0, -- мінімальний залишок
    max_stock DECIMAL(15,3), -- максимальний залишок
    reorder_point DECIMAL(15,3), -- точка замовлення

    -- Службові
    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE materials IS 'Матеріали';
CREATE INDEX idx_materials_group ON materials(group_id);
CREATE INDEX idx_materials_grade ON materials(grade_id);
CREATE INDEX idx_materials_type ON materials(material_type);
CREATE INDEX idx_materials_code ON materials(code);

-- Обладнання
CREATE TABLE equipment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    equipment_type VARCHAR(30) NOT NULL, -- cutting, turning, milling, welding, grinding, etc.
    department_id UUID REFERENCES departments(id),

    -- Технічні характеристики
    model VARCHAR(100),
    manufacturer VARCHAR(100),
    year_manufactured INT,
    serial_number VARCHAR(50),

    -- Параметри для калькуляції
    hourly_rate DECIMAL(10,2) NOT NULL, -- ставка грн/год
    setup_time DECIMAL(10,2) DEFAULT 0, -- час налагодження (хв)
    efficiency_factor DECIMAL(5,2) DEFAULT 1.0, -- коефіцієнт ефективності

    -- Технічні обмеження
    max_length DECIMAL(10,2), -- макс. довжина заготовки
    max_width DECIMAL(10,2), -- макс. ширина
    max_thickness DECIMAL(10,2), -- макс. товщина
    max_diameter DECIMAL(10,2), -- макс. діаметр
    max_weight DECIMAL(10,2), -- макс. вага заготовки

    -- Статус
    status VARCHAR(20) DEFAULT 'active', -- active, maintenance, repair, inactive
    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE equipment IS 'Обладнання';
CREATE INDEX idx_equipment_type ON equipment(equipment_type);
CREATE INDEX idx_equipment_department ON equipment(department_id);
CREATE INDEX idx_equipment_status ON equipment(status);

-- Операції
CREATE TABLE operations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL, -- 005, 010, 015...
    name VARCHAR(100) NOT NULL,
    operation_type VARCHAR(30) NOT NULL, -- cutting, turning, milling, welding, assembly, etc.
    department_id UUID REFERENCES departments(id),
    default_equipment_id UUID REFERENCES equipment(id),

    -- Параметри за замовчуванням
    default_setup_time DECIMAL(10,2) DEFAULT 0, -- час налагодження (хв)
    default_time_per_unit DECIMAL(10,4), -- час на одиницю (хв/шт)

    -- Формула розрахунку часу (опціонально)
    time_formula TEXT, -- напр.: "length * 0.5 + holes * 2"

    is_active BOOLEAN DEFAULT true,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE operations IS 'Операції';
CREATE INDEX idx_operations_type ON operations(operation_type);
CREATE INDEX idx_operations_department ON operations(department_id);

-- =====================================================
-- РІВЕНЬ 3: Залежать від рівня 2
-- =====================================================

-- Розміри матеріалів (прайс-лист розмірів)
CREATE TABLE material_dimensions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
    dimension_code VARCHAR(50), -- напр.: "1000x2000", "6000"
    length DECIMAL(10,3),
    width DECIMAL(10,3),
    weight DECIMAL(15,6), -- вага одиниці даного розміру
    is_standard BOOLEAN DEFAULT true, -- стандартний розмір
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(material_id, dimension_code)
);

COMMENT ON TABLE material_dimensions IS 'Стандартні розміри матеріалів';
CREATE INDEX idx_material_dims_material ON material_dimensions(material_id);

-- Ціни матеріалів (поточні)
CREATE TABLE material_prices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
    currency_id UUID NOT NULL REFERENCES currencies(id),
    price DECIMAL(15,4) NOT NULL, -- ціна за одиницю
    price_with_vat DECIMAL(15,4), -- ціна з ПДВ
    vat_rate_id UUID REFERENCES vat_rates(id),
    min_quantity DECIMAL(15,3) DEFAULT 0, -- мін. кількість для ціни
    valid_from DATE NOT NULL,
    valid_to DATE,
    supplier_id UUID, -- буде FK на contractors
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(material_id, currency_id, valid_from, min_quantity)
);

COMMENT ON TABLE material_prices IS 'Поточні ціни матеріалів';
CREATE INDEX idx_material_prices_material ON material_prices(material_id);
CREATE INDEX idx_material_prices_valid ON material_prices(valid_from, valid_to);

-- Історія цін матеріалів
CREATE TABLE material_prices_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL REFERENCES materials(id),
    currency_id UUID NOT NULL REFERENCES currencies(id),
    price DECIMAL(15,4) NOT NULL,
    price_date DATE NOT NULL,
    source VARCHAR(50), -- supplier, manual, import
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE material_prices_history IS 'Історія цін матеріалів';
CREATE INDEX idx_material_prices_hist ON material_prices_history(material_id, price_date DESC);

-- Витратні матеріали
CREATE TABLE consumables (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    unit_id UUID NOT NULL REFERENCES units(id),
    consumable_type VARCHAR(30), -- electrode, gas, coolant, tool, abrasive
    price DECIMAL(15,4),
    currency_id UUID REFERENCES currencies(id),
    consumption_rate DECIMAL(15,6), -- норма витрат на одиницю роботи
    consumption_unit VARCHAR(20), -- kg/hour, l/hour, pcs/cut
    equipment_id UUID REFERENCES equipment(id), -- для якого обладнання
    operation_id UUID REFERENCES operations(id), -- для якої операції
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE consumables IS 'Витратні матеріали';
CREATE INDEX idx_consumables_type ON consumables(consumable_type);
CREATE INDEX idx_consumables_equipment ON consumables(equipment_id);

-- Нормативи часу
CREATE TABLE time_norms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    operation_id UUID NOT NULL REFERENCES operations(id),
    equipment_id UUID REFERENCES equipment(id),
    material_type VARCHAR(30), -- для якого типу матеріалу
    thickness_from DECIMAL(10,3), -- діапазон товщини
    thickness_to DECIMAL(10,3),

    -- Нормативи
    setup_time DECIMAL(10,2), -- час налагодження (хв)
    time_per_unit DECIMAL(10,4), -- час на одиницю (хв/шт, хв/м, хв/м²)
    time_unit VARCHAR(20) DEFAULT 'min/pcs', -- одиниця: min/pcs, min/m, min/m²

    -- Умови застосування
    condition_formula TEXT, -- умова: "thickness >= 3 AND thickness <= 10"

    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(operation_id, equipment_id, material_type, thickness_from, thickness_to)
);

COMMENT ON TABLE time_norms IS 'Нормативи часу на операції';
CREATE INDEX idx_time_norms_operation ON time_norms(operation_id);
CREATE INDEX idx_time_norms_equipment ON time_norms(equipment_id);

-- Накладні витрати
CREATE TABLE overhead_rates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    rate_type VARCHAR(20) NOT NULL, -- percentage, fixed, per_hour
    rate_value DECIMAL(10,4) NOT NULL,
    base_type VARCHAR(30), -- materials, labor, total, equipment_hour
    department_id UUID REFERENCES departments(id), -- для конкретного підрозділу
    valid_from DATE NOT NULL,
    valid_to DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE overhead_rates IS 'Ставки накладних витрат';
CREATE INDEX idx_overhead_department ON overhead_rates(department_id);

-- Партії матеріалів (для простежуваності)
CREATE TABLE material_batches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL REFERENCES materials(id),
    batch_number VARCHAR(50) NOT NULL,
    warehouse_id UUID REFERENCES warehouses(id),

    -- Кількість
    quantity_received DECIMAL(15,3) NOT NULL,
    quantity_current DECIMAL(15,3) NOT NULL,
    unit_id UUID REFERENCES units(id),

    -- Ціна
    unit_price DECIMAL(15,4),
    currency_id UUID REFERENCES currencies(id),

    -- Дати
    received_date DATE NOT NULL,
    expiry_date DATE,

    -- Документи
    supplier_id UUID, -- FK на contractors
    invoice_number VARCHAR(50),
    certificate_number VARCHAR(50), -- сертифікат якості

    status VARCHAR(20) DEFAULT 'available', -- available, reserved, consumed, blocked
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(material_id, batch_number)
);

COMMENT ON TABLE material_batches IS 'Партії матеріалів';
CREATE INDEX idx_batches_material ON material_batches(material_id);
CREATE INDEX idx_batches_warehouse ON material_batches(warehouse_id);
CREATE INDEX idx_batches_status ON material_batches(status);

-- Тригери
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_materials_updated_at
    BEFORE UPDATE ON materials
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_equipment_updated_at
    BEFORE UPDATE ON equipment
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- КІНЕЦЬ ФАЙЛУ 02
-- =====================================================
