-- =====================================================
-- ERP СИСТЕМА: Виробництво та документи (Рівень 6-10)
-- =====================================================
-- Виконувати ПІСЛЯ 03_contractors_projects.sql
-- =====================================================

-- =====================================================
-- РІВЕНЬ 6: Маршрути, калькуляції, версії
-- =====================================================

-- Маршрути виготовлення
CREATE TABLE item_routes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    route_number INT DEFAULT 1, -- номер маршруту (може бути альтернативний)
    is_primary BOOLEAN DEFAULT true, -- основний маршрут
    total_setup_time DECIMAL(10,2), -- загальний час налагодження
    total_operation_time DECIMAL(10,2), -- загальний час операцій
    total_time DECIMAL(10,2), -- загальний час
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(item_id, route_number)
);

COMMENT ON TABLE item_routes IS 'Маршрути виготовлення';
CREATE INDEX idx_item_routes_item ON item_routes(item_id);

-- Калькуляції
CREATE TABLE calculations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id),
    calculation_number VARCHAR(30) NOT NULL,
    name VARCHAR(200),

    -- Тип калькуляції
    calculation_type VARCHAR(20) NOT NULL, -- preliminary, working, actual
    version INT DEFAULT 1,
    status VARCHAR(20) DEFAULT 'draft', -- draft, calculated, approved

    -- Параметри
    batch_size INT DEFAULT 1,
    batch_coefficient DECIMAL(5,3) DEFAULT 1.0,
    urgency_coefficient DECIMAL(5,3) DEFAULT 1.0,
    complexity_coefficient DECIMAL(5,3) DEFAULT 1.0,
    margin_coefficient DECIMAL(5,3) DEFAULT 1.0,

    -- Суми
    currency_id UUID REFERENCES currencies(id),
    material_cost DECIMAL(15,2), -- матеріали
    labor_cost DECIMAL(15,2), -- робота
    overhead_cost DECIMAL(15,2), -- накладні
    total_cost DECIMAL(15,2), -- собівартість
    margin_amount DECIMAL(15,2), -- маржа
    price_without_vat DECIMAL(15,2), -- ціна без ПДВ
    vat_rate_id UUID REFERENCES vat_rates(id),
    vat_amount DECIMAL(15,2),
    price_with_vat DECIMAL(15,2), -- ціна з ПДВ

    -- Ціна за одиницю
    unit_price DECIMAL(15,4), -- ціна за 1 шт з ПДВ
    unit_cost DECIMAL(15,4), -- собівартість за 1 шт

    -- Відповідальні
    calculated_by UUID REFERENCES users(id),
    calculated_at TIMESTAMP,
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP,

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(project_id, calculation_number, version)
);

COMMENT ON TABLE calculations IS 'Калькуляції';
CREATE INDEX idx_calculations_project ON calculations(project_id);
CREATE INDEX idx_calculations_type ON calculations(calculation_type);
CREATE INDEX idx_calculations_status ON calculations(status);

-- Версії документів
CREATE TABLE document_versions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    version_number INT NOT NULL,
    file_path TEXT,
    file_name VARCHAR(255),
    file_size BIGINT,
    changes_description TEXT, -- опис змін
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(document_id, version_number)
);

COMMENT ON TABLE document_versions IS 'Версії документів';
CREATE INDEX idx_doc_versions_document ON document_versions(document_id);

-- =====================================================
-- РІВЕНЬ 7: Операції, матеріали, виробничі замовлення
-- =====================================================

-- Операції маршруту
CREATE TABLE item_operations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    route_id UUID NOT NULL REFERENCES item_routes(id) ON DELETE CASCADE,
    operation_id UUID NOT NULL REFERENCES operations(id),
    equipment_id UUID REFERENCES equipment(id),
    department_id UUID REFERENCES departments(id),

    -- Послідовність
    sequence_number INT NOT NULL, -- 005, 010, 015...
    sort_order INT DEFAULT 0,

    -- Час
    setup_time DECIMAL(10,2) DEFAULT 0, -- час налагодження (хв)
    time_per_unit DECIMAL(10,4) NOT NULL, -- час на одиницю (хв)
    total_time DECIMAL(10,2), -- загальний час = setup + (time_per_unit * quantity)

    -- Вартість
    hourly_rate DECIMAL(10,2), -- ставка верстата
    operation_cost DECIMAL(15,4), -- вартість операції

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(route_id, sequence_number)
);

