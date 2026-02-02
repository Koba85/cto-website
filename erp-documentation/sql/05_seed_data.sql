-- =====================================================
-- ERP СИСТЕМА: Початкові дані (Seed Data)
-- =====================================================
-- Виконувати ПІСЛЯ всіх попередніх скриптів
-- =====================================================

-- =====================================================
-- СИСТЕМНІ НАЛАШТУВАННЯ
-- =====================================================

INSERT INTO system_settings (key, value, description, data_type) VALUES
('company_name', 'ТОВ "Металоконструкції"', 'Назва підприємства', 'string'),
('company_edrpou', '12345678', 'ЄДРПОУ підприємства', 'string'),
('default_currency', 'UAH', 'Валюта за замовчуванням', 'string'),
('default_vat_rate', '20', 'Ставка ПДВ за замовчуванням', 'number'),
('waste_default_percent', '15', 'Відсоток відходу за замовчуванням', 'number'),
('overhead_default_percent', '25', 'Накладні витрати за замовчуванням', 'number'),
('margin_default_percent', '20', 'Маржа за замовчуванням', 'number');

-- =====================================================
-- ОДИНИЦІ ВИМІРУ
-- =====================================================

INSERT INTO units (code, name, short_name, unit_type) VALUES
('PCS', 'Штука', 'шт', 'quantity'),
('KG', 'Кілограм', 'кг', 'weight'),
('T', 'Тонна', 'т', 'weight'),
('M', 'Метр', 'м', 'length'),
('MM', 'Міліметр', 'мм', 'length'),
('M2', 'Метр квадратний', 'м²', 'area'),
('M3', 'Метр кубічний', 'м³', 'volume'),
('L', 'Літр', 'л', 'volume'),
('H', 'Година', 'год', 'time'),
('MIN', 'Хвилина', 'хв', 'time');

-- Зв'язок між одиницями
UPDATE units SET base_unit_id = (SELECT id FROM units WHERE code = 'KG'), conversion_factor = 1000 WHERE code = 'T';
UPDATE units SET base_unit_id = (SELECT id FROM units WHERE code = 'M'), conversion_factor = 0.001 WHERE code = 'MM';
UPDATE units SET base_unit_id = (SELECT id FROM units WHERE code = 'H'), conversion_factor = 1/60.0 WHERE code = 'MIN';

-- =====================================================
-- ВАЛЮТИ
-- =====================================================

INSERT INTO currencies (code, name, symbol, decimal_places, is_base) VALUES
('UAH', 'Українська гривня', '₴', 2, true),
('USD', 'Долар США', '$', 2, false),
('EUR', 'Євро', '€', 2, false);

-- Курси валют (приклад)
INSERT INTO exchange_rates (currency_id, rate, rate_date, source)
SELECT id, 1.0, CURRENT_DATE, 'system' FROM currencies WHERE code = 'UAH'
UNION ALL
SELECT id, 41.50, CURRENT_DATE, 'НБУ' FROM currencies WHERE code = 'USD'
UNION ALL
SELECT id, 45.20, CURRENT_DATE, 'НБУ' FROM currencies WHERE code = 'EUR';

-- =====================================================
-- КРАЇНИ
-- =====================================================

INSERT INTO countries (code, code3, name) VALUES
('UA', 'UKR', 'Україна'),
('PL', 'POL', 'Польща'),
('DE', 'DEU', 'Німеччина'),
('CZ', 'CZE', 'Чехія');

-- =====================================================
-- СТАВКИ ПДВ
-- =====================================================

INSERT INTO vat_rates (name, rate, is_default, valid_from) VALUES
('Стандартна ставка', 20.00, true, '2024-01-01'),
('Пільгова ставка', 7.00, false, '2024-01-01'),
('Нульова ставка', 0.00, false, '2024-01-01'),
('Без ПДВ', 0.00, false, '2024-01-01');

-- =====================================================
-- РОЛІ КОРИСТУВАЧІВ
-- =====================================================

