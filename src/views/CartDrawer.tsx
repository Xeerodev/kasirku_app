import React from 'react';
import { CartItem } from '../types';
import { formatRupiah } from '../lib/formatters';

interface CartDrawerProps {
  isOpen: boolean;
  cart: CartItem[];
  onClose: () => void;
  onUpdateQuantity: (productId: string, newQty: number) => void;
  onRemoveItem: (productId: string) => void;
  onClearCart: () => void;
  onProceedToPayment: (subtotal: number, tax: number, total: number) => void;
}

export const CartDrawer: React.FC<CartDrawerProps> = ({
  isOpen,
  cart,
  onClose,
  onUpdateQuantity,
  onRemoveItem,
  onClearCart,
  onProceedToPayment
}) => {
  if (!isOpen) return null;

  const totalItemCount = cart.reduce((sum, item) => sum + item.quantity, 0);
  const subtotal = cart.reduce(
    (sum, item) => sum + item.product.price * item.quantity,
    0
  );
  
  // Tidak ada pajak (0%)
  const tax = 0;
  const grandTotal = subtotal;

  return (
    <div className="fixed inset-0 z-50 flex justify-center bg-black/50 backdrop-blur-xs animate-fadeIn">
      <main className="w-full max-w-md bg-[#f8fafc] dark:bg-[#12253c] text-[#0b1c30] dark:text-slate-100 h-full flex flex-col shadow-2xl relative overflow-hidden mx-auto border-x border-[#c6c6cd] dark:border-slate-700">
        {/* Header */}
        <header className="flex justify-between items-center px-6 h-14 w-full bg-white dark:bg-[#12253c] border-b border-[#c6c6cd]/50 dark:border-slate-700 sticky top-0 z-10">
          <button
            onClick={onClose}
            className="flex items-center justify-center w-10 h-10 rounded-full hover:bg-gray-100 dark:hover:bg-slate-700 transition-colors text-[#0b1c30] dark:text-slate-100 active:opacity-80"
            aria-label="Kembali"
          >
            <span className="material-symbols-outlined text-xl">arrow_back</span>
          </button>
          <h1 className="font-bold text-lg text-[#0b1c30] dark:text-slate-100 flex-1 text-center pr-10">
            Keranjang Belanja
          </h1>
          {cart.length > 0 && (
            <button
              onClick={onClearCart}
              className="text-xs text-[#ba1a1a] dark:text-red-400 hover:underline font-mono-code"
            >
              Kosongkan
            </button>
          )}
        </header>

        {/* Cart Items List */}
        <div className="flex-1 overflow-y-auto no-scrollbar p-4 flex flex-col gap-3">
          {cart.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-full text-center py-12">
              <div className="w-16 h-16 rounded-full bg-[#eff4ff] dark:bg-slate-800 text-[#0d47a1] dark:text-sky-300 flex items-center justify-center mb-3">
                <span className="material-symbols-outlined text-3xl">shopping_bag</span>
              </div>
              <p className="font-bold text-base text-[#0b1c30] dark:text-slate-100">Keranjang Anda Masih Kosong</p>
              <p className="text-xs text-[#45464d] dark:text-slate-400 mt-1 max-w-xs">
                Silakan pilih item dari menu Kasir untuk ditambahkan ke keranjang belanja.
              </p>
              <button
                onClick={onClose}
                className="mt-6 px-6 py-2.5 bg-[#0d47a1] dark:bg-sky-600 text-white rounded-full text-xs font-semibold shadow-sm hover:bg-[#0a3880]"
              >
                Pilih Produk Sekarang
              </button>
            </div>
          ) : (
            cart.map((item) => {
              const itemTotal = item.product.price * item.quantity;
              return (
                <div
                  key={item.product.id}
                  className="flex items-center gap-3 p-3.5 bg-white dark:bg-slate-800/80 border border-[#c6c6cd]/40 dark:border-slate-700 rounded-xl shadow-2xs"
                >
                  <div className="w-16 h-16 rounded-lg overflow-hidden bg-[#eff4ff] dark:bg-slate-700 shrink-0 border border-[#c6c6cd]/20 dark:border-slate-600 flex items-center justify-center">
                    {item.product.image ? (
                      <img
                        src={item.product.image}
                        alt={item.product.name}
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <span className="material-symbols-outlined text-[#76777d] dark:text-slate-400 text-2xl">
                        local_cafe
                      </span>
                    )}
                  </div>

                  <div className="flex-1 min-w-0">
                    <h2 className="text-sm font-bold text-[#0b1c30] dark:text-slate-100 truncate">
                      {item.product.name}
                    </h2>
                    <p className="text-xs text-[#45464d] dark:text-slate-400 font-mono-code mt-0.5">
                      {formatRupiah(item.product.price)}
                    </p>
                  </div>

                  <div className="flex flex-col items-end gap-1.5 shrink-0">
                    <button
                      aria-label="Hapus item"
                      onClick={() => onRemoveItem(item.product.id)}
                      className="text-[#ba1a1a] dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-950/40 p-1 rounded transition-colors"
                    >
                      <span className="material-symbols-outlined text-lg">delete</span>
                    </button>

                    <div className="flex items-center bg-[#eff4ff] dark:bg-slate-700 rounded-full border border-[#c6c6cd]/40 dark:border-slate-600 overflow-hidden h-7">
                      <button
                        onClick={() =>
                          onUpdateQuantity(item.product.id, item.quantity - 1)
                        }
                        className="w-7 h-full flex items-center justify-center text-[#0b1c30] dark:text-slate-200 hover:bg-[#dce9ff] dark:hover:bg-slate-600 active:bg-[#d3e4fe] transition-colors"
                      >
                        <span className="material-symbols-outlined text-sm">remove</span>
                      </button>
                      <span className="w-7 text-center font-mono-code text-xs font-bold text-[#0b1c30] dark:text-slate-100">
                        {item.quantity}
                      </span>
                      <button
                        disabled={item.quantity >= item.product.stock}
                        onClick={() =>
                          onUpdateQuantity(item.product.id, item.quantity + 1)
                        }
                        className="w-7 h-full flex items-center justify-center text-[#0b1c30] dark:text-slate-200 hover:bg-[#dce9ff] dark:hover:bg-slate-600 active:bg-[#d3e4fe] transition-colors disabled:opacity-40"
                      >
                        <span className="material-symbols-outlined text-sm">add</span>
                      </button>
                    </div>

                    <p className="text-xs font-bold text-[#0d47a1] dark:text-sky-300 font-mono-code">
                      {formatRupiah(itemTotal)}
                    </p>
                  </div>
                </div>
              );
            })
          )}
        </div>

        {/* Summary & Checkout Section */}
        {cart.length > 0 && (
          <div className="bg-white dark:bg-[#12253c] border-t border-[#c6c6cd]/50 dark:border-slate-700 p-5 flex flex-col gap-3">
            <div className="flex flex-col gap-1.5 text-xs">
              <div className="flex justify-between items-center text-[#45464d] dark:text-slate-400">
                <span>Total Item</span>
                <span className="font-semibold text-[#0b1c30] dark:text-slate-100">{totalItemCount} Barang</span>
              </div>
              <div className="flex justify-between items-center text-[#45464d] dark:text-slate-400">
                <span>Subtotal</span>
                <span className="font-semibold text-[#0b1c30] dark:text-slate-100 font-mono-code">
                  {formatRupiah(subtotal)}
                </span>
              </div>
            </div>

            <div className="flex justify-between items-end border-t border-[#c6c6cd]/30 dark:border-slate-700 pt-3 mb-2">
              <span className="text-base font-bold text-[#0b1c30] dark:text-slate-100">Total</span>
              <span className="text-2xl font-bold text-[#0d47a1] dark:text-sky-300 font-mono-code">
                {formatRupiah(grandTotal)}
              </span>
            </div>

            {/* Primary Action Button */}
            <button
              onClick={() => onProceedToPayment(subtotal, tax, grandTotal)}
              className="w-full text-white font-semibold text-sm h-12 rounded-full flex items-center justify-center gap-2 hover:bg-[#0d47a1] active:scale-[0.98] transition-all shadow-md bg-[#0d47a1]"
            >
              <span className="material-symbols-outlined text-lg material-symbols-filled">
                payments
              </span>
              <span>Bayar Sekarang</span>
            </button>
          </div>
        )}
      </main>
    </div>
  );
};