COMMENT ON TABLE item_operations IS 'Операції маршруту';
CREATE INDEX idx_item_ops_route ON item_operations(route_id);
CREATE INDEX idx_item_ops_operation ON item_operations(operation_id);
CREATE INDEX idx_item_ops_equipment ON item_operations(equipment_id);

-- Матеріали позиції
CREATE TABLE item_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    material_id UUID NOT NULL REFERENCES materials(id),

    -- Кількість
    quantity DECIMAL(15,6) NOT NULL, -- кількість матеріалу
    unit_id UUID REFERENCES units(id),
    waste_percent DECIMAL(5,2) DEFAULT 0, -- % відходу
    gross_quantity DECIMAL(15,6), -- кількість з урахуванням відходу

    -- Вартість
    unit_price DECIMAL(15,4), -- ціна за одиницю
    total_cost DECIMAL(15,4), -- загальна вартість

    -- Інше
    is_main BOOLEAN DEFAULT true, -- основний матеріал
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(item_id, material_id)
);

COMMENT ON TABLE item_materials IS 'Матеріали позиції';
CREATE INDEX idx_item_materials_item ON item_materials(item_id);
CREATE INDEX idx_item_materials_material ON item_materials(material_id);

-- Деталізація калькуляції
CREATE TABLE calculation_details (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    calculation_id UUID NOT NULL REFERENCES calculations(id) ON DELETE CASCADE,
    item_id UUID REFERENCES items(id),

    -- Тип рядка
    detail_type VARCHAR(20) NOT NULL, -- material, labor, overhead, total
    description TEXT,

    -- Суми
    quantity DECIMAL(15,6),
    unit_price DECIMAL(15,4),
    amount DECIMAL(15,4) NOT NULL,

    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE calculation_details IS 'Деталізація калькуляції';
CREATE INDEX idx_calc_details_calc ON calculation_details(calculation_id);
CREATE INDEX idx_calc_details_item ON calculation_details(item_id);

-- Виробничі замовлення
CREATE TABLE production_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    number VARCHAR(30) UNIQUE NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id),

    -- Тип
    order_type VARCHAR(20) DEFAULT 'standard', -- standard, urgent, rework
    status VARCHAR(20) DEFAULT 'planned', -- planned, released, in_progress, completed, cancelled
    priority INT DEFAULT 5,

    -- Кількість
    planned_quantity DECIMAL(15,3) NOT NULL,
    completed_quantity DECIMAL(15,3) DEFAULT 0,
    defect_quantity DECIMAL(15,3) DEFAULT 0,

    -- Дати
    planned_start DATE,
    planned_end DATE,
    actual_start TIMESTAMP,
    actual_end TIMESTAMP,

    -- Відповідальні
    department_id UUID REFERENCES departments(id),
    foreman_id UUID REFERENCES users(id), -- майстер

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE production_orders IS 'Виробничі замовлення';
CREATE INDEX idx_prod_orders_project ON production_orders(project_id);
CREATE INDEX idx_prod_orders_status ON production_orders(status);
CREATE INDEX idx_prod_orders_department ON production_orders(department_id);

-- =====================================================
-- РІВЕНЬ 8: Виробничі завдання, відвантаження, якість
-- =====================================================