INSERT INTO roles (code, name, description, is_system, permissions) VALUES
('ADMIN', 'Адміністратор', 'Повний доступ до системи', true, '{"all": true}'),
('MANAGER', 'Менеджер', 'Робота з клієнтами, замовленнями', false, '{"projects": true, "contractors": true, "calculations": true}'),
('ENGINEER', 'Технолог', 'Маршрути, нормативи, калькуляції', false, '{"items": true, "routes": true, "calculations": true}'),
('FOREMAN', 'Майстер', 'Виробництво, завдання', false, '{"production": true, "tasks": true}'),
('WORKER', 'Робітник', 'Виконання завдань', false, '{"tasks": {"read": true}}'),
('ACCOUNTANT', 'Бухгалтер', 'Фінанси, документи', false, '{"documents": true, "finances": true}'),
('WAREHOUSE', 'Комірник', 'Склад, матеріали', false, '{"materials": true, "warehouses": true}');

-- =====================================================
-- ТИПИ КОНТРАГЕНТІВ
-- =====================================================

INSERT INTO contractor_types (code, name, is_supplier, is_customer) VALUES
('SUPPLIER', 'Постачальник', true, false),
('CUSTOMER', 'Клієнт', false, true),
('BOTH', 'Постачальник і клієнт', true, true),
('SUBCONTRACTOR', 'Субпідрядник', true, false);

-- =====================================================
-- ПІДРОЗДІЛИ (ДЕРЕВО)
-- =====================================================

-- Кореневі підрозділи
INSERT INTO departments (code, name, short_name, is_production, sort_order) VALUES
('DEP01', 'Виробництво', 'ВИР', true, 1),
('DEP09', 'Адміністрація', 'АДМ', false, 2),
('DEP10', 'Склад', 'СКЛ', false, 3);

-- Виробничі дільниці
INSERT INTO departments (code, name, short_name, parent_id, is_production, sort_order) VALUES
('DEP02', 'Заготівельна дільниця', 'ЗАГ', (SELECT id FROM departments WHERE code = 'DEP01'), true, 1),
('DEP03', 'Механічна дільниця', 'МЕХ', (SELECT id FROM departments WHERE code = 'DEP01'), true, 2),
('DEP04', 'Зварювальна дільниця', 'ЗВ', (SELECT id FROM departments WHERE code = 'DEP01'), true, 3),
('DEP05', 'Слюсарна дільниця', 'СЛ', (SELECT id FROM departments WHERE code = 'DEP01'), true, 4),
('DEP06', 'Складальна дільниця', 'СКЛ', (SELECT id FROM departments WHERE code = 'DEP01'), true, 5),
('DEP07', 'Фарбувальна дільниця', 'ФАР', (SELECT id FROM departments WHERE code = 'DEP01'), true, 6),
('DEP08', 'ВТК', 'ВТК', (SELECT id FROM departments WHERE code = 'DEP01'), false, 7);

-- =====================================================
-- СКЛАДИ
-- =====================================================

INSERT INTO warehouses (code, name, warehouse_type, department_id, is_default) VALUES
('WH01', 'Склад матеріалів', 'material', (SELECT id FROM departments WHERE code = 'DEP10'), true),
('WH02', 'Склад готової продукції', 'product', (SELECT id FROM departments WHERE code = 'DEP10'), false),
('WH03', 'Інструментальний склад', 'tool', (SELECT id FROM departments WHERE code = 'DEP10'), false),
('WH04', 'Склад відходів', 'scrap', (SELECT id FROM departments WHERE code = 'DEP10'), false);

-- =====================================================
-- ГРУПИ МАТЕРІАЛІВ (ДЕРЕВО)
-- =====================================================

-- Кореневі групи
INSERT INTO material_groups (code, name, sort_order) VALUES
('MG01', 'Прокат', 1),
('MG17', 'Кріплення', 2);

