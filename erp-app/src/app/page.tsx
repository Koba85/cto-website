import { dashboardStats, projects, materials, equipment } from '@/data/mockData';

function StatCard({ title, value, subtitle, icon, color }: {
  title: string;
  value: string | number;
  subtitle?: string;
  icon: string;
  color: string;
}) {
  return (
    <div className="bg-white dark:bg-slate-800 rounded-xl p-6 shadow-sm border border-slate-200 dark:border-slate-700">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-sm text-slate-500 dark:text-slate-400">{title}</p>
          <p className={`text-3xl font-bold mt-2 ${color}`}>{value}</p>
          {subtitle && (
            <p className="text-xs text-slate-400 mt-1">{subtitle}</p>
          )}
        </div>
        <div className="text-3xl">{icon}</div>
      </div>
    </div>
  );
}

function StatusBadge({ status }: { status: string }) {
  const styles: Record<string, string> = {
    draft: 'bg-slate-100 text-slate-600 dark:bg-slate-700 dark:text-slate-300',
    calculation: 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400',
    approved: 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400',
    production: 'bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400',
    completed: 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400',
  };

  const labels: Record<string, string> = {
    draft: 'Чернетка',
    calculation: 'Калькуляція',
    approved: 'Затверджено',
    production: 'Виробництво',
    completed: 'Завершено',
  };

  return (
    <span className={`px-2 py-1 rounded-full text-xs font-medium ${styles[status] || styles.draft}`}>
      {labels[status] || status}
    </span>
  );
}

function EquipmentStatusBadge({ status }: { status: string }) {
  const styles: Record<string, string> = {
    active: 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400',
    maintenance: 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400',
    repair: 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400',
  };

  const labels: Record<string, string> = {
    active: 'Працює',
    maintenance: 'ТО',
    repair: 'Ремонт',
  };

  return (
    <span className={`px-2 py-1 rounded-full text-xs font-medium ${styles[status] || styles.active}`}>
      {labels[status] || status}
    </span>
  );
}

