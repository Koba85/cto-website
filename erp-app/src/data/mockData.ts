// Тестові дані для демонстрації ERP системи

export interface Department {
  id: string;
  code: string;
  name: string;
  shortName: string;
  parentId: string | null;
  level: number;
  path: string;
  isProduction: boolean;
}

export interface MaterialGroup {
  id: string;
  code: string;
  name: string;
  parentId: string | null;
  level: number;
  path: string;
}

export interface Material {
  id: string;
  code: string;
  name: string;
  groupId: string;
  groupName: string;
  materialType: string;
  thickness?: number;
  diameter?: number;
  unit: string;
  price: number;
  stock: number;
}

export interface Equipment {
  id: string;
  code: string;
  name: string;
  type: string;
  department: string;
  hourlyRate: number;
  status: 'active' | 'maintenance' | 'repair';
}

export interface Operation {
  id: string;
  code: string;
  name: string;
  type: string;
  department: string;
  defaultEquipment: string;
  setupTime: number;
}

export interface Project {
  id: string;
  number: string;
  name: string;
  customer: string;
  status: 'draft' | 'calculation' | 'approved' | 'production' | 'completed';
  deadline: string;
  estimatedCost: number;
  batchSize: number;
}

// Підрозділи
export const departments: Department[] = [
  { id: '1', code: 'DEP01', name: 'Виробництво', shortName: 'ВИР', parentId: null, level: 0, path: 'DEP01', isProduction: true },
  { id: '2', code: 'DEP02', name: 'Заготівельна дільниця', shortName: 'ЗАГ', parentId: '1', level: 1, path: 'DEP01/DEP02', isProduction: true },
  { id: '3', code: 'DEP03', name: 'Механічна дільниця', shortName: 'МЕХ', parentId: '1', level: 1, path: 'DEP01/DEP03', isProduction: true },
  { id: '4', code: 'DEP04', name: 'Зварювальна дільниця', shortName: 'ЗВ', parentId: '1', level: 1, path: 'DEP01/DEP04', isProduction: true },
  { id: '5', code: 'DEP05', name: 'Слюсарна дільниця', shortName: 'СЛ', parentId: '1', level: 1, path: 'DEP01/DEP05', isProduction: true },
  { id: '6', code: 'DEP06', name: 'Складальна дільниця', shortName: 'СКЛ', parentId: '1', level: 1, path: 'DEP01/DEP06', isProduction: true },
  { id: '7', code: 'DEP07', name: 'Фарбувальна дільниця', shortName: 'ФАР', parentId: '1', level: 1, path: 'DEP01/DEP07', isProduction: true },
  { id: '8', code: 'DEP08', name: 'ВТК', shortName: 'ВТК', parentId: '1', level: 1, path: 'DEP01/DEP08', isProduction: false },
  { id: '9', code: 'DEP09', name: 'Адміністрація', shortName: 'АДМ', parentId: null, level: 0, path: 'DEP09', isProduction: false },
  { id: '10', code: 'DEP10', name: 'Склад', shortName: 'СКЛ', parentId: null, level: 0, path: 'DEP10', isProduction: false },
];

// Групи матеріалів
export const materialGroups: MaterialGroup[] = [
  { id: '1', code: 'MG01', name: 'Прокат', parentId: null, level: 0, path: 'MG01' },
  { id: '2', code: 'MG02', name: 'Листовий прокат', parentId: '1', level: 1, path: 'MG01/MG02' },
  { id: '3', code: 'MG03', name: 'Лист гарячекатаний', parentId: '2', level: 2, path: 'MG01/MG02/MG03' },
  { id: '4', code: 'MG04', name: 'Лист холоднокатаний', parentId: '2', level: 2, path: 'MG01/MG02/MG04' },
  { id: '5', code: 'MG05', name: 'Лист нержавіючий', parentId: '2', level: 2, path: 'MG01/MG02/MG05' },
  { id: '6', code: 'MG06', name: 'Сортовий прокат', parentId: '1', level: 1, path: 'MG01/MG06' },
  { id: '7', code: 'MG07', name: 'Круг', parentId: '6', level: 2, path: 'MG01/MG06/MG07' },
  { id: '8', code: 'MG10', name: 'Труби', parentId: '1', level: 1, path: 'MG01/MG10' },
  { id: '9', code: 'MG17', name: 'Кріплення', parentId: null, level: 0, path: 'MG17' },
  { id: '10', code: 'MG18', name: 'Болти', parentId: '9', level: 1, path: 'MG17/MG18' },
  { id: '11', code: 'MG19', name: 'Гайки', parentId: '9', level: 1, path: 'MG17/MG19' },
  { id: '12', code: 'MG20', name: 'Шайби', parentId: '9', level: 1, path: 'MG17/MG20' },
];

