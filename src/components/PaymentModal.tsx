import React, { useState } from 'react';
import { CartItem, Transaction, StoreProfile, PrinterSettings } from '../types';
import { formatRupiah, generateInvoiceNumber } from '../lib/formatters';

interface PaymentModalProps {
  isOpen: boolean;
  cart: CartItem[];
  subtotal: number;
  tax: number;
  total: number;
  storeProfile: StoreProfile;
  printerSettings: PrinterSettings;
  onClose: () => void;
  onPaymentSuccess: (transaction: Transaction) => void;
}

export const PaymentModal: React.FC<PaymentModalProps> = ({
  isOpen,
  cart,
  subtotal,
  total,
  storeProfile,
  printerSettings,
  onClose,
  onPaymentSuccess
}) => {
  if (!isOpen) return null;

  const [paymentMethod, setPaymentMethod] = useState<'Tunai' | 'QRIS' | 'Kartu Debit'>('Tunai');
  const [cashAmount, setCashAmount] = useState<number>(total);
  const [customerPhonePhoto, setCustomerPhonePhoto] = useState<string | null>(null);
  const [isCompleted, setIsCompleted] = useState<boolean>(false);
  const [completedTx, setCompletedTx] = useState<Transaction | null>(null);

  const change = Math.max(0, cashAmount - total);

  const quickMoneyOptions = [
    total,
    Math.ceil(total / 10000) * 10000,
    Math.ceil(total / 50000) * 50000,
    100000,
    200000,
    500000
  ].filter((val, idx, self) => val >= total && self.indexOf(val) === idx).slice(0, 4);

  const handlePhotoUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setCustomerPhonePhoto(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleProcessPayment = () => {
    if (paymentMethod === 'Tunai' && cashAmount < total) {
      alert('Jumlah uang tunai kurang dari total pembayaran!');
      return;
    }

    const now = new Date();
    const timeStr = now.toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' });

    const cashier = storeProfile.cashierName || 'Ahmad (Kasir 1)';

    const newTx: Transaction = {
      id: 'tx-' + Date.now(),
      invoiceNumber: generateInvoiceNumber(),
      timestamp: now.toISOString(),
      timeString: timeStr,
      items: cart.map((item) => ({
        productId: item.product.id,
        name: item.product.name,
        price: item.product.price,
        quantity: item.quantity
      })),
      itemCount: cart.reduce((sum, item) => sum + item.quantity, 0),
      subtotal,
      tax: 0, // Tanpa pajak sama sekali
      discount: 0,
      total,
      status: 'Lunas',
      paymentMethod,
      cashierName: cashier
    };

    setCompletedTx(newTx);
    setIsCompleted(true);
    onPaymentSuccess(newTx);
  };

  const handlePrint = () => {
    window.print();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-xs p-4 overflow-y-auto">
      <div className="bg-white dark:bg-[#12253c] rounded-2xl max-w-md w-full overflow-hidden shadow-2xl border border-[#c6c6cd] dark:border-slate-700 text-[#0b1c30] dark:text-slate-100">
        {!isCompleted ? (
          <div>
            {/* Modal Header */}
            <div className="flex justify-between items-center px-6 py-4 border-b border-[#c6c6cd]/40 dark:border-slate-700 bg-[#f8f9ff] dark:bg-slate-800/80">
              <div>
                <h2 className="font-bold text-lg text-[#0b1c30] dark:text-slate-100">Pembayaran</h2>
                <p className="text-xs text-[#45464d] dark:text-slate-400">Pilih metode pembayaran transaksi</p>
              </div>
              <button
                onClick={onClose}
                className="w-8 h-8 rounded-full flex items-center justify-center hover:bg-gray-200 dark:hover:bg-slate-700 text-[#76777d] dark:text-slate-400"
              >
                <span className="material-symbols-outlined text-lg">close</span>
              </button>
            </div>

            <div className="p-6 space-y-5">
              {/* Total Display */}
              <div className="bg-[#e3f2fd] dark:bg-sky-950/50 p-4 rounded-xl border border-[#2196f3]/30 text-center">
                <p className="text-xs text-[#0d47a1] dark:text-sky-300 font-mono-code font-semibold uppercase tracking-wider">
                  Total Tagihan (Tanpa Pajak)
                </p>
                <p className="text-3xl font-bold text-[#0d47a1] dark:text-sky-300 font-mono-code mt-1">
                  {formatRupiah(total)}
                </p>
              </div>

              {/* Payment Method Tabs */}
              <div>
                <label className="block text-xs font-semibold text-[#0b1c30] dark:text-slate-300 mb-2 font-mono-code">
                  Metode Pembayaran
                </label>
                <div className="grid grid-cols-3 gap-2">
                  {(['Tunai', 'QRIS', 'Kartu Debit'] as const).map((method) => (
                    <button
                      key={method}
                      type="button"
                      onClick={() => setPaymentMethod(method)}
                      className={`py-2.5 px-3 rounded-xl text-xs font-semibold border transition-all flex flex-col items-center gap-1 ${
                        paymentMethod === method
                          ? 'bg-[#0d47a1] dark:bg-sky-600 text-white border-[#0d47a1] shadow-xs'
                          : 'bg-white dark:bg-slate-800 text-[#45464d] dark:text-slate-300 border-[#c6c6cd]/60 dark:border-slate-700 hover:bg-[#eff4ff] dark:hover:bg-slate-700'
                      }`}
                    >
                      <span className="material-symbols-outlined text-xl">
                        {method === 'Tunai'
                          ? 'payments'
                          : method === 'QRIS'
                          ? 'qr_code_scanner'
                          : 'credit_card'}
                      </span>
                      <span>{method}</span>
                    </button>
                  ))}
                </div>
              </div>

              {/* Cash Input & Quick Money */}
              {paymentMethod === 'Tunai' && (
                <div className="space-y-3">
                  <div>
                    <label className="block text-xs font-semibold text-[#0b1c30] dark:text-slate-300 mb-1 font-mono-code">
                      Uang Diterima
                    </label>
                    <div className="relative">
                      <span className="absolute left-3.5 top-1/2 -translate-y-1/2 font-bold text-sm text-[#0d47a1] dark:text-sky-300">
                        Rp
                      </span>
                      <input
                        type="number"
                        value={cashAmount || ''}
                        onChange={(e) => setCashAmount(Number(e.target.value))}
                        className="w-full h-12 pl-10 pr-4 bg-[#f8f9ff] dark:bg-slate-800 rounded-xl border border-[#c6c6cd] dark:border-slate-700 font-mono-code text-base font-bold text-[#0b1c30] dark:text-slate-100 focus:ring-2 focus:ring-[#0d47a1] outline-none"
                      />
                    </div>
                  </div>

                  {/* Quick Money Buttons */}
                  <div className="flex flex-wrap gap-2">
                    {quickMoneyOptions.map((amount) => (
                      <button
                        key={amount}
                        type="button"
                        onClick={() => setCashAmount(amount)}
                        className="px-3 py-1.5 rounded-lg text-xs font-mono-code border border-[#2196f3]/30 bg-[#eff4ff] dark:bg-slate-800 text-[#0d47a1] dark:text-sky-300 font-semibold hover:bg-[#dce9ff] dark:hover:bg-slate-700"
                      >
                        {formatRupiah(amount)}
                      </button>
                    ))}
                  </div>

                  {/* Change Calculation */}
                  <div className="p-3 bg-gray-50 dark:bg-slate-800/80 rounded-xl border border-[#c6c6cd]/30 dark:border-slate-700 flex justify-between items-center text-sm">
                    <span className="font-medium text-[#45464d] dark:text-slate-300">Kembalian</span>
                    <span
                      className={`font-mono-code font-bold text-base ${
                        cashAmount >= total ? 'text-[#006c49] dark:text-emerald-400' : 'text-[#ba1a1a] dark:text-red-400'
                      }`}
                    >
                      {formatRupiah(change)}
                    </span>
                  </div>
                </div>
              )}

              {/* QRIS Instructions */}
              {paymentMethod === 'QRIS' && (
                <div className="flex flex-col items-center justify-center p-4 bg-[#eff4ff] dark:bg-slate-800/80 rounded-2xl border border-[#2196f3]/30 dark:border-slate-700 text-center">
                  <div className="w-40 h-40 bg-white p-2 rounded-xl border border-[#2196f3]/40 shadow-sm flex items-center justify-center mb-2">
                    <img
                      src={`https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=KASIRKU-${total}`}
                      alt="QRIS Code"
                      className="w-full h-full object-contain"
                    />
                  </div>
                  <p className="text-xs font-bold text-[#0d47a1] dark:text-sky-300">Scan QRIS Kasirku</p>
                  <p className="text-[11px] text-[#45464d] dark:text-slate-400">
                    Mendukung GoPay, OVO, Dana, ShopeePay, dan M-Banking
                  </p>
                </div>
              )}

              {/* Kartu Debit Flow (Foto HP Pelanggan) */}
              {paymentMethod === 'Kartu Debit' && (
                <div className="p-4 bg-[#eff4ff] dark:bg-slate-800/80 rounded-2xl border border-[#2196f3]/30 dark:border-slate-700 text-center space-y-3">
                  <span className="material-symbols-outlined text-4xl text-[#0d47a1] dark:text-sky-400">
                    photo_camera
                  </span>
                  <div>
                    <p className="text-xs font-bold text-[#0b1c30] dark:text-slate-100">Foto HP Pelanggan / Bukti Transaksi</p>
                    <p className="text-[11px] text-[#45464d] dark:text-slate-400 mt-0.5">
                      Cukup foto layar HP / struk EDC pelanggan untuk verifikasi kartu debit
                    </p>
                  </div>

                  {customerPhonePhoto ? (
                    <div className="relative w-full h-36 bg-black rounded-xl overflow-hidden border border-[#2196f3]/40">
                      <img src={customerPhonePhoto} alt="Bukti Foto" className="w-full h-full object-cover" />
                      <button
                        type="button"
                        onClick={() => setCustomerPhonePhoto(null)}
                        className="absolute top-2 right-2 p-1 bg-red-600 text-white rounded-full text-xs"
                        title="Hapus foto"
                      >
                        <span className="material-symbols-outlined text-sm">close</span>
                      </button>
                    </div>
                  ) : (
                    <label className="cursor-pointer inline-flex items-center gap-2 px-4 py-2 bg-[#0061a4] hover:bg-[#00497d] text-white text-xs font-bold rounded-xl transition-all shadow-xs">
                      <span className="material-symbols-outlined text-base">add_a_photo</span>
                      <span>Ambil / Unggah Foto HP</span>
                      <input
                        type="file"
                        accept="image/*"
                        capture="environment"
                        onChange={handlePhotoUpload}
                        className="hidden"
                      />
                    </label>
                  )}
                </div>
              )}
            </div>

            {/* Actions */}
            <div className="p-6 bg-[#f8f9ff] dark:bg-slate-800/90 border-t border-[#c6c6cd]/40 dark:border-slate-700 flex gap-3">
              <button
                onClick={onClose}
                className="flex-1 py-3 px-4 rounded-xl border border-[#c6c6cd] dark:border-slate-600 text-[#45464d] dark:text-slate-300 text-xs font-bold hover:bg-gray-100 dark:hover:bg-slate-700"
              >
                Batal
              </button>
              <button
                onClick={handleProcessPayment}
                className="flex-1 py-3 px-4 rounded-xl bg-[#006c49] hover:bg-[#005236] text-white text-xs font-bold shadow-md transition-all"
              >
                Konfirmasi Lunas
              </button>
            </div>
          </div>
        ) : (
          /* Receipt View / Completion Screen */
          <div className="p-6 text-center space-y-5">
            <div className="w-16 h-16 rounded-full bg-green-100 dark:bg-emerald-950 text-[#006c49] dark:text-emerald-400 flex items-center justify-center mx-auto">
              <span className="material-symbols-outlined text-3xl material-symbols-filled">
                check_circle
              </span>
            </div>

            <div>
              <h2 className="text-xl font-bold text-[#0b1c30] dark:text-slate-100">Transaksi Berhasil!</h2>
              <p className="text-xs text-[#45464d] dark:text-slate-400 mt-1 font-mono-code">
                {completedTx?.invoiceNumber}
              </p>
            </div>

            {/* Printable Receipt Paper simulation */}
            <div
              id="printable-receipt"
              className="bg-white text-gray-900 border border-dashed border-[#c6c6cd] p-4 rounded-xl text-left font-mono-code text-xs space-y-2 shadow-inner"
            >
              <div className="text-center pb-2 border-b border-dashed border-[#c6c6cd]">
                <p className="font-bold text-sm uppercase text-[#0b1c30]">
                  {storeProfile.name || 'Toko Saya'}
                </p>
                <p className="text-[10px] text-gray-600">{storeProfile.address}</p>
                <p className="text-[10px] text-gray-600">Telp: {storeProfile.phone}</p>
              </div>

              <div className="text-[11px] text-gray-700 space-y-0.5 py-1">
                <p>No: {completedTx?.invoiceNumber}</p>
                <p>Kasir: {completedTx?.cashierName || storeProfile.cashierName || 'Ahmad (Kasir 1)'}</p>
                <p>Waktu: {completedTx?.timeString}</p>
                <p>Metode: {completedTx?.paymentMethod}</p>
              </div>

              <div className="border-t border-b border-dashed border-[#c6c6cd] py-2 space-y-1">
                {completedTx?.items.map((item) => (
                  <div key={item.productId} className="flex justify-between text-[11px]">
                    <span className="truncate max-w-[160px]">
                      {item.quantity}x {item.name}
                    </span>
                    <span>{formatRupiah(item.price * item.quantity)}</span>
                  </div>
                ))}
              </div>

              <div className="space-y-1 pt-1 text-[11px]">
                <div className="flex justify-between font-bold text-sm text-[#0b1c30] pt-1">
                  <span>Total</span>
                  <span>{formatRupiah(completedTx?.total || 0)}</span>
                </div>
                {paymentMethod === 'Tunai' && (
                  <>
                    <div className="flex justify-between text-[10px] text-gray-600">
                      <span>Tunai</span>
                      <span>{formatRupiah(cashAmount)}</span>
                    </div>
                    <div className="flex justify-between text-[10px] text-gray-600">
                      <span>Kembali</span>
                      <span>{formatRupiah(change)}</span>
                    </div>
                  </>
                )}
              </div>

              <div className="text-center pt-3 border-t border-dashed border-[#c6c6cd] text-[10px] text-gray-600 whitespace-pre-line">
                {printerSettings.footerMessage}
              </div>
            </div>

            {/* Receipt Action Buttons */}
            <div className="flex gap-3">
              <button
                onClick={handlePrint}
                className="flex-1 py-3 px-4 rounded-xl border border-[#0d47a1] dark:border-sky-400 text-[#0d47a1] dark:text-sky-300 text-xs font-bold hover:bg-[#e3f2fd] dark:hover:bg-slate-800 flex items-center justify-center gap-1.5"
              >
                <span className="material-symbols-outlined text-base">print</span>
                <span>Cetak Struk</span>
              </button>
              <button
                onClick={onClose}
                className="flex-1 py-3 px-4 rounded-xl bg-[#0d47a1] text-white text-xs font-bold hover:bg-[#0a3880] shadow-md"
              >
                Selesai
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
