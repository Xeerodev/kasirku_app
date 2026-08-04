import React, { useState } from 'react';
import { Product } from '../types';
import { formatRupiah } from '../lib/formatters';

interface StockViewProps {
  products: Product[];
  onOpenAddModal: () => void;
  onOpenEditModal: (product: Product) => void;
  onDeleteProduct: (productId: string) => void;
}

export const StockView: React.FC<StockViewProps> = ({
  products,
  onOpenAddModal,
  onOpenEditModal,
  onDeleteProduct
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [deletingProduct, setDeletingProduct] = useState<Product | null>(null);

  const filteredProducts = products.filter(
    (p) =>
      p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.category.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleConfirmDelete = () => {
    if (deletingProduct) {
      onDeleteProduct(deletingProduct.id);
      setDeletingProduct(null);
    }
  };

  return (
    <div className="min-h-screen bg-[#f8f9ff] dark:bg-[#0b1c30] text-[#0b1c30] dark:text-slate-100 flex flex-col pb-20 md:pb-8 landscape:pb-8 md:pl-52 landscape:pl-52">
      <main className="flex-1 p-4 sm:p-6 max-w-5xl mx-auto w-full">
        {/* Header */}
        <header className="mb-6 flex flex-col gap-1">
          <h1 className="text-[28px] leading-[36px] font-bold text-[#0d47a1] dark:text-[#64b5f6]">
            Manajemen Stok
          </h1>
          <p className="text-xs text-[#45464d] dark:text-slate-400">
            Kelola ketersediaan produk dan harga barang
          </p>
        </header>

        {/* Search Bar */}
        <div className="mb-6 relative w-full shadow-xs rounded-xl">
          <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-[#76777d] dark:text-slate-400">
            search
          </span>
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Cari Produk..."
            className="w-full h-[52px] pl-12 pr-4 bg-white dark:bg-[#12253c] rounded-xl border border-[#c6c6cd]/50 dark:border-slate-700 focus:ring-2 focus:ring-[#2196f3] focus:border-[#2196f3] text-[#0b1c30] dark:text-slate-100 text-sm transition-shadow outline-none"
          />
          {searchQuery && (
            <button
              onClick={() => setSearchQuery('')}
              className="absolute right-4 top-1/2 -translate-y-1/2 text-[#76777d] dark:text-slate-400"
            >
              <span className="material-symbols-outlined text-lg">close</span>
            </button>
          )}
        </div>

        {/* Product Stock List */}
        <div className="space-y-4">
          {filteredProducts.length === 0 ? (
            <div className="bg-white dark:bg-[#12253c] p-8 rounded-2xl text-center border border-dashed border-[#2196f3]/30">
              <span className="material-symbols-outlined text-4xl text-[#2196f3] mb-2">
                inventory_2
              </span>
              <p className="font-bold text-[#0b1c30] dark:text-slate-100">Belum Ada Produk dalam Stok</p>
              <p className="text-xs text-[#45464d] dark:text-slate-400 mt-1">
                Klik tombol '+' di bawah untuk menambahkan produk baru.
              </p>
            </div>
          ) : (
            filteredProducts.map((product) => {
              const isLowStock = product.stock > 0 && product.stock <= 3;
              const isOutOfStock = product.stock === 0;

              return (
                <div
                  key={product.id}
                  className={`flex flex-col p-4 bg-white dark:bg-[#12253c] rounded-xl shadow-xs border transition-all duration-200 hover:shadow-md ${
                    isOutOfStock
                      ? 'border-[#ffdad6] dark:border-red-900/50 opacity-80'
                      : isLowStock
                      ? 'border-[#ffedd5] dark:border-amber-900/50'
                      : 'border-[#c6c6cd]/30 dark:border-slate-700/60'
                  }`}
                >
                  <div className="flex items-start gap-4">
                    {/* Thumbnail Image */}
                    <div className="relative w-20 h-20 flex-shrink-0 bg-[#f5faff] dark:bg-slate-800 rounded-lg overflow-hidden border border-[#c6c6cd]/30 dark:border-slate-700 shadow-2xs">
                      {product.image ? (
                        <img
                          src={product.image}
                          alt={product.name}
                          className={`w-full h-full object-cover ${
                            isOutOfStock ? 'grayscale' : ''
                          }`}
                        />
                      ) : (
                        <div className="w-full h-full flex flex-col items-center justify-center bg-[#eff4ff] dark:bg-slate-800 text-[#76777d] dark:text-slate-400">
                          <span className="material-symbols-outlined text-2xl">
                            inventory
                          </span>
                        </div>
                      )}
                      {isOutOfStock && (
                        <div className="absolute inset-0 bg-white/40 dark:bg-black/40 rounded-lg" />
                      )}
                    </div>

                    {/* Info */}
                    <div className="flex-1 min-w-0">
                      <div className="flex justify-between items-start">
                        <div className="pr-2">
                          <h2 className="font-semibold text-sm text-[#0b1c30] dark:text-slate-100 truncate mb-0.5">
                            {product.name}
                          </h2>
                          <p className="text-xs text-[#45464d] dark:text-slate-400 truncate font-mono-code">
                            {product.category}
                          </p>
                        </div>
                      </div>

                      <div className="flex justify-between items-end mt-3">
                        <div className="flex flex-col gap-0.5">
                          {isOutOfStock ? (
                            <div className="text-[#ba1a1a] dark:text-red-400 font-mono-code text-[11px] font-bold flex items-center gap-1">
                              <span className="material-symbols-outlined text-[13px]">
                                block
                              </span>
                              <span>Habis</span>
                            </div>
                          ) : isLowStock ? (
                            <div className="text-[#ea580c] dark:text-amber-400 font-mono-code text-[11px] font-bold flex items-center gap-1">
                              <span className="material-symbols-outlined text-[13px]">
                                warning
                              </span>
                              <span>Sisa {product.stock}</span>
                            </div>
                          ) : (
                            <div className="text-[#0d47a1] dark:text-sky-400 font-mono-code text-[11px] flex items-center gap-1">
                              <span>Stok:</span>
                              <span className="font-bold">{product.stock}</span>
                            </div>
                          )}

                          <p className="font-bold text-[#0d47a1] dark:text-sky-300 text-base font-mono-code">
                            {formatRupiah(product.price)}
                          </p>
                        </div>

                        {/* Action buttons */}
                        <div className="flex gap-1 bg-[#e3f2fd] dark:bg-slate-800 rounded-lg p-1 border border-[#2196f3]/20 dark:border-slate-700">
                          <button
                            onClick={() => onOpenEditModal(product)}
                            className="w-8 h-8 flex items-center justify-center rounded-md text-[#0d47a1] dark:text-sky-300 hover:bg-[#90caf9]/50 dark:hover:bg-slate-700 transition-colors"
                            title="Edit"
                          >
                            <span className="material-symbols-outlined text-lg">edit</span>
                          </button>
                          <button
                            onClick={() => setDeletingProduct(product)}
                            className="w-8 h-8 flex items-center justify-center rounded-md text-[#ba1a1a] dark:text-red-400 hover:bg-red-100 dark:hover:bg-red-950/50 transition-colors"
                            title="Hapus"
                          >
                            <span className="material-symbols-outlined text-lg">
                              delete
                            </span>
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              );
            })
          )}
        </div>
      </main>

      {/* Delete Confirmation Modal */}
      {deletingProduct && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="bg-white dark:bg-[#12253c] rounded-2xl max-w-sm w-full p-6 text-center space-y-4 border border-[#c6c6cd] dark:border-slate-700 shadow-xl">
            <div className="w-12 h-12 rounded-full bg-[#ffdad6] dark:bg-red-900/40 text-[#ba1a1a] dark:text-red-300 flex items-center justify-center mx-auto">
              <span className="material-symbols-outlined text-2xl">delete</span>
            </div>
            <div>
              <h3 className="font-bold text-base text-[#0b1c30] dark:text-slate-100">
                Hapus Produk?
              </h3>
              <p className="text-xs text-[#45464d] dark:text-slate-400 mt-1">
                Apakah Anda yakin ingin menghapus <strong>"{deletingProduct.name}"</strong> dari daftar stok?
              </p>
            </div>
            <div className="flex gap-2 pt-2">
              <button
                onClick={() => setDeletingProduct(null)}
                className="flex-1 py-2.5 bg-gray-100 dark:bg-slate-800 text-[#0b1c30] dark:text-slate-200 rounded-xl text-xs font-semibold hover:bg-gray-200 dark:hover:bg-slate-700"
              >
                Batal
              </button>
              <button
                onClick={handleConfirmDelete}
                className="flex-1 py-2.5 bg-[#ba1a1a] text-white rounded-xl text-xs font-semibold hover:bg-red-800 transition-colors"
              >
                Hapus
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Floating Action Button (FAB) */}
      <button
        onClick={onOpenAddModal}
        className="fixed right-6 bottom-20 md:bottom-8 w-14 h-14 bg-[#0d47a1] text-white rounded-2xl flex items-center justify-center shadow-lg hover:shadow-xl hover:bg-[#0a3880] transition-all z-30 active:scale-95"
        title="Tambah Produk Baru"
      >
        <span className="material-symbols-outlined text-[28px]">add</span>
      </button>
    </div>
  );
};
