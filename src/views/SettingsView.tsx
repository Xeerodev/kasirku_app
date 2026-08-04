import React, { useState } from 'react';
import { StoreProfile, PrinterSettings, SystemSettings } from '../types';

interface SettingsViewProps {
  storeProfile: StoreProfile;
  printerSettings: PrinterSettings;
  systemSettings: SystemSettings;
  onSaveProfile: (profile: StoreProfile) => void;
  onSavePrinter: (printer: PrinterSettings) => void;
  onSaveSystem: (system: SystemSettings) => void;
  onLogout: () => void;
}

export const SettingsView: React.FC<SettingsViewProps> = ({
  storeProfile,
  printerSettings,
  systemSettings,
  onSaveProfile,
  onSavePrinter,
  onSaveSystem,
  onLogout
}) => {
  // Local form states
  const [name, setName] = useState(storeProfile.name);
  const [cashierName, setCashierName] = useState(storeProfile.cashierName || 'Ahmad (Kasir 1)');
  const [address, setAddress] = useState(storeProfile.address);
  const [phone, setPhone] = useState(storeProfile.phone);
  const [logoUrl, setLogoUrl] = useState(storeProfile.logoUrl);

  const [activePrinter, setActivePrinter] = useState(printerSettings.activePrinter);
  const [autoPrintReceipt, setAutoPrintReceipt] = useState(printerSettings.autoPrintReceipt);
  const [footerMessage, setFooterMessage] = useState(printerSettings.footerMessage);

  const [language, setLanguage] = useState(systemSettings.language);
  const [darkMode, setDarkMode] = useState(systemSettings.darkMode);

  const handleSaveProfile = (e: React.FormEvent) => {
    e.preventDefault();
    onSaveProfile({
      name,
      cashierName,
      address,
      phone,
      logoUrl,
      isConfigured: true
    });
    alert('Profil toko & nama kasir berhasil diperbarui!');
  };

  const handleContactDev = () => {
    window.open(
      'https://wa.me/6283164004093?text=' + encodeURIComponent('mau kasih masukan'),
      '_blank'
    );
  };

  const handleTestPrint = () => {
    alert(`Mengirim perintah Test Print ke printer "${activePrinter}"...`);
  };

  const handleBackupData = () => {
    const dataStr =
      'data:text/json;charset=utf-8,' +
      encodeURIComponent(
        JSON.stringify({
          storeProfile,
          printerSettings,
          systemSettings,
          timestamp: new Date().toISOString()
        })
      );
    const downloadAnchor = document.createElement('a');
    downloadAnchor.setAttribute('href', dataStr);
    downloadAnchor.setAttribute('download', `kasirku-backup-${Date.now()}.json`);
    document.body.appendChild(downloadAnchor);
    downloadAnchor.click();
    downloadAnchor.remove();
  };

  return (
    <div className="min-h-screen bg-[#f8f9ff] dark:bg-[#0b1c30] text-[#0f1d25] dark:text-slate-100 flex flex-col pb-20 md:pb-8 landscape:pb-8 md:pl-52 landscape:pl-52">
      {/* Top Header */}
      <header className="bg-white dark:bg-[#12253c] border-b border-[#c3c6d4]/40 dark:border-slate-700/60 flex justify-between items-center px-4 md:px-8 h-16 sticky top-0 z-20">
        <div className="flex items-center gap-2">
          <span className="material-symbols-outlined text-[#003178] dark:text-sky-400 text-2xl material-symbols-filled">
            settings
          </span>
          <h1 className="text-xl md:text-2xl font-bold text-[#003178] dark:text-sky-300">Pengaturan</h1>
        </div>
        <button
          onClick={handleContactDev}
          className="py-2 px-3 bg-[#25D366] hover:bg-[#20bd5a] text-white rounded-xl text-xs font-bold flex items-center gap-1.5 shadow-xs transition-all active:scale-95"
        >
          <span className="material-symbols-outlined text-base">chat</span>
          <span className="hidden sm:inline">Hubungi Developer</span>
        </button>
      </header>

      {/* Main Settings Content */}
      <main className="p-4 md:p-8 max-w-4xl mx-auto w-full space-y-6">
        {/* 1. Profil Toko & Kasir */}
        <section className="bg-white dark:bg-[#12253c] rounded-2xl border border-[#c3c6d4]/40 dark:border-slate-700/60 p-6 shadow-xs">
          <h2 className="text-lg font-bold text-[#003178] dark:text-sky-300 mb-4 flex items-center gap-2">
            <span className="material-symbols-outlined text-xl">store</span>
            <span>Profil Toko & Kasir</span>
          </h2>

          <form onSubmit={handleSaveProfile} className="flex flex-col md:flex-row gap-6">
            <div className="flex-shrink-0 flex flex-col items-center">
              <div className="w-32 h-32 rounded-xl bg-[#e9f5ff] dark:bg-slate-800 flex items-center justify-center overflow-hidden border border-[#c3c6d4]/50 dark:border-slate-700 mb-2">
                {logoUrl ? (
                  <img src={logoUrl} alt="Logo Toko" className="w-full h-full object-cover" />
                ) : (
                  <span className="material-symbols-outlined text-4xl text-[#737783]">
                    storefront
                  </span>
                )}
              </div>
              <button
                type="button"
                onClick={() => {
                  const url = prompt('Masukkan URL gambar logo baru:', logoUrl);
                  if (url !== null) setLogoUrl(url);
                }}
                className="text-xs font-semibold text-[#0061a4] dark:text-sky-400 hover:underline font-mono-code"
              >
                Ubah Logo
              </button>
            </div>

            <div className="flex-1 space-y-4">
              <div>
                <label className="block text-xs font-semibold text-[#434652] dark:text-slate-300 mb-1 font-mono-code">
                  Nama Toko
                </label>
                <input
                  type="text"
                  required
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="w-full h-11 px-3.5 rounded-xl border border-[#c3c6d4] dark:border-slate-700 bg-[#f5faff] dark:bg-slate-800 text-sm dark:text-slate-100 focus:border-[#0061a4] outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#434652] dark:text-slate-300 mb-1 font-mono-code">
                  Nama Kasir (Ditampilkan di Struk)
                </label>
                <input
                  type="text"
                  required
                  value={cashierName}
                  onChange={(e) => setCashierName(e.target.value)}
                  placeholder="Contoh: Budi / Admin Kasir"
                  className="w-full h-11 px-3.5 rounded-xl border border-[#c3c6d4] dark:border-slate-700 bg-[#f5faff] dark:bg-slate-800 text-sm dark:text-slate-100 focus:border-[#0061a4] outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#434652] dark:text-slate-300 mb-1 font-mono-code">
                  Alamat
                </label>
                <textarea
                  rows={2}
                  value={address}
                  onChange={(e) => setAddress(e.target.value)}
                  className="w-full p-3 rounded-xl border border-[#c3c6d4] dark:border-slate-700 bg-[#f5faff] dark:bg-slate-800 text-sm dark:text-slate-100 focus:border-[#0061a4] outline-none resize-none"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#434652] dark:text-slate-300 mb-1 font-mono-code">
                  Nomor Telepon
                </label>
                <input
                  type="tel"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  className="w-full h-11 px-3.5 rounded-xl border border-[#c3c6d4] dark:border-slate-700 bg-[#f5faff] dark:bg-slate-800 text-sm dark:text-slate-100 focus:border-[#0061a4] outline-none"
                />
              </div>

              <button
                type="submit"
                className="h-11 px-6 bg-[#0061a4] hover:bg-[#00497d] text-white rounded-xl text-xs font-semibold transition-colors shadow-xs"
              >
                Simpan Profil & Kasir
              </button>
            </div>
          </form>
        </section>

        {/* 2. Printer & Struk */}
        <section className="bg-white dark:bg-[#12253c] rounded-2xl border border-[#c3c6d4]/40 dark:border-slate-700/60 p-6 shadow-xs">
          <h2 className="text-lg font-bold text-[#003178] dark:text-sky-300 mb-4 flex items-center gap-2">
            <span className="material-symbols-outlined text-xl">print</span>
            <span>Printer & Struk</span>
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-[#434652] dark:text-slate-300 mb-1 font-mono-code">
                  Printer Aktif
                </label>
                <select
                  value={activePrinter}
                  onChange={(e) => {
                    setActivePrinter(e.target.value);
                    onSavePrinter({ activePrinter: e.target.value, autoPrintReceipt, footerMessage });
                  }}
                  className="w-full h-11 px-3.5 rounded-xl border border-[#c3c3d4] dark:border-slate-700 bg-[#f5faff] dark:bg-slate-800 text-sm dark:text-slate-100 outline-none"
                >
                  <option value="Epson TM-T82X (USB)">Epson TM-T82X (USB)</option>
                  <option value="Bluetooth Printer 58mm">Bluetooth Printer 58mm</option>
                  <option value="Tidak ada printer">Tidak ada printer</option>
                </select>
              </div>

              <div className="flex items-center justify-between p-3.5 rounded-xl border border-[#c3c6d4]/50 dark:border-slate-700/60 bg-[#f5faff] dark:bg-slate-800">
                <span className="text-sm font-medium text-[#0f1d25] dark:text-slate-100">Cetak struk otomatis</span>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={autoPrintReceipt}
                    onChange={(e) => {
                      setAutoPrintReceipt(e.target.checked);
                      onSavePrinter({ activePrinter, autoPrintReceipt: e.target.checked, footerMessage });
                    }}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-[#c3c6d4] peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#0061a4]" />
                </label>
              </div>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-[#434652] dark:text-slate-300 mb-1 font-mono-code">
                  Pesan Footer Struk
                </label>
                <textarea
                  rows={3}
                  value={footerMessage}
                  onChange={(e) => {
                    setFooterMessage(e.target.value);
                    onSavePrinter({ activePrinter, autoPrintReceipt, footerMessage: e.target.value });
                  }}
                  className="w-full p-3 rounded-xl border border-[#c3c6d4] dark:border-slate-700 bg-[#f5faff] dark:bg-slate-800 text-sm dark:text-slate-100 outline-none resize-none"
                />
              </div>

              <button
                type="button"
                onClick={handleTestPrint}
                className="h-11 px-6 border border-[#0061a4] text-[#0061a4] dark:text-sky-400 hover:bg-[#e9f5ff] dark:hover:bg-slate-800 rounded-xl text-xs font-semibold transition-colors w-full flex justify-center items-center gap-2"
              >
                <span className="material-symbols-outlined text-lg">receipt</span>
                <span>Test Print Struk</span>
              </button>
            </div>
          </div>
        </section>

        {/* 3. Sistem & Developer & 4. Logout */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <section className="bg-white dark:bg-[#12253c] rounded-2xl border border-[#c3c6d4]/40 dark:border-slate-700/60 p-6 shadow-xs space-y-4">
            <h2 className="text-lg font-bold text-[#003178] dark:text-sky-300 flex items-center gap-2">
              <span className="material-symbols-outlined text-xl">
                settings_system_daydream
              </span>
              <span>Sistem & Masukan</span>
            </h2>

            <div className="flex items-center justify-between p-3.5 rounded-xl border border-[#c3c6d4]/50 dark:border-slate-700/60 bg-[#f5faff] dark:bg-slate-800">
              <div className="flex items-center gap-2">
                <span className="material-symbols-outlined text-[#737783] dark:text-slate-400 text-lg">language</span>
                <span className="text-sm text-[#0f1d25] dark:text-slate-100">Bahasa</span>
              </div>
              <select
                value={language}
                onChange={(e) => {
                  const lang = e.target.value as 'Indonesia' | 'English';
                  setLanguage(lang);
                  onSaveSystem({ language: lang, darkMode });
                }}
                className="px-3 py-1.5 rounded-lg border border-[#c3c6d4] dark:border-slate-700 bg-white dark:bg-slate-700 text-xs font-semibold outline-none text-[#0f1d25] dark:text-slate-100"
              >
                <option value="Indonesia">Indonesia</option>
                <option value="English">English</option>
              </select>
            </div>

            <div className="flex items-center justify-between p-3.5 rounded-xl border border-[#c3c6d4]/50 dark:border-slate-700/60 bg-[#f5faff] dark:bg-slate-800">
              <div className="flex items-center gap-2">
                <span className="material-symbols-outlined text-[#737783] dark:text-slate-400 text-lg">dark_mode</span>
                <span className="text-sm text-[#0f1d25] dark:text-slate-100">Tema Gelap</span>
              </div>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={darkMode}
                  onChange={(e) => {
                    const newMode = e.target.checked;
                    setDarkMode(newMode);
                    onSaveSystem({ language, darkMode: newMode });
                  }}
                  className="sr-only peer"
                />
                <div className="w-11 h-6 bg-[#c3c6d4] peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#0061a4]" />
              </label>
            </div>

            <button
              type="button"
              onClick={handleContactDev}
              className="w-full h-11 bg-[#25D366] hover:bg-[#20bd5a] text-white rounded-xl text-xs font-bold transition-colors flex justify-center items-center gap-2"
            >
              <span className="material-symbols-outlined text-lg">chat</span>
              <span>Hubungi Developer (WhatsApp)</span>
            </button>

            <button
              type="button"
              onClick={handleBackupData}
              className="w-full h-11 border border-[#737783] dark:border-slate-600 text-[#0f1d25] dark:text-slate-200 rounded-xl text-xs font-semibold hover:bg-[#e9f5ff] dark:hover:bg-slate-800 transition-colors flex justify-center items-center gap-2"
            >
              <span className="material-symbols-outlined text-lg">backup</span>
              <span>Cadangkan Data JSON</span>
            </button>
          </section>

          <section className="bg-white dark:bg-[#12253c] rounded-2xl border border-[#c3c6d4]/40 dark:border-slate-700/60 p-6 shadow-xs flex flex-col justify-center items-center text-center">
            <div className="w-14 h-14 rounded-full bg-[#ffdad6] text-[#93000a] flex items-center justify-center mb-3">
              <span className="material-symbols-outlined text-3xl">logout</span>
            </div>
            <h3 className="font-bold text-base text-[#0f1d25] dark:text-slate-100 mb-1">Keluar dari Sesi</h3>
            <p className="text-xs text-[#434652] dark:text-slate-400 mb-5 max-w-xs leading-relaxed">
              Pastikan semua transaksi telah selesai sebelum keluar dari aplikasi.
            </p>
            <button
              onClick={onLogout}
              className="h-11 px-8 bg-[#ba1a1a] hover:bg-red-800 text-white rounded-xl text-xs font-semibold transition-all shadow-xs w-full"
            >
              Keluar
            </button>
          </section>
        </div>
      </main>
    </div>
  );
};