// Матеріали
export const materials: Material[] = [
  { id: '1', code: 'ЛИСТ-3-S235', name: 'Лист 3мм S235', groupId: '3', groupName: 'Лист гарячекатаний', materialType: 'sheet', thickness: 3, unit: 'кг', price: 32.50, stock: 1250 },
  { id: '2', code: 'ЛИСТ-4-S235', name: 'Лист 4мм S235', groupId: '3', groupName: 'Лист гарячекатаний', materialType: 'sheet', thickness: 4, unit: 'кг', price: 32.50, stock: 2100 },
  { id: '3', code: 'ЛИСТ-5-S355', name: 'Лист 5мм S355', groupId: '3', groupName: 'Лист гарячекатаний', materialType: 'sheet', thickness: 5, unit: 'кг', price: 35.00, stock: 850 },
  { id: '4', code: 'ЛИСТ-6-S235', name: 'Лист 6мм S235', groupId: '3', groupName: 'Лист гарячекатаний', materialType: 'sheet', thickness: 6, unit: 'кг', price: 32.50, stock: 1500 },
  { id: '5', code: 'ЛИСТ-8-S355', name: 'Лист 8мм S355', groupId: '3', groupName: 'Лист гарячекатаний', materialType: 'sheet', thickness: 8, unit: 'кг', price: 35.00, stock: 920 },
  { id: '6', code: 'КРУГ-20-S235', name: 'Круг 20мм S235', groupId: '7', groupName: 'Круг', materialType: 'round', diameter: 20, unit: 'кг', price: 38.00, stock: 450 },
  { id: '7', code: 'КРУГ-30-S355', name: 'Круг 30мм S355', groupId: '7', groupName: 'Круг', materialType: 'round', diameter: 30, unit: 'кг', price: 40.00, stock: 380 },
  { id: '8', code: 'БОЛТ-M10x30', name: 'Болт М10×30 8.8', groupId: '10', groupName: 'Болти', materialType: 'fastener', unit: 'шт', price: 4.50, stock: 5000 },
  { id: '9', code: 'БОЛТ-M12x40', name: 'Болт М12×40 8.8', groupId: '10', groupName: 'Болти', materialType: 'fastener', unit: 'шт', price: 6.50, stock: 3200 },
  { id: '10', code: 'ГАЙКА-M10', name: 'Гайка М10', groupId: '11', groupName: 'Гайки', materialType: 'fastener', unit: 'шт', price: 1.80, stock: 8000 },
  { id: '11', code: 'ГАЙКА-M12', name: 'Гайка М12', groupId: '11', groupName: 'Гайки', materialType: 'fastener', unit: 'шт', price: 2.50, stock: 6500 },
  { id: '12', code: 'ШАЙБА-10', name: 'Шайба 10', groupId: '12', groupName: 'Шайби', materialType: 'fastener', unit: 'шт', price: 0.60, stock: 12000 },
];

// Обладнання
export const equipment: Equipment[] = [
  { id: '1', code: 'EQ01', name: 'Гільйотина НГ-16', type: 'cutting', department: 'Заготівельна дільниця', hourlyRate: 450, status: 'active' },
  { id: '2', code: 'EQ02', name: 'Плазма HYPERTHERM', type: 'cutting', department: 'Заготівельна дільниця', hourlyRate: 850, status: 'active' },
  { id: '3', code: 'EQ03', name: 'Лазер TRUMPF', type: 'cutting', department: 'Заготівельна дільниця', hourlyRate: 1200, status: 'maintenance' },
  { id: '4', code: 'EQ04', name: 'Стрічкопила BOMAR', type: 'cutting', department: 'Заготівельна дільниця', hourlyRate: 350, status: 'active' },
  { id: '5', code: 'EQ05', name: 'Токарний 16К20', type: 'turning', department: 'Механічна дільниця', hourlyRate: 550, status: 'active' },
  { id: '6', code: 'EQ06', name: 'Фрезерний 6Р82', type: 'milling', department: 'Механічна дільниця', hourlyRate: 600, status: 'active' },
  { id: '7', code: 'EQ07', name: 'Свердлильний 2Н135', type: 'drilling', department: 'Механічна дільниця', hourlyRate: 300, status: 'active' },
  { id: '8', code: 'EQ08', name: 'Зварювальний MIG', type: 'welding', department: 'Зварювальна дільниця', hourlyRate: 400, status: 'active' },
  { id: '9', code: 'EQ09', name: 'Зварювальний TIG', type: 'welding', department: 'Зварювальна дільниця', hourlyRate: 500, status: 'repair' },
  { id: '10', code: 'EQ10', name: 'Прес гідравлічний', type: 'forming', department: 'Заготівельна дільниця', hourlyRate: 650, status: 'active' },
];

