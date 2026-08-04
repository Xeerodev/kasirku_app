import React, { useState } from 'react';
import { Product, CartItem, StoreProfile } from '../types';
import { formatRupiah } from '../lib/formatters';

interface PosViewProps {
  products: Product[];
  cart: CartItem[];
  storeProfile: StoreProfile;
  onAddToCart: (product: Product) => void;
  onRemoveFromCart: (product: Product) => void;
  onOpenCart: () => void;
}

export const PosView: React.FC<PosViewProps> = ({
  products,
  cart,
  storeProfile,
  onAddToCart,
  onRemoveFromCart,
  onOpenCart
}) => {
  const [selectedCategory, setSelectedCategory] = useState<string>('Semua');
  const [searchQuery, setSearchQuery] = useState<string>('');

  const categories = ['Semua', 'Kopi', 'Kue', 'Merchandise', 'Biji Kopi', 'Minuman'];

  const filteredProducts = products.filter((product) => {
    const matchesCategory =
      selectedCategory === 'Semua' || product.category === selectedCategory;
    const matchesSearch =
      product.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      product.category.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const totalCartCount = cart.reduce((sum, item) => sum + item.quantity, 0);
  const totalCartAmount = cart.reduce(
    (sum, item) => sum + item.product.price * item.quantity,
    0
  );

  const getItemQuantity = (productId: string) => {
    const cartItem = cart.find((item) => item.product.id === productId);
    return cartItem ? cartItem.quantity : 0;
  };

  return (
    <div className="min-h-screen bg-[#f8f9ff] dark:bg-[#0b1c30] text-[#0b1c30] dark:text-slate-100 flex flex-col pb-24 md:pb-8 landscape:pb-8 md:pl-52 landscape:pl-52">
      {/* Header Section */}
      <header className="bg-[#f8f9ff] dark:bg-[#0b1c30] sticky top-0 z-20 px-4 md:px-8 pt-4 pb-2 border-b border-[#c6c6cd]/30 dark:border-slate-800 shadow-xs">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-[#0d47a1] dark:text-sky-400 text-2xl material-symbols-filled">
              point_of_sale
            </span>
            <h1 className="text-2xl font-bold text-[#0d47a1] dark:text-sky-300 tracking-tight">
              <span className="md:hidden landscape:hidden">{storeProfile.name || 'Kasirku'}</span>
              <span className="hidden md:inline landscape:inline">Kasir</span>
            </h1>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-10 h-10 overflow-hidden rounded-full border border-[#2196f3]/40 shadow-sm bg-white dark:bg-slate-800 flex items-center justify-center">
              {storeProfile.logoUrl ? (
                <img
                  src={storeProfile.logoUrl}
                  alt="Store Logo"
                  className="w-full h-full object-cover"
                />
              ) : (
                <span className="material-symbols-outlined text-[#0d47a1] dark:text-sky-400">store</span>
              )}
            </div>
          </div>
        </div>

        {/* Search Bar */}
        <div className="relative w-full mb-3">
          <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-[#76777d] dark:text-slate-400">
            search
          </span>
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Cari produk..."
            className="w-full h-12 pl-12 pr-4 rounded-full bg-[#eff4ff] dark:bg-[#12253c] border-none text-[#0b1c30] dark:text-slate-100 placeholder:text-[#45464d] dark:placeholder:text-slate-400 focus:ring-2 focus:ring-[#0d47a1] focus:outline-none text-sm font-medium shadow-xs"
          />
          {searchQuery && (
            <button
              onClick={() => setSearchQuery('')}
              className="absolute right-4 top-1/2 -translate-y-1/2 text-[#76777d] hover:text-[#0b1c30] dark:text-slate-400"
            >
              <span className="material-symbols-outlined text-lg">close</span>
            </button>
          )}
        </div>

        {/* Category Scroll */}
        <div className="flex overflow-x-auto no-scrollbar gap-2 pb-2 -mx-4 px-4">
          {categories.map((cat) => {
            const isSelected = selectedCategory === cat;
            return (
              <button
                key={cat}
                onClick={() => setSelectedCategory(cat)}
                className={`whitespace-nowrap px-4 py-2 rounded-full font-mono-code text-xs transition-all active:scale-95 flex-shrink-0 ${
                  isSelected
                    ? 'bg-[#0d47a1] dark:bg-sky-600 text-white font-semibold shadow-xs'
                    : 'bg-[#eff4ff] dark:bg-slate-800 text-[#45464d] dark:text-slate-300 border border-[#c6c6cd]/50 dark:border-slate-700 hover:bg-[#dce9ff]'
                }`}
              >
                {cat}
              </button>
            );
          })}
        </div>
      </header>

      {/* Product Grid */}
      <main className="flex-1 px-4 md:px-8 py-4 overflow-y-auto">
        {filteredProducts.length === 0 ? (
          <div className="text-center py-16 bg-white dark:bg-[#12253c] rounded-2xl border border-dashed border-[#c6c6cd] dark:border-slate-700 p-8">
            <span className="material-symbols-outlined text-5xl text-[#c6c6cd] dark:text-slate-600 mb-2">
              search_off
            </span>
            <p className="font-semibold text-lg text-[#0b1c30] dark:text-slate-100">Produk tidak ditemukan</p>
            <p className="text-xs text-[#45464d] dark:text-slate-400 mt-1">
              Coba cari kata kunci lain atau pilih kategori lain.
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3.5 md:gap-5">
            {filteredProducts.map((product) => {
              const qty = getItemQuantity(product.id);
              const isOutOfStock = product.stock === 0;

              return (
                <div
                  key={product.id}
                  className={`bg-white dark:bg-[#12253c] rounded-2xl border border-[#c6c6cd]/40 dark:border-slate-700/60 overflow-hidden flex flex-col transition-all shadow-xs hover:shadow-md ${
                    isOutOfStock ? 'opacity-60 bg-gray-50 dark:bg-slate-900/50' : ''
                  }`}
                >
                  <div className="h-32 sm:h-36 w-full bg-[#d3e4fe]/50 dark:bg-slate-800 relative flex items-center justify-center overflow-hidden">
                    {product.image ? (
                      <img
                        src={product.image}
                        alt={product.name}
                        className={`object-cover w-full h-full ${
                          isOutOfStock ? 'grayscale' : ''
                        }`}
                      />
                    ) : (
                      <div className="flex flex-col items-center justify-center text-[#76777d] dark:text-slate-400">
                        <span className="material-symbols-outlined text-4xl">local_cafe</span>
                        <span className="text-[10px] font-mono-code mt-1">{product.category}</span>
                      </div>
                    )}

                    {isOutOfStock && (
                      <div className="absolute inset-0 bg-black/20 flex items-center justify-center">
                        <span className="bg-[#ba1a1a] text-white px-3 py-1 rounded-full font-mono-code text-xs font-bold shadow-md">
                          Habis
                        </span>
                      </div>
                    )}
                  </div>

                  <div className="p-3 flex flex-col flex-1">
                    <div className="flex flex-col mb-2">
                      <h3 className="font-bold text-sm text-[#0b1c30] dark:text-slate-100 leading-snug line-clamp-2">
                        {product.name}
                      </h3>
                      {!isOutOfStock && (
                        <p className="text-[10px] font-mono-code text-[#006c49] dark:text-emerald-400 font-medium mt-0.5">
                          Stok: {product.stock}
                        </p>
                      )}
                    </div>

                    <div className="mt-auto flex flex-col">
                      <span className="font-bold text-sm text-[#0d47a1] dark:text-sky-300 mb-2 font-mono-code">
                        {formatRupiah(product.price)}
                      </span>

                      {/* Quantity Controls */}
                      <div className="flex items-center gap-2 justify-center">
                        <button
                          disabled={qty === 0}
                          onClick={() => onRemoveFromCart(product)}
                          className={`w-8 h-8 rounded-full flex items-center justify-center transition-transform active:scale-90 ${
                            qty > 0
                              ? 'bg-[#6cf8bb] text-[#00714d] hover:bg-[#4edea3]'
                              : 'bg-[#eff4ff] dark:bg-slate-800 text-[#c6c6cd] dark:text-slate-600 cursor-not-allowed'
                          }`}
                        >
                          <span className="material-symbols-outlined text-base">remove</span>
                        </button>

                        <span className="font-mono-code text-xs font-bold text-[#0b1c30] dark:text-slate-100 w-5 text-center">
                          {qty}
                        </span>

                        <button
                          disabled={isOutOfStock || qty >= product.stock}
                          onClick={() => onAddToCart(product)}
                          className={`w-8 h-8 rounded-full flex items-center justify-center transition-transform active:scale-90 ${
                            !isOutOfStock && qty < product.stock
                              ? 'bg-[#0d47a1] dark:bg-sky-600 text-white hover:bg-[#0a3880]'
                              : 'bg-[#eff4ff] dark:bg-slate-800 text-[#c6c6cd] dark:text-slate-600 cursor-not-allowed'
                          }`}
                        >
                          <span className="material-symbols-outlined text-base">add</span>
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </main>

      {/* Sticky Cart Bar (Mobile & Floating Action) */}
      {cart.length > 0 && (
        <div className="fixed bottom-14 md:bottom-4 landscape:bottom-4 left-0 right-0 md:left-52 landscape:left-52 z-30 px-4 md:px-8 pb-3 pt-4 bg-gradient-to-t from-[#f8f9ff] dark:from-[#0b1c30] via-[#f8f9ff]/90 dark:via-[#0b1c30]/90 to-transparent">
          <button
            onClick={onOpenCart}
            className="w-full max-w-2xl mx-auto bg-[#0d47a1] dark:bg-sky-600 hover:bg-[#0a3880] text-white rounded-full h-13 flex items-center justify-between px-6 shadow-lg active:scale-[0.99] transition-all"
          >
            <div className="flex items-center gap-3">
              <div className="bg-white/20 text-white w-8 h-8 rounded-full flex items-center justify-center font-mono-code text-xs font-bold">
                {totalCartCount}
              </div>
              <span className="font-semibold text-sm text-white">Lihat Keranjang</span>
            </div>

            <div className="flex items-center gap-2">
              <span className="font-bold text-sm font-mono-code text-white">
                {formatRupiah(totalCartAmount)}
              </span>
              <span className="material-symbols-outlined text-xl">chevron_right</span>
            </div>
          </button>
        </div>
      )}
    </div>
  );
};