-- Підгрупи прокату
INSERT INTO material_groups (code, name, parent_id, sort_order) VALUES
('MG02', 'Листовий прокат', (SELECT id FROM material_groups WHERE code = 'MG01'), 1),
('MG06', 'Сортовий прокат', (SELECT id FROM material_groups WHERE code = 'MG01'), 2),
('MG10', 'Труби', (SELECT id FROM material_groups WHERE code = 'MG01'), 3),
('MG13', 'Фасонний прокат', (SELECT id FROM material_groups WHERE code = 'MG01'), 4);

-- Підгрупи листового прокату
INSERT INTO material_groups (code, name, parent_id, sort_order) VALUES
('MG03', 'Лист гарячекатаний', (SELECT id FROM material_groups WHERE code = 'MG02'), 1),
('MG04', 'Лист холоднокатаний', (SELECT id FROM material_groups WHERE code = 'MG02'), 2),
('MG05', 'Лист нержавіючий', (SELECT id FROM material_groups WHERE code = 'MG02'), 3);

-- Підгрупи сортового прокату
INSERT INTO material_groups (code, name, parent_id, sort_order) VALUES
('MG07', 'Круг', (SELECT id FROM material_groups WHERE code = 'MG06'), 1),
('MG08', 'Квадрат', (SELECT id FROM material_groups WHERE code = 'MG06'), 2),
('MG09', 'Шестигранник', (SELECT id FROM material_groups WHERE code = 'MG06'), 3);

-- Підгрупи труб
INSERT INTO material_groups (code, name, parent_id, sort_order) VALUES
('MG11', 'Труба кругла', (SELECT id FROM material_groups WHERE code = 'MG10'), 1),
('MG12', 'Труба профільна', (SELECT id FROM material_groups WHERE code = 'MG10'), 2);

-- Підгрупи кріплення
INSERT INTO material_groups (code, name, parent_id, sort_order) VALUES
('MG18', 'Болти', (SELECT id FROM material_groups WHERE code = 'MG17'), 1),
('MG19', 'Гайки', (SELECT id FROM material_groups WHERE code = 'MG17'), 2),
('MG20', 'Шайби', (SELECT id FROM material_groups WHERE code = 'MG17'), 3);

-- =====================================================
-- МАРКИ СТАЛІ
-- =====================================================

INSERT INTO material_grades (code, name, standard, density) VALUES
('S235', 'Сталь S235JR', 'EN 10025-2', 7.85),
('S355', 'Сталь S355J2', 'EN 10025-2', 7.85),
('ST3', 'Сталь Ст3', 'ДСТУ 2651', 7.85),
('09G2S', 'Сталь 09Г2С', 'ДСТУ 8541', 7.85),
('AISI304', 'Нержавіюча 08Х18Н10', 'AISI 304', 7.93),
('AISI316', 'Нержавіюча 10Х17Н13М2', 'AISI 316', 8.00);

-- =====================================================
-- МАТЕРІАЛИ (приклади)
-- =====================================================

INSERT INTO materials (code, name, full_name, group_id, grade_id, unit_id, material_type, thickness, weight_per_unit) VALUES
-- Листи
('ЛИСТ-3-S235', 'Лист 3мм S235', 'Лист гарячекатаний 3мм S235JR',
 (SELECT id FROM material_groups WHERE code = 'MG03'),
 (SELECT id FROM material_grades WHERE code = 'S235'),
 (SELECT id FROM units WHERE code = 'KG'),
 'sheet', 3.0, 23.55),

('ЛИСТ-4-S235', 'Лист 4мм S235', 'Лист гарячекатаний 4мм S235JR',
 (SELECT id FROM material_groups WHERE code = 'MG03'),
 (SELECT id FROM material_grades WHERE code = 'S235'),
 (SELECT id FROM units WHERE code = 'KG'),
 'sheet', 4.0, 31.40),

('ЛИСТ-5-S355', 'Лист 5мм S355', 'Лист гарячекатаний 5мм S355J2',
 (SELECT id FROM material_groups WHERE code = 'MG03'),
 (SELECT id FROM material_grades WHERE code = 'S355'),
 (SELECT id FROM units WHERE code = 'KG'),
 'sheet', 5.0, 39.25),