-- Виробничі завдання
CREATE TABLE production_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    production_order_id UUID NOT NULL REFERENCES production_orders(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES items(id),
    operation_id UUID REFERENCES operations(id),
    equipment_id UUID REFERENCES equipment(id),

    -- Статус
    status VARCHAR(20) DEFAULT 'pending', -- pending, in_progress, completed, paused

    -- Кількість
    planned_quantity DECIMAL(15,3) NOT NULL,
    completed_quantity DECIMAL(15,3) DEFAULT 0,
    defect_quantity DECIMAL(15,3) DEFAULT 0,

    -- Час
    planned_time DECIMAL(10,2), -- плановий час (хв)
    actual_time DECIMAL(10,2), -- фактичний час (хв)

    -- Дати
    planned_start TIMESTAMP,
    planned_end TIMESTAMP,
    actual_start TIMESTAMP,
    actual_end TIMESTAMP,

    -- Виконавець
    worker_id UUID REFERENCES users(id),

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE production_tasks IS 'Виробничі завдання';
CREATE INDEX idx_prod_tasks_order ON production_tasks(production_order_id);
CREATE INDEX idx_prod_tasks_item ON production_tasks(item_id);
CREATE INDEX idx_prod_tasks_status ON production_tasks(status);
CREATE INDEX idx_prod_tasks_worker ON production_tasks(worker_id);

-- Відвантаження
CREATE TABLE shipments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    number VARCHAR(30) UNIQUE NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id),
    customer_id UUID REFERENCES contractors(id),

    -- Статус
    status VARCHAR(20) DEFAULT 'planned', -- planned, ready, shipped, delivered

    -- Дати
    planned_date DATE,
    actual_date DATE,

    -- Доставка
    delivery_type VARCHAR(20), -- pickup, delivery, courier
    delivery_address TEXT,
    carrier VARCHAR(100),
    tracking_number VARCHAR(50),

    -- Документи
    invoice_id UUID REFERENCES documents(id),
    waybill_id UUID REFERENCES documents(id), -- ТТН

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE shipments IS 'Відвантаження';
CREATE INDEX idx_shipments_project ON shipments(project_id);
CREATE INDEX idx_shipments_customer ON shipments(customer_id);
CREATE INDEX idx_shipments_status ON shipments(status);

-- Перевірки якості
CREATE TABLE quality_checks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID NOT NULL REFERENCES items(id),
    production_task_id UUID REFERENCES production_tasks(id),
    batch_id UUID REFERENCES material_batches(id),

    -- Тип перевірки
    check_type VARCHAR(30) NOT NULL, -- incoming, in_process, final
    status VARCHAR(20) DEFAULT 'pending', -- pending, passed, failed, conditional

    -- Результати
    check_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    checked_quantity DECIMAL(15,3),
    passed_quantity DECIMAL(15,3),
    failed_quantity DECIMAL(15,3),

    -- Параметри
    parameters JSONB, -- виміряні параметри
    requirements JSONB, -- вимоги

    -- Виконавець
    inspector_id UUID REFERENCES users(id),

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE quality_checks IS 'Перевірки якості';
CREATE INDEX idx_quality_item ON quality_checks(item_id);
CREATE INDEX idx_quality_task ON quality_checks(production_task_id);
CREATE INDEX idx_quality_type ON quality_checks(check_type);

-- =====================================================
-- РІВЕНЬ 9: Облік часу, дефекти, серійні номери
-- =====================================================

-- Облік робочого часу
CREATE TABLE work_time_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    production_task_id UUID NOT NULL REFERENCES production_tasks(id),
    worker_id UUID NOT NULL REFERENCES users(id),
    equipment_id UUID REFERENCES equipment(id),

    -- Час
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    duration_minutes DECIMAL(10,2), -- тривалість (хв)

    -- Робота
    work_type VARCHAR(20) DEFAULT 'production', -- production, setup, maintenance, idle
    quantity_produced DECIMAL(15,3), -- вироблена кількість

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE work_time_log IS 'Облік робочого часу';
CREATE INDEX idx_work_time_task ON work_time_log(production_task_id);
CREATE INDEX idx_work_time_worker ON work_time_log(worker_id);
CREATE INDEX idx_work_time_date ON work_time_log(start_time);

-- Позиції відвантаження
CREATE TABLE shipment_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shipment_id UUID NOT NULL REFERENCES shipments(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES items(id),
    quantity DECIMAL(15,3) NOT NULL,
    serial_numbers TEXT[], -- масив серійних номерів
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(shipment_id, item_id)
);

COMMENT ON TABLE shipment_items IS 'Позиції відвантаження';
CREATE INDEX idx_shipment_items_shipment ON shipment_items(shipment_id);
CREATE INDEX idx_shipment_items_item ON shipment_items(item_id);

