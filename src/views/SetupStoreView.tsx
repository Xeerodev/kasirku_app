import React, { useState } from 'react';
import { StoreProfile } from '../types';

interface SetupStoreViewProps {
  storeProfile: StoreProfile;
  onSaveProfile: (profile: StoreProfile) => void;
  onSwitchToLogin: () => void;
}

export const SetupStoreView: React.FC<SetupStoreViewProps> = ({
  storeProfile,
  onSaveProfile,
  onSwitchToLogin
}) => {
  const [name, setName] = useState(storeProfile.name || 'Kedai Kopi Sentral');
  const [address, setAddress] = useState(storeProfile.address || 'Jl. Sudirman No. 123, Jakarta Selatan');
  const [phone, setPhone] = useState(storeProfile.phone || '081234567890');
  const [logoUrl, setLogoUrl] = useState(storeProfile.logoUrl || 'https://lh3.googleusercontent.com/aida-public/AB6AXuAauGAhbu65K_I1wi0o-PzU4TJB6Ig9t-yvYC4SNcKStpfTwkEcBW_3Z-b2qBLuStZykRlT8Y5vMjh5sGnCKla8PhWJSoCbGMUlcGJ73SgmDHyopgfACCEeRI8VN4sfcgs0xD0UvBqyMNkhpmqzf2rlfDSGuAf0hjyhibHjPqAWmz-extPRXkEqUDyD6NSq8hGYLGcyZEKn4HpQCQHDJNVLG92Nny2Hv-sA3myLcC2CoUXnqlfCPTPsULIUSMjhZV0vOg');

  const handleLogoUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setLogoUrl(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSaveProfile({
      name: name || 'Toko Baru',
      address,
      phone,
      logoUrl,
      isConfigured: true
    });
  };

  return (
    <div className="min-h-screen bg-[#e3f2fd] text-[#0b1c30] flex items-center justify-center p-4 md:p-8">
      <div className="w-full max-w-[1100px] bg-[#e3f2fd] md:bg-white rounded-2xl shadow-xl border border-[#2196f3]/40 overflow-hidden flex flex-col md:flex-row">
        {/* Left Side: Branding (Desktop) */}
        <div className="hidden md:flex flex-col flex-1 bg-[#d3e4fe]/60 p-10 justify-between border-r border-[#c6c6cd]">
          <div>
            <div className="w-16 h-16 rounded-2xl bg-[#0d47a1] overflow-hidden mb-6 shadow-md p-2 flex items-center justify-center">
              {logoUrl ? (
                <img
                  src={logoUrl}
                  alt="Kasirku Logo"
                  className="w-full h-full object-cover rounded-xl"
                />
              ) : (
                <span className="material-symbols-outlined text-white text-3xl material-symbols-filled">
                  storefront
                </span>
              )}
            </div>
            <h1 className="text-3xl font-bold text-[#0d47a1] mb-4 tracking-tight">
              Atur Toko Anda
            </h1>
            <p className="text-base text-[#45464d] leading-relaxed max-w-md">
              Bergabunglah dengan ribuan pedagang yang mengelola inventaris, melacak penjualan, dan mengembangkan bisnis mereka bersama Kasirku. Persiapan hanya membutuhkan kurang dari satu menit.
            </p>
          </div>

          <div className="mt-8 bg-white p-6 rounded-2xl border border-[#2196f3]/30 shadow-sm">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-10 h-10 rounded-full bg-[#e3f2fd] text-[#0d47a1] flex items-center justify-center">
                <span className="material-symbols-outlined text-2xl material-symbols-filled">
                  speed
                </span>
              </div>
              <h3 className="font-semibold text-lg text-[#0d47a1]">
                Dibuat untuk Kecepatan
              </h3>
            </div>
            <p className="text-sm text-[#45464d] leading-normal">
              Antarmuka kami dioptimalkan untuk lingkungan ritel berkecepatan tinggi, meminimalkan sentuhan dan memaksimalkan kecepatan pembayaran.
            </p>
          </div>
        </div>

        {/* Right Side: Form */}
        <div className="flex-1 flex flex-col justify-center p-6 sm:p-10 md:p-12 bg-[#e3f2fd]">
          {/* Mobile Header */}
          <div className="md:hidden flex items-center gap-4 mb-6">
            <div className="w-12 h-12 rounded-xl bg-[#0d47a1] p-1.5 shadow-sm flex items-center justify-center">
              <span className="material-symbols-outlined text-white text-2xl material-symbols-filled">
                storefront
              </span>
            </div>
            <div>
              <h1 className="text-2xl font-bold text-[#0d47a1]">Atur Toko Anda</h1>
              <p className="text-xs text-[#45464d]">Registrasi toko usaha baru</p>
            </div>
          </div>

          <form onSubmit={handleSubmit} className="w-full max-w-md mx-auto space-y-5">
            {/* Upload Logo */}
            <div>
              <label className="block text-sm font-semibold text-[#0b1c30] mb-2 font-mono-code">
                Upload Logo Toko <span className="text-xs font-normal opacity-70">(Opsional)</span>
              </label>
              <div className="flex items-center justify-center w-full">
                <label className="flex flex-col items-center justify-center w-full border-2 border-[#2196f3] border-dashed rounded-xl cursor-pointer bg-white hover:bg-blue-50/50 transition-colors h-20 relative overflow-hidden group">
                  {logoUrl ? (
                    <div className="flex items-center gap-3 px-4 w-full">
                      <img
                        src={logoUrl}
                        alt="Logo Preview"
                        className="w-12 h-12 object-cover rounded-lg border border-[#2196f3]"
                      />
                      <div className="flex-1 min-w-0">
                        <p className="text-xs font-bold text-[#0d47a1] truncate">Logo Terpilih</p>
                        <p className="text-[11px] text-[#76777d]">Klik untuk mengganti gambar</p>
                      </div>
                      <span className="material-symbols-outlined text-[#2196f3]">cloud_upload</span>
                    </div>
                  ) : (
                    <div className="flex flex-col items-center justify-center gap-1">
                      <span className="material-symbols-outlined text-[#2196f3] text-2xl">
                        cloud_upload
                      </span>
                      <p className="text-xs text-[#45464d]">
                        Upload Logo <span className="text-[11px] opacity-70">(Opsional)</span>
                      </p>
                    </div>
                  )}
                  <input
                    type="file"
                    accept="image/*"
                    className="hidden"
                    onChange={handleLogoUpload}
                  />
                </label>
              </div>
            </div>

            {/* Store Name */}
            <div>
              <label htmlFor="store_name" className="block text-sm font-semibold text-[#0b1c30] mb-1.5 font-mono-code">
                Nama Toko
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                  <span className="material-symbols-outlined text-[#2196f3] text-xl">
                    storefront
                  </span>
                </div>
                <input
                  id="store_name"
                  type="text"
                  required
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="cth. Kedai Kopi Sentral"
                  className="block w-full pl-11 pr-4 py-3 border border-[#2196f3] rounded-xl bg-white focus:ring-2 focus:ring-[#0d47a1] focus:border-[#0d47a1] outline-none transition-all text-sm"
                />
              </div>
            </div>

            {/* Address */}
            <div>
              <label htmlFor="address" className="block text-sm font-semibold text-[#0b1c30] mb-1.5 font-mono-code">
                Alamat Toko
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 pt-3 pointer-events-none">
                  <span className="material-symbols-outlined text-[#2196f3] text-xl">
                    location_on
                  </span>
                </div>
                <textarea
                  id="address"
                  rows={3}
                  required
                  value={address}
                  onChange={(e) => setAddress(e.target.value)}
                  placeholder="Alamat jalan lengkap"
                  className="block w-full pl-11 pr-4 py-2.5 border border-[#2196f3] rounded-xl bg-white focus:ring-2 focus:ring-[#0d47a1] focus:border-[#0d47a1] outline-none transition-all text-sm resize-none"
                />
              </div>
            </div>

            {/* Phone Number */}
            <div>
              <label htmlFor="phone_number" className="block text-sm font-semibold text-[#0b1c30] mb-1.5 font-mono-code">
                Nomor HP
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                  <span className="material-symbols-outlined text-[#2196f3] text-xl">
                    call
                  </span>
                </div>
                <input
                  id="phone_number"
                  type="tel"
                  required
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="cth. 081234567890"
                  className="block w-full pl-11 pr-4 py-3 border border-[#2196f3] rounded-xl bg-white focus:ring-2 focus:ring-[#0d47a1] focus:border-[#0d47a1] outline-none transition-all text-sm"
                />
              </div>
            </div>

            {/* Submit Action */}
            <div className="pt-2">
              <button
                type="submit"
                className="w-full h-14 bg-[#0d47a1] hover:bg-[#0a3880] text-white font-semibold text-base rounded-full flex items-center justify-center gap-3 transition-all shadow-md active:scale-[0.99]"
              >
                <span>Mulai Sekarang</span>
                <span className="material-symbols-outlined text-xl">arrow_forward</span>
              </button>

              <p className="mt-4 text-center text-xs text-[#45464d] leading-normal">
                Dengan melanjutkan, Anda menyetujui Ketentuan Layanan dan Kebijakan Privasi kami.
              </p>

              <div className="mt-4 pt-3 border-t border-[#2196f3]/20 flex justify-center">
                <button
                  type="button"
                  onClick={onSwitchToLogin}
                  className="text-xs font-semibold text-[#0d47a1] hover:underline"
                >
                  Sudah punya akun? Masuk di sini
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};