-- Круги
('КРУГ-20-S235', 'Круг 20мм S235', 'Круг калібрований 20мм S235JR',
 (SELECT id FROM material_groups WHERE code = 'MG07'),
 (SELECT id FROM material_grades WHERE code = 'S235'),
 (SELECT id FROM units WHERE code = 'KG'),
 'round', NULL, 2.466),

('КРУГ-30-S355', 'Круг 30мм S355', 'Круг калібрований 30мм S355J2',
 (SELECT id FROM material_groups WHERE code = 'MG07'),
 (SELECT id FROM material_grades WHERE code = 'S355'),
 (SELECT id FROM units WHERE code = 'KG'),
 'round', NULL, 5.549);

-- Оновлюємо діаметр для кругів
UPDATE materials SET diameter = 20.0 WHERE code = 'КРУГ-20-S235';
UPDATE materials SET diameter = 30.0 WHERE code = 'КРУГ-30-S355';

-- Кріплення
INSERT INTO materials (code, name, group_id, unit_id, material_type, weight_per_unit) VALUES
('БОЛТ-M10x30', 'Болт М10×30 8.8', (SELECT id FROM material_groups WHERE code = 'MG18'),
 (SELECT id FROM units WHERE code = 'PCS'), 'fastener', 0.035),
('БОЛТ-M12x40', 'Болт М12×40 8.8', (SELECT id FROM material_groups WHERE code = 'MG18'),
 (SELECT id FROM units WHERE code = 'PCS'), 'fastener', 0.065),
('ГАЙКА-M10', 'Гайка М10 8', (SELECT id FROM material_groups WHERE code = 'MG19'),
 (SELECT id FROM units WHERE code = 'PCS'), 'fastener', 0.012),
('ГАЙКА-M12', 'Гайка М12 8', (SELECT id FROM material_groups WHERE code = 'MG19'),
 (SELECT id FROM units WHERE code = 'PCS'), 'fastener', 0.020),
('ШАЙБА-10', 'Шайба 10', (SELECT id FROM material_groups WHERE code = 'MG20'),
 (SELECT id FROM units WHERE code = 'PCS'), 'fastener', 0.006),
('ШАЙБА-12', 'Шайба 12', (SELECT id FROM material_groups WHERE code = 'MG20'),
 (SELECT id FROM units WHERE code = 'PCS'), 'fastener', 0.010);

-- =====================================================
-- ЦІНИ МАТЕРІАЛІВ
-- =====================================================

INSERT INTO material_prices (material_id, currency_id, price, valid_from)
SELECT m.id, c.id,
    CASE
        WHEN m.code LIKE 'ЛИСТ%' THEN 32.50
        WHEN m.code LIKE 'КРУГ%' THEN 38.00
        WHEN m.code LIKE 'БОЛТ%' THEN 4.50
        WHEN m.code LIKE 'ГАЙКА%' THEN 1.80
        WHEN m.code LIKE 'ШАЙБА%' THEN 0.60
        ELSE 50.00
    END,
    CURRENT_DATE
FROM materials m
CROSS JOIN currencies c
WHERE c.code = 'UAH';

-- =====================================================
-- ОБЛАДНАННЯ
-- =====================================================

INSERT INTO equipment (code, name, equipment_type, department_id, hourly_rate, setup_time) VALUES
('EQ01', 'Гільйотина НГ-16', 'cutting', (SELECT id FROM departments WHERE code = 'DEP02'), 450.00, 15),
('EQ02', 'Плазма HYPERTHERM', 'cutting', (SELECT id FROM departments WHERE code = 'DEP02'), 850.00, 20),
('EQ03', 'Лазер TRUMPF', 'cutting', (SELECT id FROM departments WHERE code = 'DEP02'), 1200.00, 10),
('EQ04', 'Стрічкопила BOMAR', 'cutting', (SELECT id FROM departments WHERE code = 'DEP02'), 350.00, 10),
('EQ05', 'Токарний 16К20', 'turning', (SELECT id FROM departments WHERE code = 'DEP03'), 550.00, 20),
('EQ06', 'Фрезерний 6Р82', 'milling', (SELECT id FROM departments WHERE code = 'DEP03'), 600.00, 25),
('EQ07', 'Свердлильний 2Н135', 'drilling', (SELECT id FROM departments WHERE code = 'DEP03'), 300.00, 10),
('EQ08', 'Зварювальний MIG', 'welding', (SELECT id FROM departments WHERE code = 'DEP04'), 400.00, 5),
('EQ09', 'Зварювальний TIG', 'welding', (SELECT id FROM departments WHERE code = 'DEP04'), 500.00, 10),
('EQ10', 'Прес гідравлічний', 'forming', (SELECT id FROM departments WHERE code = 'DEP02'), 650.00, 15);

