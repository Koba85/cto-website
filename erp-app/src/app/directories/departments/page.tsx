'use client';

import { useState } from 'react';
import { departments, type Department } from '@/data/mockData';

function TreeNode({
  item,
  allItems,
  expanded,
  onToggle,
  selectedId,
  onSelect
}: {
  item: Department;
  allItems: Department[];
  expanded: Set<string>;
  onToggle: (id: string) => void;
  selectedId: string | null;
  onSelect: (item: Department) => void;
}) {
  const children = allItems.filter(d => d.parentId === item.id);
  const hasChildren = children.length > 0;
  const isExpanded = expanded.has(item.id);
  const isSelected = selectedId === item.id;

  return (
    <div>
      <div
        className={`flex items-center gap-2 px-3 py-2 rounded-lg cursor-pointer transition-colors ${
          isSelected
            ? 'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400'
            : 'hover:bg-slate-100 dark:hover:bg-slate-700'
        }`}
        style={{ paddingLeft: `${item.level * 24 + 12}px` }}
        onClick={() => onSelect(item)}
      >
        {hasChildren ? (
          <button
            onClick={(e) => {
              e.stopPropagation();
              onToggle(item.id);
            }}
            className="w-5 h-5 flex items-center justify-center text-slate-400 hover:text-slate-600 dark:hover:text-slate-300"
          >
            {isExpanded ? '▼' : '▶'}
          </button>
        ) : (
          <span className="w-5" />
        )}

        <span className="text-lg">
          {item.isProduction ? '🏭' : item.code === 'DEP09' ? '🏢' : '📦'}
        </span>

        <div className="flex-1">
          <span className="font-medium text-slate-800 dark:text-white">{item.name}</span>
          <span className="text-xs text-slate-400 ml-2">({item.code})</span>
        </div>

        {item.isProduction && (
          <span className="px-2 py-0.5 text-xs rounded-full bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400">
            Виробн.
          </span>
        )}
      </div>

      {hasChildren && isExpanded && (
        <div>
          {children.map(child => (
            <TreeNode
              key={child.id}
              item={child}
              allItems={allItems}
              expanded={expanded}
              onToggle={onToggle}
              selectedId={selectedId}
              onSelect={onSelect}
            />
          ))}
        </div>
      )}
    </div>
  );
}

export default function DepartmentsPage() {
  const [expanded, setExpanded] = useState<Set<string>>(new Set(['1'])); // Expand "Виробництво" by default
  const [selected, setSelected] = useState<Department | null>(null);

  const rootItems = departments.filter(d => d.parentId === null);

  const toggleExpand = (id: string) => {
    setExpanded(prev => {
      const newSet = new Set(prev);
      if (newSet.has(id)) {
        newSet.delete(id);
      } else {
        newSet.add(id);
      }
      return newSet;
    });
  };

  const expandAll = () => {
    setExpanded(new Set(departments.map(d => d.id)));
  };

  const collapseAll = () => {
    setExpanded(new Set());
  };

  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-slate-800 dark:text-white">Підрозділи</h1>
          <p className="text-slate-500 dark:text-slate-400 mt-1">Організаційна структура підприємства</p>
        </div>
        <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors flex items-center gap-2">
          <span>➕</span> Додати підрозділ
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Tree */}
        <div className="lg:col-span-2 bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-700">
          {/* Tree Header */}
          <div className="px-4 py-3 border-b border-slate-200 dark:border-slate-700 flex items-center justify-between">
            <h2 className="font-semibold text-slate-800 dark:text-white">Структура</h2>
            <div className="flex items-center gap-2">
              <button
                onClick={expandAll}
                className="px-2 py-1 text-xs text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-700 rounded transition-colors"
              >
                Розгорнути все
              </button>
              <button
                onClick={collapseAll}
                className="px-2 py-1 text-xs text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-700 rounded transition-colors"
              >
                Згорнути все
              </button>
            </div>
          </div>

          {/* Tree Content */}
          <div className="p-4">
            {rootItems.map(item => (
              <TreeNode
                key={item.id}
                item={item}
                allItems={departments}
                expanded={expanded}
                onToggle={toggleExpand}
                selectedId={selected?.id || null}
                onSelect={setSelected}
              />
            ))}
          </div>
        </div>

        {/* Details Panel */}
        <div className="bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-700">
          <div className="px-4 py-3 border-b border-slate-200 dark:border-slate-700">
            <h2 className="font-semibold text-slate-800 dark:text-white">Деталі</h2>
          </div>

          <div className="p-4">
            {selected ? (
              <div className="space-y-4">
                <div className="text-center pb-4 border-b border-slate-100 dark:border-slate-700">
                  <div className="text-4xl mb-2">
                    {selected.isProduction ? '🏭' : selected.code === 'DEP09' ? '🏢' : '📦'}
                  </div>
                  <h3 className="text-lg font-bold text-slate-800 dark:text-white">{selected.name}</h3>
                  <p className="text-sm text-slate-500 dark:text-slate-400">{selected.shortName}</p>
                </div>

                <div className="space-y-3">
                  <div className="flex justify-between text-sm">
                    <span className="text-slate-500 dark:text-slate-400">Код:</span>
                    <span className="font-mono text-slate-800 dark:text-white">{selected.code}</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-slate-500 dark:text-slate-400">Рівень:</span>
                    <span className="text-slate-800 dark:text-white">{selected.level}</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-slate-500 dark:text-slate-400">Шлях:</span>
                    <span className="font-mono text-xs text-slate-600 dark:text-slate-300">{selected.path}</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-slate-500 dark:text-slate-400">Тип:</span>
                    <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${
                      selected.isProduction
                        ? 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400'
                        : 'bg-slate-100 text-slate-700 dark:bg-slate-600 dark:text-slate-300'
                    }`}>
                      {selected.isProduction ? 'Виробничий' : 'Адміністративний'}
                    </span>
                  </div>
                </div>

                <div className="flex gap-2 pt-4 border-t border-slate-100 dark:border-slate-700">
                  <button className="flex-1 px-3 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                    Редагувати
                  </button>
                  <button className="px-3 py-2 text-sm border border-red-200 dark:border-red-800 text-red-600 dark:text-red-400 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors">
                    🗑️
                  </button>
                </div>
              </div>
            ) : (
              <div className="text-center py-8 text-slate-500 dark:text-slate-400">
                <p className="text-4xl mb-2">👆</p>
                <p>Оберіть підрозділ зі списку</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