export default function Dashboard() {
  const activeProjects = projects.filter(p => p.status === 'production' || p.status === 'approved');
  const lowStockMaterials = materials.filter(m => m.stock < 500);

  return (
    <div className="p-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-slate-800 dark:text-white">
          Панель керування
        </h1>
        <p className="text-slate-500 dark:text-slate-400 mt-1">
          Загальний огляд системи
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <StatCard
          title="Активні замовлення"
          value={dashboardStats.activeProjects}
          subtitle={`з ${dashboardStats.totalProjects} всього`}
          icon="📋"
          color="text-blue-600 dark:text-blue-400"
        />
        <StatCard
          title="Матеріали на складі"
          value={dashboardStats.totalMaterials}
          subtitle={`${dashboardStats.lowStockMaterials} потребують поповнення`}
          icon="🔩"
          color="text-green-600 dark:text-green-400"
        />
        <StatCard
          title="Обладнання"
          value={`${dashboardStats.activeEquipment}/${dashboardStats.totalEquipment}`}
          subtitle="працює / всього"
          icon="⚙️"
          color="text-purple-600 dark:text-purple-400"
        />
        <StatCard
          title="Дохід за місяць"
          value={`${(dashboardStats.monthlyRevenue / 1000).toFixed(0)}K`}
          subtitle={`${dashboardStats.monthlyOrders} замовлень`}
          icon="💰"
          color="text-amber-600 dark:text-amber-400"
        />
      </div>

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Active Projects */}
        <div className="bg-white dark:bg-slate-800 rounded-xl shadow-sm border border-slate-200 dark:border-slate-700">
          <div className="p-4 border-b border-slate-200 dark:border-slate-700 flex items-center justify-between">
            <h2 className="font-semibold text-slate-800 dark:text-white">Активні замовлення</h2>
            <a href="/projects" className="text-sm text-blue-600 dark:text-blue-400 hover:underline">
              Всі замовлення →
            </a>
          </div>
          <div className="p-4">
            <table className="w-full">
              <thead>
                <tr className="text-left text-xs text-slate-500 dark:text-slate-400 uppercase">
                  <th className="pb-3">Номер</th>
                  <th className="pb-3">Назва</th>
                  <th className="pb-3">Статус</th>
                  <th className="pb-3 text-right">Термін</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-700">
                {activeProjects.map((project) => (
                  <tr key={project.id} className="text-sm">
                    <td className="py-3 font-mono text-slate-600 dark:text-slate-300">
                      {project.number}
                    </td>
                    <td className="py-3 text-slate-800 dark:text-white">
                      {project.name}
                    </td>
                    <td className="py-3">
                      <StatusBadge status={project.status} />
                    </td>
                    <td className="py-3 text-right text-slate-500 dark:text-slate-400">
                      {new Date(project.deadline).toLocaleDateString('uk-UA')}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Equipment Status */}
        <div className="bg-white dark:bg-slate-800 rounded-xl shadow-sm border border-slate-200 dark:border-slate-700">
          <div className="p-4 border-b border-slate-200 dark:border-slate-700 flex items-center justify-between">
            <h2 className="font-semibold text-slate-800 dark:text-white">Стан обладнання</h2>
            <a href="/directories/equipment" className="text-sm text-blue-600 dark:text-blue-400 hover:underline">
              Все обладнання →
            </a>
          </div>
          <div className="p-4">
            <table className="w-full">
              <thead>
                <tr className="text-left text-xs text-slate-500 dark:text-slate-400 uppercase">
                  <th className="pb-3">Код</th>
                  <th className="pb-3">Назва</th>
                  <th className="pb-3">Дільниця</th>
                  <th className="pb-3 text-right">Статус</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-700">
                {equipment.slice(0, 5).map((eq) => (
                  <tr key={eq.id} className="text-sm">
                    <td className="py-3 font-mono text-slate-600 dark:text-slate-300">
                      {eq.code}
                    </td>
                    <td className="py-3 text-slate-800 dark:text-white">
                      {eq.name}
                    </td>
                    <td className="py-3 text-slate-500 dark:text-slate-400 text-xs">
                      {eq.department}
                    </td>
                    <td className="py-3 text-right">
                      <EquipmentStatusBadge status={eq.status} />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Low Stock Materials */}
        <div className="bg-white dark:bg-slate-800 rounded-xl shadow-sm border border-slate-200 dark:border-slate-700">
          <div className="p-4 border-b border-slate-200 dark:border-slate-700 flex items-center justify-between">
            <h2 className="font-semibold text-slate-800 dark:text-white">Матеріали (низький залишок)</h2>
            <a href="/directories/materials" className="text-sm text-blue-600 dark:text-blue-400 hover:underline">
              Всі матеріали →
            </a>
          </div>
          <div className="p-4">
            {lowStockMaterials.length > 0 ? (
              <table className="w-full">
                <thead>
                  <tr className="text-left text-xs text-slate-500 dark:text-slate-400 uppercase">
                    <th className="pb-3">Код</th>
                    <th className="pb-3">Назва</th>
                    <th className="pb-3 text-right">Залишок</th>
                    <th className="pb-3 text-right">Ціна</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 dark:divide-slate-700">
                  {lowStockMaterials.map((mat) => (
                    <tr key={mat.id} className="text-sm">
                      <td className="py-3 font-mono text-slate-600 dark:text-slate-300">
                        {mat.code}
                      </td>
                      <td className="py-3 text-slate-800 dark:text-white">
                        {mat.name}
                      </td>
                      <td className="py-3 text-right text-red-600 dark:text-red-400 font-medium">
                        {mat.stock} {mat.unit}
                      </td>
                      <td className="py-3 text-right text-slate-500 dark:text-slate-400">
                        {mat.price.toFixed(2)} ₴
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            ) : (
              <p className="text-slate-500 dark:text-slate-400 text-center py-4">
                Всі матеріали в наявності
              </p>
            )}
          </div>
        </div>

        {/* Quick Actions */}
        <div className="bg-white dark:bg-slate-800 rounded-xl shadow-sm border border-slate-200 dark:border-slate-700">
          <div className="p-4 border-b border-slate-200 dark:border-slate-700">
            <h2 className="font-semibold text-slate-800 dark:text-white">Швидкі дії</h2>
          </div>
          <div className="p-4 grid grid-cols-2 gap-3">
            <a
              href="/projects"
              className="flex items-center gap-3 p-4 rounded-lg border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-700 transition-colors"
            >
              <span className="text-2xl">➕</span>
              <div>
                <p className="font-medium text-slate-800 dark:text-white">Нове замовлення</p>
                <p className="text-xs text-slate-500 dark:text-slate-400">Створити проект</p>
              </div>
            </a>
            <a
              href="/calculation"
              className="flex items-center gap-3 p-4 rounded-lg border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-700 transition-colors"
            >
              <span className="text-2xl">🧮</span>
              <div>
                <p className="font-medium text-slate-800 dark:text-white">Калькуляція</p>
                <p className="text-xs text-slate-500 dark:text-slate-400">Розрахувати вартість</p>
              </div>
            </a>
            <a
              href="/directories/materials"
              className="flex items-center gap-3 p-4 rounded-lg border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-700 transition-colors"
            >
              <span className="text-2xl">📦</span>
              <div>
                <p className="font-medium text-slate-800 dark:text-white">Матеріали</p>
                <p className="text-xs text-slate-500 dark:text-slate-400">Переглянути склад</p>
              </div>
            </a>
            <a
              href="/directories/equipment"
              className="flex items-center gap-3 p-4 rounded-lg border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-700 transition-colors"
            >
              <span className="text-2xl">🔧</span>
              <div>
                <p className="font-medium text-slate-800 dark:text-white">Обладнання</p>
                <p className="text-xs text-slate-500 dark:text-slate-400">Стан верстатів</p>
              </div>
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