-- Дефекти
CREATE TABLE defects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quality_check_id UUID REFERENCES quality_checks(id),
    item_id UUID NOT NULL REFERENCES items(id),
    production_task_id UUID REFERENCES production_tasks(id),

    -- Опис
    defect_type VARCHAR(50) NOT NULL, -- dimension, surface, weld, material, assembly
    description TEXT NOT NULL,
    severity VARCHAR(20) DEFAULT 'minor', -- minor, major, critical

    -- Кількість
    quantity DECIMAL(15,3) DEFAULT 1,

    -- Рішення
    decision VARCHAR(20), -- repair, scrap, accept_deviation
    repair_notes TEXT,

    -- Виконавці
    detected_by UUID REFERENCES users(id),
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_by UUID REFERENCES users(id),
    resolved_at TIMESTAMP,

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE defects IS 'Дефекти';
CREATE INDEX idx_defects_item ON defects(item_id);
CREATE INDEX idx_defects_task ON defects(production_task_id);
CREATE INDEX idx_defects_type ON defects(defect_type);

-- Серійні номери
CREATE TABLE serial_numbers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID NOT NULL REFERENCES items(id),
    serial_number VARCHAR(50) UNIQUE NOT NULL,
    production_order_id UUID REFERENCES production_orders(id),

    -- Статус
    status VARCHAR(20) DEFAULT 'produced', -- produced, shipped, installed, returned

    -- Дати
    production_date DATE,
    shipment_date DATE,
    warranty_start DATE,
    warranty_end DATE,

    -- Відстеження
    shipment_id UUID REFERENCES shipments(id),
    customer_id UUID REFERENCES contractors(id),

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE serial_numbers IS 'Серійні номери';
CREATE INDEX idx_serial_item ON serial_numbers(item_id);
CREATE INDEX idx_serial_number ON serial_numbers(serial_number);
CREATE INDEX idx_serial_order ON serial_numbers(production_order_id);

-- =====================================================
-- РІВЕНЬ 10: Аудит
-- =====================================================

-- Журнал аудиту
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL, -- INSERT, UPDATE, DELETE
    old_data JSONB,
    new_data JSONB,
    changed_fields TEXT[], -- список змінених полів
    user_id UUID REFERENCES users(id),
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE audit_log IS 'Журнал аудиту змін';
CREATE INDEX idx_audit_table ON audit_log(table_name);
CREATE INDEX idx_audit_record ON audit_log(record_id);
CREATE INDEX idx_audit_user ON audit_log(user_id);
CREATE INDEX idx_audit_date ON audit_log(created_at);
CREATE INDEX idx_audit_action ON audit_log(action);

-- Погодження документів
CREATE TABLE document_approvals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    step_number INT NOT NULL, -- порядок погодження
    approver_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'pending', -- pending, approved, rejected
    comments TEXT,
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(document_id, step_number)
);

COMMENT ON TABLE document_approvals IS 'Погодження документів';
CREATE INDEX idx_doc_approvals_document ON document_approvals(document_id);
CREATE INDEX idx_doc_approvals_approver ON document_approvals(approver_id);
CREATE INDEX idx_doc_approvals_status ON document_approvals(status);

-- Тригери для оновлення updated_at
CREATE TRIGGER update_calculations_updated_at
    BEFORE UPDATE ON calculations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_production_orders_updated_at
    BEFORE UPDATE ON production_orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_production_tasks_updated_at
    BEFORE UPDATE ON production_tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shipments_updated_at
    BEFORE UPDATE ON shipments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Функція аудиту (опціонально)
-- =====================================================

CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, record_id, action, old_data)
        VALUES (TG_TABLE_NAME, OLD.id, 'DELETE', to_jsonb(OLD));
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, record_id, action, old_data, new_data)
        VALUES (TG_TABLE_NAME, NEW.id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, record_id, action, new_data)
        VALUES (TG_TABLE_NAME, NEW.id, 'INSERT', to_jsonb(NEW));
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Приклад: додати аудит для таблиці projects
-- CREATE TRIGGER audit_projects
--     AFTER INSERT OR UPDATE OR DELETE ON projects
--     FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

-- =====================================================
-- КІНЕЦЬ ФАЙЛУ 04
-- =====================================================