-- =====================================================
-- ОПЕРАЦІЇ
-- =====================================================

INSERT INTO operations (code, name, operation_type, department_id, default_equipment_id, default_setup_time) VALUES
('005', 'Різка на гільйотині', 'cutting', (SELECT id FROM departments WHERE code = 'DEP02'), (SELECT id FROM equipment WHERE code = 'EQ01'), 15),
('007', 'Різка плазмова', 'cutting', (SELECT id FROM departments WHERE code = 'DEP02'), (SELECT id FROM equipment WHERE code = 'EQ02'), 20),
('008', 'Різка лазерна', 'cutting', (SELECT id FROM departments WHERE code = 'DEP02'), (SELECT id FROM equipment WHERE code = 'EQ03'), 10),
('010', 'Слюсарна обробка', 'bench_work', (SELECT id FROM departments WHERE code = 'DEP05'), NULL, 5),
('015', 'Токарна обробка', 'turning', (SELECT id FROM departments WHERE code = 'DEP03'), (SELECT id FROM equipment WHERE code = 'EQ05'), 20),
('020', 'Фрезерна обробка', 'milling', (SELECT id FROM departments WHERE code = 'DEP03'), (SELECT id FROM equipment WHERE code = 'EQ06'), 25),
('025', 'Свердління', 'drilling', (SELECT id FROM departments WHERE code = 'DEP03'), (SELECT id FROM equipment WHERE code = 'EQ07'), 10),
('030', 'Гнуття', 'forming', (SELECT id FROM departments WHERE code = 'DEP02'), (SELECT id FROM equipment WHERE code = 'EQ10'), 15),
('035', 'Зварювання MIG/MAG', 'welding', (SELECT id FROM departments WHERE code = 'DEP04'), (SELECT id FROM equipment WHERE code = 'EQ08'), 5),
('040', 'Зварювання TIG', 'welding', (SELECT id FROM departments WHERE code = 'DEP04'), (SELECT id FROM equipment WHERE code = 'EQ09'), 10),
('050', 'Складання', 'assembly', (SELECT id FROM departments WHERE code = 'DEP06'), NULL, 10),
('055', 'Фарбування', 'painting', (SELECT id FROM departments WHERE code = 'DEP07'), NULL, 15),
('060', 'Контроль ВТК', 'inspection', (SELECT id FROM departments WHERE code = 'DEP08'), NULL, 5);

-- =====================================================
-- НОРМАТИВИ ЧАСУ
-- =====================================================