// Операції
export const operations: Operation[] = [
  { id: '1', code: '005', name: 'Різка на гільйотині', type: 'cutting', department: 'Заготівельна дільниця', defaultEquipment: 'Гільйотина НГ-16', setupTime: 15 },
  { id: '2', code: '007', name: 'Різка плазмова', type: 'cutting', department: 'Заготівельна дільниця', defaultEquipment: 'Плазма HYPERTHERM', setupTime: 20 },
  { id: '3', code: '008', name: 'Різка лазерна', type: 'cutting', department: 'Заготівельна дільниця', defaultEquipment: 'Лазер TRUMPF', setupTime: 10 },
  { id: '4', code: '010', name: 'Слюсарна обробка', type: 'bench_work', department: 'Слюсарна дільниця', defaultEquipment: '-', setupTime: 5 },
  { id: '5', code: '015', name: 'Токарна обробка', type: 'turning', department: 'Механічна дільниця', defaultEquipment: 'Токарний 16К20', setupTime: 20 },
  { id: '6', code: '020', name: 'Фрезерна обробка', type: 'milling', department: 'Механічна дільниця', defaultEquipment: 'Фрезерний 6Р82', setupTime: 25 },
  { id: '7', code: '025', name: 'Свердління', type: 'drilling', department: 'Механічна дільниця', defaultEquipment: 'Свердлильний 2Н135', setupTime: 10 },
  { id: '8', code: '030', name: 'Гнуття', type: 'forming', department: 'Заготівельна дільниця', defaultEquipment: 'Прес гідравлічний', setupTime: 15 },
  { id: '9', code: '035', name: 'Зварювання MIG/MAG', type: 'welding', department: 'Зварювальна дільниця', defaultEquipment: 'Зварювальний MIG', setupTime: 5 },
  { id: '10', code: '040', name: 'Зварювання TIG', type: 'welding', department: 'Зварювальна дільниця', defaultEquipment: 'Зварювальний TIG', setupTime: 10 },
  { id: '11', code: '050', name: 'Складання', type: 'assembly', department: 'Складальна дільниця', defaultEquipment: '-', setupTime: 10 },
  { id: '12', code: '055', name: 'Фарбування', type: 'painting', department: 'Фарбувальна дільниця', defaultEquipment: '-', setupTime: 15 },
  { id: '13', code: '060', name: 'Контроль ВТК', type: 'inspection', department: 'ВТК', defaultEquipment: '-', setupTime: 5 },
];

// Проекти
export const projects: Project[] = [
  { id: '1', number: 'PRJ-2024-001', name: 'Кронштейн КР-150', customer: 'ТОВ "Машбуд"', status: 'production', deadline: '2024-02-15', estimatedCost: 45000, batchSize: 50 },
  { id: '2', number: 'PRJ-2024-002', name: 'Рама несуча РН-200', customer: 'ПП "Техносервіс"', status: 'calculation', deadline: '2024-02-28', estimatedCost: 125000, batchSize: 10 },
  { id: '3', number: 'PRJ-2024-003', name: 'Опора ОП-100', customer: 'АТ "Енергомаш"', status: 'approved', deadline: '2024-03-10', estimatedCost: 78000, batchSize: 25 },
  { id: '4', number: 'PRJ-2024-004', name: 'Балка Б-300', customer: 'ТОВ "Будконструкція"', status: 'draft', deadline: '2024-03-20', estimatedCost: 0, batchSize: 1 },
  { id: '5', number: 'PRJ-2024-005', name: 'Корпус КР-50', customer: 'ТОВ "Машбуд"', status: 'completed', deadline: '2024-01-30', estimatedCost: 32000, batchSize: 100 },
];

// Коефіцієнти партійності
export const batchCoefficients = [
  { from: 1, to: 1, coefficient: 1.00, name: 'Прототип' },
  { from: 2, to: 10, coefficient: 0.85, name: 'Мала партія' },
  { from: 11, to: 50, coefficient: 0.70, name: 'Середня партія' },
  { from: 51, to: 100, coefficient: 0.60, name: 'Велика партія' },
  { from: 101, to: null, coefficient: 0.50, name: 'Серійне виробництво' },
];

// Статистика для дашборду
export const dashboardStats = {
  totalProjects: 5,
  activeProjects: 3,
  totalMaterials: 12,
  lowStockMaterials: 2,
  totalEquipment: 10,
  activeEquipment: 8,
  monthlyRevenue: 280000,
  monthlyOrders: 15,
};
