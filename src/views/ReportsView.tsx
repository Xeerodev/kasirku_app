import React from 'react';
import { Transaction, StoreProfile } from '../types';
import { formatRupiah } from '../lib/formatters';

interface ReportsViewProps {
  transactions: Transaction[];
  storeProfile: StoreProfile;
  onViewAllTransactions: () => void;
}

export const ReportsView: React.FC<ReportsViewProps> = ({
  transactions,
  storeProfile,
  onViewAllTransactions
}) => {
  // Calculate analytics
  const totalSales = transactions
    .filter((tx) => tx.status === 'Lunas')
    .reduce((sum, tx) => sum + tx.total, 0);

  const totalTransactions = transactions.length;

  const handleExportPDF = () => {
    alert('Mengunduh Laporan Penjualan (PDF)...');
  };

  const handleExportExcel = () => {
    alert('Mengunduh Laporan Penjualan (Excel/XLSX)...');
  };

  const handlePrint = () => {
    window.print();
  };

  const topSellingProduct = {
    name: 'Artisan Espresso Roast',
    unitsSold: 48,
    image:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCF-qcm-b66fnodh-JVo1nxXD4XU1eAZhDQayyPYD6_vh1BWkBLXpkZNgQzz-Hgb5GE0jOrep4-Lo3h7JBt8xDu_Op4qGbDSLbtotW-hkK-w3OLjjD1bLcjTZ3jfSNCv_Q_G_f9Uv794wBf1Nn_sdK0btC07fVi-2noepCWMtL_yu1n9xaG2wScscF1_axt72iysHroCgCFG8ny81wmtgSLXsaYk1vUaqMCe9feh5xSNzb20gRdcqyw'
  };

  const recentTransactions = transactions.slice(0, 5);

  return (
    <div className="min-h-screen bg-[#f8f9ff] dark:bg-[#0b1c30] text-[#0b1c30] dark:text-slate-100 flex flex-col pb-20 md:pb-8 landscape:pb-8 md:pl-52 landscape:pl-52">
      {/* Top App Bar */}
      <header className="w-full sticky top-0 bg-[#f8f9ff] dark:bg-[#0b1c30] flex justify-between items-center px-4 md:px-8 h-14 border-b border-[#c6c6cd]/40 dark:border-slate-800 z-20">
        <div className="flex items-center gap-3">
          <img
            src={storeProfile.logoUrl}
            alt="Logo"
            className="h-8 w-auto object-contain rounded"
          />
          <span className="font-bold text-xl text-[#0d47a1] dark:text-sky-300">
            {storeProfile.name || 'Kasirku'}
          </span>
        </div>
        {/* Header without print button as requested */}
      </header>

      {/* Main Content */}
      <main className="p-4 md:p-8 max-w-6xl mx-auto w-full space-y-6">
        {/* Header & Actions */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-[#0d47a1] dark:text-sky-300">Laporan</h1>
            <p className="text-sm text-[#45464d] dark:text-slate-400">Ringkasan Penjualan Hari Ini</p>
          </div>
          <div className="flex gap-3">
            <button
              onClick={handleExportPDF}
              className="flex items-center gap-2 px-4 py-2 border border-[#0d47a1] dark:border-sky-400 rounded-xl text-[#0d47a1] dark:text-sky-300 hover:bg-[#e3f2fd] dark:hover:bg-slate-800 transition-colors text-xs font-semibold font-mono-code"
            >
              <span className="material-symbols-outlined text-lg">picture_as_pdf</span>
              <span>Ekspor PDF</span>
            </button>
            <button
              onClick={handleExportExcel}
              className="flex items-center gap-2 px-4 py-2 border border-[#0d47a1] dark:border-sky-400 rounded-xl text-[#0d47a1] dark:text-sky-300 hover:bg-[#e3f2fd] dark:hover:bg-slate-800 transition-colors text-xs font-semibold font-mono-code"
            >
              <span className="material-symbols-outlined text-lg">table_chart</span>
              <span>Ekspor Excel</span>
            </button>
          </div>
        </div>

        {/* Bento Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {/* Total Sales Card */}
          <div className="bg-[#e3f2fd] dark:bg-sky-950/60 p-6 rounded-2xl border border-[#2196f3]/40 dark:border-sky-800/50 shadow-xs flex flex-col justify-between h-48 relative overflow-hidden group">
            <div className="absolute inset-0 bg-gradient-to-br from-[#0d47a1]/5 to-transparent pointer-events-none" />
            <div className="flex justify-between items-start z-10">
              <div>
                <p className="text-xs font-semibold text-[#0d47a1] dark:text-sky-300 font-mono-code uppercase tracking-wider">
                  Total Omset
                </p>
                <h2 className="text-2xl lg:text-3xl font-bold text-[#0d47a1] dark:text-sky-200 mt-2 font-mono-code">
                  {formatRupiah(totalSales)}
                </h2>
              </div>
              <div className="w-12 h-12 rounded-xl bg-white/80 dark:bg-slate-800 text-[#0d47a1] dark:text-sky-300 flex items-center justify-center shadow-xs">
                <span className="material-symbols-outlined text-2xl">payments</span>
              </div>
            </div>
            <div className="z-10 flex items-center gap-1 text-xs text-[#006c49] dark:text-emerald-400 font-semibold font-mono-code">
              <span className="material-symbols-outlined text-base">trending_up</span>
              <span>+14.2% dari kemarin</span>
            </div>
          </div>

          {/* Total Transactions Card */}
          <div className="bg-[#e3f2fd] dark:bg-sky-950/60 p-6 rounded-2xl border border-[#2196f3]/40 dark:border-sky-800/50 shadow-xs flex flex-col justify-between h-48 relative overflow-hidden group">
            <div className="flex justify-between items-start z-10">
              <div>
                <p className="text-xs font-semibold text-[#0d47a1] dark:text-sky-300 font-mono-code uppercase tracking-wider">
                  Total Transaksi
                </p>
                <h2 className="text-2xl lg:text-3xl font-bold text-[#0d47a1] dark:text-sky-200 mt-2 font-mono-code">
                  {totalTransactions} Transaksi
                </h2>
              </div>
              <div className="w-12 h-12 rounded-xl bg-white/80 dark:bg-slate-800 text-[#0d47a1] dark:text-sky-300 flex items-center justify-center shadow-xs">
                <span className="material-symbols-outlined text-2xl">receipt_long</span>
              </div>
            </div>
            <p className="z-10 text-xs text-[#45464d] dark:text-slate-400 font-mono-code">
              Rata-rata {formatRupiah(totalTransactions ? Math.round(totalSales / totalTransactions) : 0)} / transaksi
            </p>
          </div>

          {/* Top Selling Card */}
          <div className="bg-white dark:bg-[#12253c] p-6 rounded-2xl border border-[#c6c6cd]/40 dark:border-slate-700/60 shadow-xs flex flex-col justify-between h-48">
            <div className="flex justify-between items-start">
              <div>
                <p className="text-xs font-semibold text-[#45464d] dark:text-slate-400 font-mono-code uppercase tracking-wider">
                  Produk Terlaris
                </p>
                <h3 className="text-base font-bold text-[#0b1c30] dark:text-slate-100 mt-1 line-clamp-1">
                  {topSellingProduct.name}
                </h3>
              </div>
              <span className="material-symbols-outlined text-amber-500 text-2xl">
                star
              </span>
            </div>

            <div className="flex items-center gap-3">
              <img
                src={topSellingProduct.image}
                alt={topSellingProduct.name}
                className="w-12 h-12 rounded-lg object-cover border border-[#c6c6cd]/30"
              />
              <div>
                <p className="text-xs text-[#45464d] dark:text-slate-400">Total Terjual</p>
                <p className="font-bold text-sm text-[#0d47a1] dark:text-sky-300 font-mono-code">
                  {topSellingProduct.unitsSold} porsi
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Recent Transactions Section */}
        <section className="bg-white dark:bg-[#12253c] rounded-2xl border border-[#c6c6cd]/40 dark:border-slate-700/60 p-6 shadow-xs space-y-4">
          <div className="flex justify-between items-center">
            <h2 className="text-lg font-bold text-[#0b1c30] dark:text-slate-100 flex items-center gap-2">
              <span className="material-symbols-outlined text-[#0d47a1] dark:text-sky-400 text-xl">history</span>
              <span>Transaksi Terakhir</span>
            </h2>
            <button
              onClick={onViewAllTransactions}
              className="text-xs font-semibold text-[#0d47a1] dark:text-sky-400 hover:underline font-mono-code"
            >
              Lihat Semua
            </button>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-[#f8f9ff] dark:bg-slate-800 text-[#45464d] dark:text-slate-300 border-b border-[#c6c6cd]/40 dark:border-slate-700 font-mono-code">
                <tr>
                  <th className="p-3">NO. INVOICE</th>
                  <th className="p-3">WAKTU</th>
                  <th className="p-3">KASIR</th>
                  <th className="p-3">METODE</th>
                  <th className="p-3">TOTAL</th>
                  <th className="p-3">STATUS</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#c6c6cd]/20 dark:divide-slate-700">
                {recentTransactions.map((tx) => (
                  <tr key={tx.id} className="hover:bg-[#f8f9ff] dark:hover:bg-slate-800/50">
                    <td className="p-3 font-mono-code font-bold text-[#0d47a1] dark:text-sky-300">
                      {tx.invoiceNumber}
                    </td>
                    <td className="p-3 text-[#45464d] dark:text-slate-400 font-mono-code">
                      {tx.timeString}
                    </td>
                    <td className="p-3 text-[#0b1c30] dark:text-slate-200">
                      {tx.cashierName || storeProfile.cashierName || 'Ahmad'}
                    </td>
                    <td className="p-3 text-[#45464d] dark:text-slate-300 font-medium">
                      {tx.paymentMethod}
                    </td>
                    <td className="p-3 font-mono-code font-bold text-[#0b1c30] dark:text-slate-100">
                      {formatRupiah(tx.total)}
                    </td>
                    <td className="p-3">
                      <span className="px-2.5 py-1 rounded-full text-[10px] font-bold font-mono-code bg-emerald-100 dark:bg-emerald-950 text-[#006c49] dark:text-emerald-400">
                        {tx.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      </main>
    </div>
  );
};
