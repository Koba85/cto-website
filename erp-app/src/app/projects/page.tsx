import { projects } from '@/data/mockData';

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
    <span className={`px-3 py-1 rounded-full text-xs font-medium ${styles[status] || styles.draft}`}>
      {labels[status] || status}
    </span>
  );
}

export default function ProjectsPage() {
  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-slate-800 dark:text-white">Замовлення</h1>
          <p className="text-slate-500 dark:text-slate-400 mt-1">Управління проектами та замовленнями</p>
        </div>
        <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors flex items-center gap-2">
          <span>➕</span> Нове замовлення
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-4 mb-6">
        {[
          { label: 'Всього', count: projects.length, color: 'text-slate-800 dark:text-white' },
          { label: 'Чернетки', count: projects.filter(p => p.status === 'draft').length, color: 'text-slate-600' },
          { label: 'Калькуляція', count: projects.filter(p => p.status === 'calculation').length, color: 'text-yellow-600' },
          { label: 'Виробництво', count: projects.filter(p => p.status === 'production').length, color: 'text-purple-600' },
          { label: 'Завершено', count: projects.filter(p => p.status === 'completed').length, color: 'text-green-600' },
        ].map((stat, i) => (
          <div key={i} className="bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-700 p-4 text-center">
            <p className={`text-2xl font-bold ${stat.color}`}>{stat.count}</p>
            <p className="text-xs text-slate-500 dark:text-slate-400">{stat.label}</p>
          </div>
        ))}
      </div>

      {/* Projects List */}
      <div className="space-y-4">
        {projects.map((project) => (
          <div
            key={project.id}
            className="bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-700 p-4 hover:shadow-md transition-shadow"
          >
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
              {/* Left side */}
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <span className="font-mono text-sm text-slate-500 dark:text-slate-400">
                    {project.number}
                  </span>
                  <StatusBadge status={project.status} />
                </div>
                <h3 className="text-lg font-semibold text-slate-800 dark:text-white">
                  {project.name}
                </h3>
                <p className="text-sm text-slate-500 dark:text-slate-400 mt-1">
                  Замовник: {project.customer}
                </p>
              </div>

              {/* Right side */}
              <div className="flex flex-col md:flex-row md:items-center gap-4 md:gap-8">
                <div className="text-center">
                  <p className="text-xs text-slate-500 dark:text-slate-400">Партія</p>
                  <p className="text-lg font-bold text-slate-800 dark:text-white">{project.batchSize} шт</p>
                </div>
                <div className="text-center">
                  <p className="text-xs text-slate-500 dark:text-slate-400">Вартість</p>
                  <p className="text-lg font-bold text-slate-800 dark:text-white">
                    {project.estimatedCost > 0 ? `${(project.estimatedCost / 1000).toFixed(0)}K ₴` : '—'}
                  </p>
                </div>
                <div className="text-center">
                  <p className="text-xs text-slate-500 dark:text-slate-400">Термін</p>
                  <p className="text-sm font-medium text-slate-700 dark:text-slate-300">
                    {new Date(project.deadline).toLocaleDateString('uk-UA')}
                  </p>
                </div>
                <div className="flex gap-2">
                  <button className="px-4 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                    Відкрити
                  </button>
                  <button className="px-3 py-2 text-sm border border-slate-200 dark:border-slate-600 text-slate-600 dark:text-slate-400 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-700 transition-colors">
                    ⋯
                  </button>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
