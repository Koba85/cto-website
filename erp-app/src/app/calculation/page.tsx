'use client';

import { useState } from 'react';
import { batchCoefficients, materials } from '@/data/mockData';

export default function CalculationPage() {
  const [batchSize, setBatchSize] = useState(1);
  const [weight, setWeight] = useState(2.5);
  const [laborHours, setLaborHours] = useState(1.5);

  // Prices
  const materialPrice = 32.5; // грн/кг
  const laborRate = 450; // грн/год
  const overheadPercent = 25;
  const marginPercent = 20;

  // Get batch coefficient
  const getCoefficient = (qty: number) => {
    const found = batchCoefficients.find(c =>
      qty >= c.from && (c.to === null || qty <= c.to)
    );
    return found?.coefficient || 1;
  };

  const coefficient = getCoefficient(batchSize);

  // Calculations for 1 piece
  const materialCost = weight * materialPrice;
  const laborCost = laborHours * laborRate;
  const subtotal = materialCost + laborCost;
  const overheadCost = subtotal * (overheadPercent / 100);
  const totalCost = subtotal + overheadCost;
  const marginAmount = totalCost * (marginPercent / 100);
  const pricePerUnit = totalCost + marginAmount;

  // With batch coefficient
  const priceWithCoef = pricePerUnit * coefficient;
  const totalBatchPrice = priceWithCoef * batchSize;

  return (
    <div className="p-8">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-slate-800 dark:text-white">Калькулятор вартості</h1>
        <p className="text-slate-500 dark:text-slate-400 mt-1">Швидкий розрахунок собівартості деталі</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Input Form */}
        <div className="bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-700 p-6">
          <h2 className="font-semibold text-slate-800 dark:text-white mb-4">Вхідні дані</h2>

          <div className="space-y-4">
            {/* Material */}
            <div>
              <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
                Матеріал
              </label>
              <select className="w-full px-3 py-2 border border-slate-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-700 text-slate-800 dark:text-white">
                {materials.filter(m => m.materialType === 'sheet').map(m => (
                  <option key={m.id} value={m.id}>{m.name} — {m.price} ₴/{m.unit}</option>
                ))}
              </select>
            </div>

            {/* Weight */}
            <div>
              <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
                Вага деталі (кг)
              </label>
              <input
                type="number"
                step="0.1"
                value={weight}
                onChange={(e) => setWeight(parseFloat(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-slate-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-700 text-slate-800 dark:text-white"
              />
            </div>

            {/* Labor hours */}
            <div>
              <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
                Трудомісткість (год)
              </label>
              <input
                type="number"
                step="0.1"
                value={laborHours}
                onChange={(e) => setLaborHours(parseFloat(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-slate-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-700 text-slate-800 dark:text-white"
              />
            </div>

            {/* Batch size */}
            <div>
              <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
                Розмір партії (шт)
              </label>
              <input
                type="number"
                min="1"
                value={batchSize}
                onChange={(e) => setBatchSize(parseInt(e.target.value) || 1)}
                className="w-full px-3 py-2 border border-slate-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-700 text-slate-800 dark:text-white"
              />
            </div>
          </div>

          {/* Coefficients info */}
          <div className="mt-6 pt-4 border-t border-slate-200 dark:border-slate-700">
            <h3 className="text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
              Коефіцієнти партійності
            </h3>
            <div className="grid grid-cols-2 gap-2 text-xs">
              {batchCoefficients.map((c, i) => (
                <div
                  key={i}
                  className={`px-2 py-1 rounded ${
                    coefficient === c.coefficient
                      ? 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400 font-medium'
                      : 'bg-slate-100 text-slate-600 dark:bg-slate-700 dark:text-slate-400'
                  }`}
                >
                  {c.from}—{c.to || '∞'} шт: ×{c.coefficient}
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Results */}
        <div className="space-y-6">
          {/* Calculation breakdown */}
          <div className="bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-700 p-6">
            <h2 className="font-semibold text-slate-800 dark:text-white mb-4">Розрахунок (за 1 шт)</h2>

            <div className="space-y-3">
              <div className="flex justify-between text-sm">
                <span className="text-slate-500 dark:text-slate-400">Матеріал ({weight} кг × {materialPrice} ₴)</span>
                <span className="font-medium text-slate-800 dark:text-white">{materialCost.toFixed(2)} ₴</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-slate-500 dark:text-slate-400">Робота ({laborHours} год × {laborRate} ₴)</span>
                <span className="font-medium text-slate-800 dark:text-white">{laborCost.toFixed(2)} ₴</span>
              </div>
              <div className="flex justify-between text-sm border-t border-slate-100 dark:border-slate-700 pt-2">
                <span className="text-slate-500 dark:text-slate-400">Проміжний підсумок</span>
                <span className="font-medium text-slate-800 dark:text-white">{subtotal.toFixed(2)} ₴</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-slate-500 dark:text-slate-400">Накладні ({overheadPercent}%)</span>
                <span className="font-medium text-slate-800 dark:text-white">{overheadCost.toFixed(2)} ₴</span>
              </div>
              <div className="flex justify-between text-sm border-t border-slate-100 dark:border-slate-700 pt-2">
                <span className="text-slate-600 dark:text-slate-300 font-medium">Собівартість</span>
                <span className="font-bold text-slate-800 dark:text-white">{totalCost.toFixed(2)} ₴</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-slate-500 dark:text-slate-400">Маржа ({marginPercent}%)</span>
                <span className="font-medium text-slate-800 dark:text-white">{marginAmount.toFixed(2)} ₴</span>
              </div>
              <div className="flex justify-between text-sm border-t border-slate-200 dark:border-slate-600 pt-2">
                <span className="text-slate-700 dark:text-slate-200 font-semibold">Ціна за 1 шт</span>
                <span className="font-bold text-lg text-blue-600 dark:text-blue-400">{pricePerUnit.toFixed(2)} ₴</span>
              </div>
            </div>
          </div>

          {/* Batch result */}
          <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl p-6 text-white">
            <h2 className="font-semibold mb-4">Результат для партії {batchSize} шт</h2>

            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-blue-100">Коефіцієнт партійності</span>
                <span className="font-bold">×{coefficient}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-blue-100">Ціна за 1 шт (з коеф.)</span>
                <span className="font-bold">{priceWithCoef.toFixed(2)} ₴</span>
              </div>
              <div className="flex justify-between border-t border-blue-400 pt-3">
                <span className="text-lg font-medium">Загальна вартість</span>
                <span className="text-2xl font-bold">{totalBatchPrice.toFixed(2)} ₴</span>
              </div>
            </div>

            <div className="mt-4 pt-4 border-t border-blue-400 text-sm text-blue-100">
              <p>Економія за рахунок партії: {((pricePerUnit - priceWithCoef) * batchSize).toFixed(2)} ₴ ({((1 - coefficient) * 100).toFixed(0)}%)</p>
            </div>
          </div>

          {/* Quick comparison */}
          <div className="bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-700 p-6">
            <h2 className="font-semibold text-slate-800 dark:text-white mb-4">Порівняння партій</h2>
            <div className="grid grid-cols-4 gap-2 text-center text-sm">
              {[1, 10, 50, 100].map(qty => {
                const coef = getCoefficient(qty);
                const price = pricePerUnit * coef;
                return (
                  <div
                    key={qty}
                    className={`p-3 rounded-lg ${
                      qty === batchSize
                        ? 'bg-blue-100 dark:bg-blue-900/30 border-2 border-blue-500'
                        : 'bg-slate-50 dark:bg-slate-700'
                    }`}
                  >
                    <p className="font-bold text-slate-800 dark:text-white">{qty} шт</p>
                    <p className="text-xs text-slate-500 dark:text-slate-400">×{coef}</p>
                    <p className="font-medium text-blue-600 dark:text-blue-400">{price.toFixed(0)} ₴</p>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
