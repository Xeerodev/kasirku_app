import React, { useState } from 'react';
import { Transaction, StoreProfile } from '../types';
import { formatRupiah } from '../lib/formatters';

interface HistoryViewProps {
  transactions: Transaction[];
  storeProfile: StoreProfile;
  onToggleRefund?: (transactionId: string) => void;
}

export const HistoryView: React.FC<HistoryViewProps> = ({
  transactions,
  storeProfile,
  onToggleRefund
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedTx, setSelectedTx] = useState<Transaction | null>(null);

  const filteredTransactions = transactions.filter(
    (tx) =>
      tx.invoiceNumber.toLowerCase().includes(searchQuery.toLowerCase()) ||
      tx.paymentMethod.toLowerCase().includes(searchQuery.toLowerCase()) ||
      tx.status.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="min-h-screen bg-[#f8f9ff] dark:bg-[#0b1c30] text-[#0b1c30] dark:text-slate-100 flex flex-col pb-20 md:pb-8 landscape:pb-8 md:pl-52 landscape:pl-52">
      <main className="p-4 md:p-8 max-w-5xl mx-auto w-full space-y-5">
        <header className="mb-2">
          <div className="flex items-center gap-2 mb-1">
            <span className="material-symbols-outlined text-[#0d47a1] dark:text-sky-400 text-2xl material-symbols-filled">
              history
            </span>
            <span className="font-bold text-xl text-[#0d47a1] dark:text-sky-300">Riwayat Transaksi</span>
          </div>
          <p className="text-xs text-[#45464d] dark:text-slate-400">
            Daftar seluruh transaksi penjualan toko
          </p>
        </header>

        {/* Search */}
        <div className="relative w-full">
          <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-[#76777d] dark:text-slate-400">
            search
          </span>
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Cari no. faktur atau metode pembayaran..."
            className="w-full h-12 pl-12 pr-4 bg-white dark:bg-[#12253c] text-[#0b1c30] dark:text-slate-100 rounded-xl border border-[#c6c6cd]/50 dark:border-slate-700 text-sm focus:ring-2 focus:ring-[#0d47a1] outline-none"
          />
        </div>

        {/* List */}
        <div className="bg-white dark:bg-[#12253c] rounded-2xl border border-[#c6c6cd]/40 dark:border-slate-700/60 shadow-xs overflow-hidden">
          {filteredTransactions.length === 0 ? (
            <div className="p-12 text-center text-[#76777d] dark:text-slate-400">
              <span className="material-symbols-outlined text-4xl mb-2">receipt_long</span>
              <p className="font-bold text-sm text-[#0b1c30] dark:text-slate-200">Belum ada riwayat transaksi</p>
            </div>
          ) : (
            <div className="divide-y divide-[#c6c6cd]/20 dark:divide-slate-700/60">
              {filteredTransactions.map((tx) => (
                <div
                  key={tx.id}
                  onClick={() => setSelectedTx(tx)}
                  className="p-4 flex items-center justify-between hover:bg-[#eff4ff] dark:hover:bg-slate-800/50 transition-colors cursor-pointer"
                >
                  <div className="space-y-1">
                    <div className="flex items-center gap-2">
                      <span className="font-bold font-mono-code text-sm text-[#0d47a1] dark:text-sky-300">
                        {tx.invoiceNumber}
                      </span>
                      <span
                        className={`px-2 py-0.5 text-[10px] font-bold rounded-full font-mono-code ${
                          tx.status === 'Lunas'
                            ? 'bg-[#e3f2fd] dark:bg-sky-950 text-[#0d47a1] dark:text-sky-300'
                            : 'bg-[#ffdad6] dark:bg-red-950 text-[#93000a] dark:text-red-300'
                        }`}
                      >
                        {tx.status}
                      </span>
                    </div>
                    <p className="text-xs text-[#45464d] dark:text-slate-400">
                      {tx.timeString} • {tx.itemCount} item ({tx.paymentMethod}) • Kasir: {tx.cashierName || storeProfile.cashierName || 'Ahmad'}
                    </p>
                  </div>

                  <div className="text-right flex items-center gap-3">
                    <div>
                      <p className="font-bold font-mono-code text-sm text-[#0b1c30] dark:text-slate-100">
                        {formatRupiah(tx.total)}
                      </p>
                      <p className="text-[10px] text-[#76777d] dark:text-slate-400">Klik detail</p>
                    </div>
                    <span className="material-symbols-outlined text-[#76777d] dark:text-slate-400">
                      chevron_right
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </main>

      {/* Transaction Detail Modal */}
      {selectedTx && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-xs p-4">
          <div className="bg-white dark:bg-[#12253c] rounded-2xl max-w-md w-full overflow-hidden shadow-xl border border-[#c6c6cd] dark:border-slate-700 text-[#0b1c30] dark:text-slate-100">
            <div className="p-4 border-b border-[#c6c6cd]/40 dark:border-slate-700 bg-[#f8f9ff] dark:bg-slate-800 flex justify-between items-center">
              <h3 className="font-bold text-base text-[#0d47a1] dark:text-sky-300">Detail Faktur</h3>
              <button
                onClick={() => setSelectedTx(null)}
                className="w-8 h-8 rounded-full flex items-center justify-center hover:bg-gray-200 dark:hover:bg-slate-700 text-[#76777d] dark:text-slate-400"
              >
                <span className="material-symbols-outlined text-lg">close</span>
              </button>
            </div>

            <div className="p-5 font-mono-code text-xs space-y-3">
              <div className="flex justify-between text-sm font-bold text-[#0b1c30] dark:text-slate-100">
                <span>{selectedTx.invoiceNumber}</span>
                <span className="text-[#0d47a1] dark:text-sky-300">{selectedTx.status}</span>
              </div>
              <div className="text-[#76777d] dark:text-slate-400 space-y-0.5">
                <p>Kasir: {selectedTx.cashierName || storeProfile.cashierName || 'Ahmad'}</p>
                <p>Waktu: {selectedTx.timeString} | Pembayaran: {selectedTx.paymentMethod}</p>
              </div>

              <div className="border-t border-b border-dashed border-[#c6c6cd] dark:border-slate-700 py-3 space-y-1.5">
                {selectedTx.items.map((item) => (
                  <div key={item.productId} className="flex justify-between">
                    <span>
                      {item.quantity}x {item.name}
                    </span>
                    <span>{formatRupiah(item.price * item.quantity)}</span>
                  </div>
                ))}
              </div>

              <div className="flex justify-between font-bold text-sm text-[#0b1c30] dark:text-slate-100 pt-1">
                <span>Total Bayar</span>
                <span>{formatRupiah(selectedTx.total)}</span>
              </div>
            </div>

            <div className="p-4 bg-[#f8f9ff] dark:bg-slate-800/90 border-t border-[#c6c6cd]/40 dark:border-slate-700 flex gap-2">
              <button
                onClick={() => window.print()}
                className="flex-1 py-2.5 bg-[#0d47a1] text-white rounded-xl text-xs font-semibold hover:bg-[#0a3880]"
              >
                Cetak Ulang Struk
              </button>

              {onToggleRefund && selectedTx.status === 'Lunas' && (
                <button
                  onClick={() => {
                    onToggleRefund(selectedTx.id);
                    setSelectedTx(null);
                  }}
                  className="py-2.5 px-4 bg-[#ba1a1a] text-white rounded-xl text-xs font-semibold hover:bg-red-800"
                >
                  Refund
                </button>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
