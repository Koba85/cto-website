import { operations } from '@/data/mockData';

export default function OperationsPage() {
  const typeLabels: Record<string, string> = {
    cutting: 'Різка',
    turning: 'Токарна',
    milling: 'Фрезерна',
    drilling: 'Свердління',
    forming: 'Гнуття',
    welding: 'Зварювання',
    bench_work: 'Слюсарна',
    assembly: 'Складання',
    painting: 'Фарбування',
    inspection: 'Контроль',
  };

  const typeColors: Record<string, string> = {
    cutting: 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400',
    turning: 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400',
    milling: 'bg-indigo-100 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-400',
    drilling: 'bg-cyan-100 text-cyan-700 dark:bg-cyan-900/30 dark:text-cyan-400',
    forming: 'bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400',
    welding: 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400',
    bench_work: 'bg-slate-100 text-slate-700 dark:bg-slate-600 dark:text-slate-300',
    assembly: 'bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400',
    painting: 'bg-pink-100 text-pink-700 dark:bg-pink-900/30 dark:text-pink-400',
    inspection: 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400',
  };

  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-slate-800 dark:text-white">Операції</h1>
          <p className="text-slate-500 dark:text-slate-400 mt-1">Технологічні операції для маршрутів виготовлення</p>
        </div>
        <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors flex items-center gap-2">
          <span>➕</span> Додати операцію
        </button>
      </div>

      {/* Table */}
      <div className="bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-700 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-slate-50 dark:bg-slate-700">
              <tr className="text-left text-xs text-slate-500 dark:text-slate-400 uppercase">
                <th className="px-4 py-3 font-medium">Код</th>
                <th className="px-4 py-3 font-medium">Назва операції</th>
                <th className="px-4 py-3 font-medium">Тип</th>
                <th className="px-4 py-3 font-medium">Дільниця</th>
                <th className="px-4 py-3 font-medium">Обладнання за замовч.</th>
                <th className="px-4 py-3 font-medium text-right">Час налагодження</th>
                <th className="px-4 py-3 font-medium text-center">Дії</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-slate-700">
              {operations.map((op) => (
                <tr key={op.id} className="hover:bg-slate-50 dark:hover:bg-slate-700/50 transition-colors">
                  <td className="px-4 py-3">
                    <span className="font-mono text-lg font-bold text-slate-700 dark:text-slate-200">
                      {op.code}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <span className="font-medium text-slate-800 dark:text-white">
                      {op.name}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${typeColors[op.type] || 'bg-slate-100 text-slate-700'}`}>
                      {typeLabels[op.type] || op.type}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <span className="text-sm text-slate-600 dark:text-slate-300">
                      {op.department}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <span className="text-sm text-slate-500 dark:text-slate-400">
                      {op.defaultEquipment}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-right">
                    <span className="font-medium text-slate-800 dark:text-white">
                      {op.setupTime}
                    </span>
                    <span className="text-xs text-slate-500 dark:text-slate-400 ml-1">хв</span>
                  </td>
                  <td className="px-4 py-3 text-center">
                    <div className="flex items-center justify-center gap-1">
                      <button className="p-2 hover:bg-slate-100 dark:hover:bg-slate-600 rounded-lg transition-colors" title="Переглянути">
                        👁️
                      </button>
                      <button className="p-2 hover:bg-slate-100 dark:hover:bg-slate-600 rounded-lg transition-colors" title="Редагувати">
                        ✏️
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Footer */}
        <div className="px-4 py-3 bg-slate-50 dark:bg-slate-700 border-t border-slate-200 dark:border-slate-600">
          <span className="text-sm text-slate-500 dark:text-slate-400">
            Всього: {operations.length} операцій
          </span>
        </div>
      </div>

      {/* Info */}
      <div className="mt-6 bg-blue-50 dark:bg-blue-900/20 rounded-xl border border-blue-200 dark:border-blue-800 p-4">
        <h3 className="font-medium text-blue-800 dark:text-blue-300 mb-2">💡 Підказка</h3>
        <p className="text-sm text-blue-700 dark:text-blue-400">
          Код операції використовується в маршрутних картах. Рекомендована нумерація:
          005, 010, 015... з кроком 5 для можливості вставки нових операцій.
        </p>
      </div>
    </div>
  );
}