INSERT INTO time_norms (operation_id, equipment_id, material_type, thickness_from, thickness_to, setup_time, time_per_unit, time_unit) VALUES
-- Гільйотина
((SELECT id FROM operations WHERE code = '005'), (SELECT id FROM equipment WHERE code = 'EQ01'), 'sheet', 1, 3, 15, 0.3, 'min/cut'),
((SELECT id FROM operations WHERE code = '005'), (SELECT id FROM equipment WHERE code = 'EQ01'), 'sheet', 3, 6, 15, 0.5, 'min/cut'),
((SELECT id FROM operations WHERE code = '005'), (SELECT id FROM equipment WHERE code = 'EQ01'), 'sheet', 6, 12, 20, 0.8, 'min/cut'),
-- Плазма
((SELECT id FROM operations WHERE code = '007'), (SELECT id FROM equipment WHERE code = 'EQ02'), 'sheet', 1, 6, 20, 1.5, 'min/m'),
((SELECT id FROM operations WHERE code = '007'), (SELECT id FROM equipment WHERE code = 'EQ02'), 'sheet', 6, 20, 20, 2.5, 'min/m'),
-- Токарна
((SELECT id FROM operations WHERE code = '015'), (SELECT id FROM equipment WHERE code = 'EQ05'), 'round', NULL, NULL, 20, 3.0, 'min/pcs'),
-- Свердління
((SELECT id FROM operations WHERE code = '025'), (SELECT id FROM equipment WHERE code = 'EQ07'), NULL, NULL, NULL, 10, 0.5, 'min/hole'),
-- Зварювання
((SELECT id FROM operations WHERE code = '035'), (SELECT id FROM equipment WHERE code = 'EQ08'), NULL, NULL, NULL, 5, 2.0, 'min/m'),
((SELECT id FROM operations WHERE code = '040'), (SELECT id FROM equipment WHERE code = 'EQ09'), NULL, NULL, NULL, 10, 4.0, 'min/m');

-- =====================================================
-- НАКЛАДНІ ВИТРАТИ
-- =====================================================

INSERT INTO overhead_rates (code, name, rate_type, rate_value, base_type, valid_from) VALUES
('OH01', 'Загальновиробничі витрати', 'percentage', 25.0, 'labor', CURRENT_DATE),
('OH02', 'Адміністративні витрати', 'percentage', 10.0, 'total', CURRENT_DATE),
('OH03', 'Витрати на збут', 'percentage', 5.0, 'total', CURRENT_DATE),
('OH04', 'Амортизація обладнання', 'per_hour', 50.0, 'equipment_hour', CURRENT_DATE),
('OH05', 'Електроенергія', 'per_hour', 15.0, 'equipment_hour', CURRENT_DATE);

-- =====================================================
-- КОЕФІЦІЄНТИ ПАРТІЙНОСТІ
-- =====================================================

INSERT INTO batch_coefficients (name, quantity_from, quantity_to, coefficient) VALUES
('Прототип', 1, 1, 1.00),
('Мала партія', 2, 10, 0.85),
('Середня партія', 11, 50, 0.70),
('Велика партія', 51, 100, 0.60),
('Серійне виробництво', 101, NULL, 0.50);

-- =====================================================
-- КАТЕГОРІЇ ДОКУМЕНТІВ
-- =====================================================

INSERT INTO document_categories (code, name, sort_order) VALUES
('DC01', 'Комерційні документи', 1),
('DC02', 'Виробничі документи', 2),
('DC03', 'Фінансові документи', 3);

INSERT INTO document_categories (code, name, parent_id, sort_order) VALUES
('DC01-01', 'Запити', (SELECT id FROM document_categories WHERE code = 'DC01'), 1),
('DC01-02', 'Комерційні пропозиції', (SELECT id FROM document_categories WHERE code = 'DC01'), 2),
('DC01-03', 'Договори', (SELECT id FROM document_categories WHERE code = 'DC01'), 3),
('DC02-01', 'Специфікації', (SELECT id FROM document_categories WHERE code = 'DC02'), 1),
('DC02-02', 'Маршрутні карти', (SELECT id FROM document_categories WHERE code = 'DC02'), 2),
('DC02-03', 'Виробничі накази', (SELECT id FROM document_categories WHERE code = 'DC02'), 3),
('DC03-01', 'Рахунки', (SELECT id FROM document_categories WHERE code = 'DC03'), 1),
('DC03-02', 'Акти виконаних робіт', (SELECT id FROM document_categories WHERE code = 'DC03'), 2),
('DC03-03', 'Видаткові накладні', (SELECT id FROM document_categories WHERE code = 'DC03'), 3);

-- =====================================================
-- КІНЕЦЬ ФАЙЛУ 05 - SEED DATA
-- =====================================================
