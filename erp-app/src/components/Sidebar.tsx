'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

const menuItems = [
  {
    title: 'Головна',
    items: [
      { name: 'Дашборд', href: '/', icon: '📊' },
    ]
  },
  {
    title: 'Довідники',
    items: [
      { name: 'Підрозділи', href: '/directories/departments', icon: '🏢' },
      { name: 'Матеріали', href: '/directories/materials', icon: '🔩' },
      { name: 'Обладнання', href: '/directories/equipment', icon: '⚙️' },
      { name: 'Операції', href: '/directories/operations', icon: '🔧' },
    ]
  },
  {
    title: 'Виробництво',
    items: [
      { name: 'Замовлення', href: '/projects', icon: '📋' },
      { name: 'Калькуляція', href: '/calculation', icon: '🧮' },
    ]
  },
];

export default function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-64 bg-white dark:bg-slate-800 border-r border-slate-200 dark:border-slate-700 h-screen fixed left-0 top-0 overflow-y-auto">
      {/* Logo */}
      <div className="p-4 border-b border-slate-200 dark:border-slate-700">
        <h1 className="text-xl font-bold text-blue-600 dark:text-blue-400">
          ERP Система
        </h1>
        <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
          Управління виробництвом
        </p>
      </div>

      {/* Menu */}
      <nav className="p-4">
        {menuItems.map((section, idx) => (
          <div key={idx} className="mb-6">
            <h2 className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2">
              {section.title}
            </h2>
            <ul className="space-y-1">
              {section.items.map((item) => {
                const isActive = pathname === item.href ||
                  (item.href !== '/' && pathname.startsWith(item.href));
                return (
                  <li key={item.href}>
                    <Link
                      href={item.href}
                      className={`flex items-center gap-3 px-3 py-2 rounded-lg transition-colors ${
                        isActive
                          ? 'bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 font-medium'
                          : 'text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-700'
                      }`}
                    >
                      <span className="text-lg">{item.icon}</span>
                      <span>{item.name}</span>
                    </Link>
                  </li>
                );
              })}
            </ul>
          </div>
        ))}
      </nav>

      {/* Footer */}
      <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-900 flex items-center justify-center">
            <span className="text-sm">👤</span>
          </div>
          <div>
            <p className="text-sm font-medium text-slate-700 dark:text-slate-200">Адміністратор</p>
            <p className="text-xs text-slate-500 dark:text-slate-400">admin@erp.ua</p>
          </div>
        </div>
      </div>
    </aside>
  );
}
