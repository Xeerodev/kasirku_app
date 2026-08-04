import React, { useState, useEffect, useRef } from 'react';
import { Product } from '../types';

interface ProductFormModalProps {
  isOpen: boolean;
  productToEdit?: Product | null;
  existingCategories?: string[];
  onClose: () => void;
  onSaveProduct: (product: Partial<Product>) => void;
}

export const ProductFormModal: React.FC<ProductFormModalProps> = ({
  isOpen,
  productToEdit,
  existingCategories = ['Kopi', 'Kue', 'Merchandise', 'Biji Kopi', 'Teh', 'Minuman'],
  onClose,
  onSaveProduct
}) => {
  if (!isOpen) return null;

  const [name, setName] = useState('');
  const [category, setCategory] = useState('Kopi');
  const [customCategory, setCustomCategory] = useState('');
  const [isCustomCategory, setIsCustomCategory] = useState(false);
  const [price, setPrice] = useState<number | ''>('');
  const [stock, setStock] = useState<number | ''>('');
  const [image, setImage] = useState('');
  const [description, setDescription] = useState('');
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Combine default & existing unique categories
  const categoryOptions = Array.from(
    new Set([...existingCategories, 'Kopi', 'Kue', 'Merchandise', 'Biji Kopi', 'Teh', 'Minuman'])
  );

  useEffect(() => {
    if (productToEdit) {
      setName(productToEdit.name);
      setPrice(productToEdit.price);
      setStock(productToEdit.stock);
      setImage(productToEdit.image || '');
      setDescription(productToEdit.description || '');

      if (categoryOptions.includes(productToEdit.category)) {
        setCategory(productToEdit.category);
        setIsCustomCategory(false);
        setCustomCategory('');
      } else {
        setCategory('__custom__');
        setIsCustomCategory(true);
        setCustomCategory(productToEdit.category);
      }
    } else {
      setName('');
      setCategory(categoryOptions[0] || 'Kopi');
      setIsCustomCategory(false);
      setCustomCategory('');
      setPrice('');
      setStock('');
      setImage('');
      setDescription('');
    }
  }, [productToEdit, isOpen]);

  const handleImageFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (file.size > 5 * 1024 * 1024) {
      alert('Ukuran gambar terlalu besar! Maksimal 5MB.');
      return;
    }

    const reader = new FileReader();
    reader.onload = (event) => {
      if (event.target?.result) {
        setImage(event.target.result as string);
      }
    };
    reader.readAsDataURL(file);
  };

  const handleRemoveImage = () => {
    setImage('');
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    const finalCategory = isCustomCategory
      ? customCategory.trim()
      : category === '__custom__'
      ? customCategory.trim()
      : category;

    if (!name || price === '' || stock === '') {
      alert('Mohon isi nama produk, harga, dan jumlah stok!');
      return;
    }

    if (!finalCategory) {
      alert('Mohon tentukan kategori produk!');
      return;
    }

    onSaveProduct({
      id: productToEdit ? productToEdit.id : undefined,
      name,
      category: finalCategory,
      price: Number(price),
      stock: Number(stock),
      image,
      description
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-xs p-3 overflow-y-auto">
      <div className="bg-white dark:bg-[#12253c] text-[#0b1c30] dark:text-slate-100 rounded-2xl max-w-md w-full overflow-hidden shadow-xl border border-[#c6c6cd] dark:border-slate-700 my-auto">
        <div className="flex justify-between items-center px-5 py-3 border-b border-[#c6c6cd]/40 dark:border-slate-700 bg-[#f8f9ff] dark:bg-slate-800/80">
          <h2 className="font-bold text-base text-[#0d47a1] dark:text-sky-300">
            {productToEdit ? 'Edit Produk' : 'Tambah Produk Baru'}
          </h2>
          <button
            type="button"
            onClick={onClose}
            className="w-7 h-7 rounded-full flex items-center justify-center hover:bg-gray-200 dark:hover:bg-slate-700 text-[#76777d] dark:text-slate-400"
          >
            <span className="material-symbols-outlined text-base">close</span>
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-5 space-y-3.5 text-xs">
          {/* Nama Produk */}
          <div>
            <label className="block font-semibold text-[#0b1c30] dark:text-slate-200 mb-1 font-mono-code">
              Nama Produk
            </label>
            <input
              type="text"
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="cth. Latte Special"
              className="w-full h-10 px-3 rounded-xl border border-[#c6c6cd] dark:border-slate-600 bg-white dark:bg-slate-800 text-[#0b1c30] dark:text-slate-100 focus:ring-2 focus:ring-[#0d47a1] outline-none"
            />
          </div>

          {/* Kategori */}
          <div>
            <div className="flex justify-between items-center mb-1">
              <label className="font-semibold text-[#0b1c30] dark:text-slate-200 font-mono-code">
                Kategori
              </label>
              <button
                type="button"
                onClick={() => {
                  setIsCustomCategory(!isCustomCategory);
                  if (!isCustomCategory) {
                    setCategory('__custom__');
                  } else {
                    setCategory(categoryOptions[0] || 'Kopi');
                  }
                }}
                className="text-[11px] text-[#0d47a1] dark:text-sky-400 font-semibold hover:underline"
              >
                {isCustomCategory ? 'Pilih dari Daftar' : '+ Ketik Manual'}
              </button>
            </div>

            {!isCustomCategory ? (
              <select
                value={category}
                onChange={(e) => {
                  if (e.target.value === '__custom__') {
                    setIsCustomCategory(true);
                  } else {
                    setCategory(e.target.value);
                  }
                }}
                className="w-full h-10 px-3 rounded-xl border border-[#c6c6cd] dark:border-slate-600 bg-white dark:bg-slate-800 text-[#0b1c30] dark:text-slate-100 focus:ring-2 focus:ring-[#0d47a1] outline-none"
              >
                {categoryOptions.map((cat) => (
                  <option key={cat} value={cat}>
                    {cat}
                  </option>
                ))}
                <option value="__custom__">+ Ketik Kategori Baru...</option>
              </select>
            ) : (
              <input
                type="text"
                required
                value={customCategory}
                onChange={(e) => setCustomCategory(e.target.value)}
                placeholder="Tulis nama kategori baru..."
                className="w-full h-10 px-3 rounded-xl border border-[#0d47a1] dark:border-sky-400 bg-white dark:bg-slate-800 text-[#0b1c30] dark:text-slate-100 focus:ring-2 focus:ring-[#0d47a1] outline-none"
              />
            )}

            {/* Quick Category Chips */}
            <div className="flex flex-wrap gap-1.5 mt-2">
              {categoryOptions.slice(0, 6).map((cat) => (
                <button
                  key={cat}
                  type="button"
                  onClick={() => {
                    setIsCustomCategory(false);
                    setCategory(cat);
                  }}
                  className={`px-2.5 py-1 rounded-full text-[10px] font-mono-code border transition-colors ${
                    !isCustomCategory && category === cat
                      ? 'bg-[#0d47a1] dark:bg-sky-600 text-white border-transparent font-bold'
                      : 'bg-[#eff4ff] dark:bg-slate-800 text-[#45464d] dark:text-slate-300 border-[#c6c6cd]/50 dark:border-slate-700 hover:bg-[#dce9ff]'
                  }`}
                >
                  {cat}
                </button>
              ))}
            </div>
          </div>

          {/* Harga & Stok */}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block font-semibold text-[#0b1c30] dark:text-slate-200 mb-1 font-mono-code">
                Harga (Rp)
              </label>
              <input
                type="number"
                required
                min="0"
                value={price}
                onChange={(e) => setPrice(e.target.value ? Number(e.target.value) : '')}
                placeholder="25000"
                className="w-full h-10 px-3 rounded-xl border border-[#c6c6cd] dark:border-slate-600 bg-white dark:bg-slate-800 font-mono-code text-[#0b1c30] dark:text-slate-100 focus:ring-2 focus:ring-[#0d47a1] outline-none"
              />
            </div>

            <div>
              <label className="block font-semibold text-[#0b1c30] dark:text-slate-200 mb-1 font-mono-code">
                Jumlah Stok
              </label>
              <input
                type="number"
                required
                min="0"
                value={stock}
                onChange={(e) => setStock(e.target.value ? Number(e.target.value) : '')}
                placeholder="50"
                className="w-full h-10 px-3 rounded-xl border border-[#c6c6cd] dark:border-slate-600 bg-white dark:bg-slate-800 font-mono-code text-[#0b1c30] dark:text-slate-100 focus:ring-2 focus:ring-[#0d47a1] outline-none"
              />
            </div>
          </div>

          {/* Upload Gambar Produk */}
          <div>
            <label className="block font-semibold text-[#0b1c30] dark:text-slate-200 mb-1 font-mono-code">
              Gambar Produk
            </label>

            <input
              type="file"
              ref={fileInputRef}
              accept="image/*"
              onChange={handleImageFileChange}
              className="hidden"
            />

            {image ? (
              <div className="relative w-full h-28 rounded-xl border border-[#c6c6cd] dark:border-slate-600 overflow-hidden bg-slate-100 dark:bg-slate-800 flex items-center justify-center group">
                <img src={image} alt="Preview" className="w-full h-full object-cover" />
                <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
                  <button
                    type="button"
                    onClick={() => fileInputRef.current?.click()}
                    className="px-3 py-1.5 bg-white text-[#0b1c30] rounded-lg font-bold text-[11px] shadow-sm hover:bg-gray-100"
                  >
                    Ganti
                  </button>
                  <button
                    type="button"
                    onClick={handleRemoveImage}
                    className="px-3 py-1.5 bg-[#ba1a1a] text-white rounded-lg font-bold text-[11px] shadow-sm hover:bg-red-700"
                  >
                    Hapus
                  </button>
                </div>
              </div>
            ) : (
              <button
                type="button"
                onClick={() => fileInputRef.current?.click()}
                className="w-full h-24 rounded-xl border-2 border-dashed border-[#c6c6cd] dark:border-slate-600 hover:border-[#0d47a1] bg-[#f8f9ff] dark:bg-slate-800/60 flex flex-col items-center justify-center gap-1 transition-colors text-[#45464d] dark:text-slate-400 active:scale-[0.99]"
              >
                <span className="material-symbols-outlined text-2xl text-[#0d47a1] dark:text-sky-400">
                  cloud_upload
                </span>
                <span className="font-semibold text-[11px]">Upload Gambar dari Galeri</span>
                <span className="text-[10px] text-gray-400">JPG, PNG, WEBP (Maks 5MB)</span>
              </button>
            )}
          </div>

          {/* Deskripsi */}
          <div>
            <label className="block font-semibold text-[#0b1c30] dark:text-slate-200 mb-1 font-mono-code">
              Deskripsi Produk
            </label>
            <textarea
              rows={2}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Deskripsi singkat produk..."
              className="w-full p-2.5 rounded-xl border border-[#c6c6cd] dark:border-slate-600 bg-white dark:bg-slate-800 text-[#0b1c30] dark:text-slate-100 focus:ring-2 focus:ring-[#0d47a1] outline-none resize-none"
            />
          </div>

          {/* Buttons */}
          <div className="pt-2 flex gap-2.5">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 py-2.5 border border-[#c6c6cd] dark:border-slate-600 rounded-xl text-xs font-semibold text-[#45464d] dark:text-slate-300 hover:bg-gray-100 dark:hover:bg-slate-700"
            >
              Batal
            </button>
            <button
              type="submit"
              className="flex-1 py-2.5 bg-[#0d47a1] dark:bg-sky-600 text-white rounded-xl text-xs font-semibold hover:bg-[#0a3880] shadow-sm"
            >
              Simpan Produk
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
