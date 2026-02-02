'use client';

import { useState } from 'react';
import { materials, materialGroups } from '@/data/mockData';

export default function MaterialsPage() {
  const [search, setSearch] = useState('');
  const [selectedGroup, setSelectedGroup] = useState<string | null>(null);

  const filteredMaterials = materials.filter(m => {
    const matchesSearch = m.name.toLowerCase().includes(search.toLowerCase()) ||
                         m.code.toLowerCase().includes(search.toLowerCase());
    const matchesGroup = !selectedGroup || m.groupId === selectedGroup;
    return matchesSearch && matchesGroup;
  });

  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-slate-800 dark:text-white">Матеріали</h1>
          <p className="text-slate-500 dark:text-slate-400 mt-1">Довідник матеріалів та складські залишки</p>
        </div>
        <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors flex items-center gap-2">
          <span>➕</span> Додати матеріал
        </button>
      </div>

      {/* Filters */}
      <div className="bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-700 p-4 mb-6">
        <div className="flex flex-col md:flex-row gap-4">
          {/* Search */}
          <div className="flex-1">
            <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Пошук
            </label>
            <input
              type="text"
              placeholder="Код або назва матеріалу..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full px-3 py-2 border border-slate-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-700 text-slate-800 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          {/* Group filter */}
          <div className="w-full md:w-64">
            <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Група
            </label>
            <select
              value={selectedGroup || ''}
              onChange={(e) => setSelectedGroup(e.target.value || null)}
              className="w-full px-3 py-2 border border-slate-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-700 text-slate-800 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="">Всі групи</option>
              {materialGroups.map(g => (
                <option key={g.id} value={g.id}>
                  {'  '.repeat(g.level)}{g.name}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-700 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-slate-50 dark:bg-slate-700">
              <tr className="text-left text-xs text-slate-500 dark:text-slate-400 uppercase">
                <th className="px-4 py-3 font-medium">Код</th>
                <th className="px-4 py-3 font-medium">Назва</th>
                <th className="px-4 py-3 font-medium">Група</th>
                <th className="px-4 py-3 font-medium">Тип</th>
                <th className="px-4 py-3 font-medium text-right">Розмір</th>
                <th className="px-4 py-3 font-medium text-right">Ціна</th>
                <th className="px-4 py-3 font-medium text-right">Залишок</th>
                <th className="px-4 py-3 font-medium text-center">Дії</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-slate-700">
              {filteredMaterials.map((mat) => (
                <tr key={mat.id} className="hover:bg-slate-50 dark:hover:bg-slate-700/50 transition-colors">
                  <td className="px-4 py-3">
                    <span className="font-mono text-sm text-slate-600 dark:text-slate-300">
                      {mat.code}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <span className="font-medium text-slate-800 dark:text-white">
                      {mat.name}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <span className="text-sm text-slate-500 dark:text-slate-400">
                      {mat.groupName}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                      mat.materialType === 'sheet' ? 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400' :
                      mat.materialType === 'round' ? 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400' :
                      'bg-slate-100 text-slate-700 dark:bg-slate-600 dark:text-slate-300'
                    }`}>
                      {mat.materialType === 'sheet' ? 'Лист' :
                       mat.materialType === 'round' ? 'Круг' :
                       mat.materialType === 'fastener' ? 'Кріплення' : mat.materialType}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-right text-sm text-slate-600 dark:text-slate-300">
                    {mat.thickness ? `${mat.thickness} мм` : mat.diameter ? `Ø${mat.diameter} мм` : '-'}
                  </td>
                  <td className="px-4 py-3 text-right">
                    <span className="font-medium text-slate-800 dark:text-white">
                      {mat.price.toFixed(2)} ₴
                    </span>
                    <span className="text-xs text-slate-500 dark:text-slate-400">/{mat.unit}</span>
                  </td>
                  <td className="px-4 py-3 text-right">
                    <span className={`font-medium ${mat.stock < 500 ? 'text-red-600 dark:text-red-400' : 'text-green-600 dark:text-green-400'}`}>
                      {mat.stock.toLocaleString()}
                    </span>
                    <span className="text-xs text-slate-500 dark:text-slate-400 ml-1">{mat.unit}</span>
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
        <div className="px-4 py-3 bg-slate-50 dark:bg-slate-700 border-t border-slate-200 dark:border-slate-600 flex items-center justify-between">
          <span className="text-sm text-slate-500 dark:text-slate-400">
            Знайдено: {filteredMaterials.length} з {materials.length} матеріалів
          </span>
          <div className="flex items-center gap-2">
            <button className="px-3 py-1 text-sm border border-slate-300 dark:border-slate-600 rounded hover:bg-slate-100 dark:hover:bg-slate-600 transition-colors">
              ← Назад
            </button>
            <span className="text-sm text-slate-600 dark:text-slate-400">1 / 1</span>
            <button className="px-3 py-1 text-sm border border-slate-300 dark:border-slate-600 rounded hover:bg-slate-100 dark:hover:bg-slate-600 transition-colors">
              Далі →
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
