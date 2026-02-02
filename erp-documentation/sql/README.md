# SQL-скрипти для ERP-системи

## Порядок виконання

Скрипти необхідно виконувати **строго в такому порядку**:

```
1. 01_system_tables.sql     - Системні таблиці (рівень 0-1)
2. 02_materials_equipment.sql - Матеріали, обладнання (рівень 2-3)
3. 03_contractors_projects.sql - Контрагенти, проекти (рівень 4-5)
4. 04_production.sql        - Виробництво, документи (рівень 6-10)
5. 05_seed_data.sql         - Початкові дані
```

## Швидкий старт

### Варіант 1: Локальний PostgreSQL

```bash
# Створити базу даних
createdb erp_system

# Виконати скрипти по черзі
psql -d erp_system -f 01_system_tables.sql
psql -d erp_system -f 02_materials_equipment.sql
psql -d erp_system -f 03_contractors_projects.sql
psql -d erp_system -f 04_production.sql
psql -d erp_system -f 05_seed_data.sql
```

### Варіант 2: Supabase (хмарний)

1. Створіть проект на [supabase.com](https://supabase.com)
2. Перейдіть в SQL Editor
3. Виконайте кожен скрипт по черзі

### Варіант 3: Neon.tech (хмарний)

1. Створіть проект на [neon.tech](https://neon.tech)
2. Використайте SQL Editor або підключіться через psql
3. Виконайте скрипти по черзі

## Що створюється

### Таблиці (60+)

| Файл | Таблиці |
|------|---------|
| 01 | system_settings, units, currencies, exchange_rates, countries, vat_rates, roles, departments, warehouses, material_groups, material_grades, contractor_types, document_categories |
| 02 | users, materials, equipment, operations, material_dimensions, material_prices, material_prices_history, consumables, time_norms, overhead_rates, material_batches |
| 03 | contractors, contacts, contractor_prices, batch_coefficients, projects, items, documents |
| 04 | item_routes, calculations, document_versions, item_operations, item_materials, calculation_details, production_orders, production_tasks, shipments, quality_checks, work_time_log, shipment_items, defects, serial_numbers, audit_log, document_approvals |

### Функції та тригери

- `update_updated_at_column()` - автооновлення дати зміни
- `update_tree_path()` - автопідрахунок path та level для дерев
- `update_items_path()` - path для структури виробу
- `audit_trigger_function()` - журналювання змін

### Початкові дані (05_seed_data.sql)

- 7 системних налаштувань
- 10 одиниць виміру
- 3 валюти + курси
- 4 країни
- 4 ставки ПДВ
- 7 ролей
- 4 типи контрагентів
- 10 підрозділів (дерево)
- 4 склади
- 14 груп матеріалів (дерево)
- 6 марок сталі
- 11 матеріалів з цінами
- 10 одиниць обладнання
- 13 операцій
- 9 нормативів часу
- 5 накладних витрат
- 5 коефіцієнтів партійності
- 12 категорій документів

## Перевірка після встановлення

```sql
-- Перевірити кількість таблиць
SELECT count(*) FROM information_schema.tables
WHERE table_schema = 'public';

-- Перевірити дерево підрозділів
SELECT code, name, level, path
FROM departments
ORDER BY path;

-- Перевірити дерево груп матеріалів
SELECT code, name, level, path
FROM material_groups
ORDER BY path;

-- Перевірити матеріали з цінами
SELECT m.code, m.name, mp.price
FROM materials m
LEFT JOIN material_prices mp ON m.id = mp.material_id
WHERE mp.is_active = true;
```

## Видалення бази

```sql
-- УВАГА: це видалить ВСІ дані!
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO public;
```

## Резервне копіювання

```bash
# Створити бекап
pg_dump -d erp_system > backup_$(date +%Y%m%d).sql

# Відновити з бекапу
psql -d erp_system < backup_20240101.sql
```
