import React from 'react';
import { ActiveView, StoreProfile } from '../types';
import { KASIRKU_LOGO } from '../data/initialData';

interface NavigationProps {
  activeView: ActiveView;
  onSelectView: (view: ActiveView) => void;
  cartItemCount?: number;
  storeProfile?: StoreProfile;
  isDarkMode?: boolean;
  onToggleDarkMode?: () => void;
}

export const Navigation: React.FC<NavigationProps> = ({
  activeView,
  onSelectView,
  cartItemCount = 0,
  storeProfile,
  isDarkMode = false,
  onToggleDarkMode
}) => {
  const navItems = [
    { id: 'pos' as ActiveView, label: 'Kasir', icon: 'point_of_sale' },
    { id: 'stok' as ActiveView, label: 'Stok', icon: 'inventory_2' },
    { id: 'riwayat' as ActiveView, label: 'Riwayat', icon: 'history' },
    { id: 'laporan' as ActiveView, label: 'Laporan', icon: 'analytics' },
    { id: 'pengaturan' as ActiveView, label: 'Pengaturan', icon: 'settings' }
  ];

  const handleContactDev = () => {
    window.open(
      'https://wa.me/6283164004093?text=' + encodeURIComponent('mau kasih masukan'),
      '_blank'
    );
  };

  const storeName = storeProfile?.name || 'Toko Kopi Senja';

  return (
    <>
      {/* Mobile Bottom Navigation Bar (Hidden in Landscape & Desktop) */}
      <nav className="fixed bottom-0 left-0 right-0 z-40 bg-white dark:bg-[#12253c] border-t border-[#c6c6cd]/30 dark:border-slate-700/60 shadow-[0_-2px_10px_rgba(0,0,0,0.05)] md:hidden landscape:hidden">
        <div className="flex justify-around items-center h-13 px-1 w-full max-w-md mx-auto">
          {navItems.map((item) => {
            const isActive = activeView === item.id;
            return (
              <button
                key={item.id}
                onClick={() => onSelectView(item.id)}
                className={`flex flex-col items-center justify-center relative transition-all duration-150 active:scale-95 ${
                  isActive ? 'w-[64px]' : 'w-[54px] text-[#45464d] dark:text-slate-300 hover:text-[#0d47a1]'
                }`}
              >
                {isActive ? (
                  <div className="flex flex-col items-center justify-center bg-[#0d47a1] text-white rounded-lg px-2 py-0.5 w-full shadow-2xs">
                    <span className="material-symbols-outlined text-lg material-symbols-filled">
                      {item.icon}
                    </span>
                    <span className="text-[9.5px] font-bold leading-none mt-0.5">
                      {item.label}
                    </span>
                  </div>
                ) : (
                  <div className="flex flex-col items-center justify-center py-0.5">
                    <span className="material-symbols-outlined text-lg">
                      {item.icon}
                    </span>
                    <span className="text-[9.5px] font-medium leading-none mt-0.5">
                      {item.label}
                    </span>
                  </div>
                )}
                {item.id === 'pos' && cartItemCount > 0 && !isActive && (
                  <span className="absolute top-0 right-1 w-3.5 h-3.5 bg-[#ba1a1a] text-white text-[9px] font-bold rounded-full flex items-center justify-center">
                    {cartItemCount}
                  </span>
                )}
              </button>
            );
          })}
        </div>
      </nav>

      {/* Desktop & Landscape Sidebar Navigation */}
      <aside className="hidden md:flex landscape:flex fixed left-0 top-0 bottom-0 w-52 bg-white dark:bg-[#12253c] border-r border-[#c6c6cd]/40 dark:border-slate-700/60 flex-col z-30 shadow-sm text-[#0b1c30] dark:text-slate-100">
        <div className="h-14 flex items-center px-4 border-b border-[#c6c6cd]/30 dark:border-slate-700/60 gap-2.5">
          <div className="w-8 h-8 rounded-lg bg-white p-0.5 flex items-center justify-center shadow-xs border border-[#c6c6cd]/40 overflow-hidden flex-shrink-0">
            <img src={KASIRKU_LOGO} alt="Kasirku Logo" className="w-full h-full object-contain" />
          </div>
          <div className="min-w-0 flex-1">
            <h1 className="font-bold text-xs text-[#0d47a1] dark:text-[#64b5f6] tracking-tight leading-tight truncate">
              {storeName}
            </h1>
            <p className="text-[9px] text-[#76777d] dark:text-slate-400 font-mono-code font-semibold">
              Kasirku POS
            </p>
          </div>
        </div>

        <nav className="flex-1 py-3 px-2 space-y-1 overflow-y-auto">
          {navItems.map((item) => {
            const isActive = activeView === item.id;
            return (
              <button
                key={item.id}
                onClick={() => onSelectView(item.id)}
                className={`w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-medium transition-all duration-200 ${
                  isActive
                    ? 'bg-[#0d47a1] text-white shadow-xs font-semibold'
                    : 'text-[#45464d] dark:text-slate-300 hover:bg-[#e3f2fd] dark:hover:bg-slate-800 hover:text-[#0d47a1]'
                }`}
              >
                <span
                  className={`material-symbols-outlined text-lg ${
                    isActive ? 'material-symbols-filled' : ''
                  }`}
                >
                  {item.icon}
                </span>
                <span className="flex-1 text-left">{item.label}</span>
                {item.id === 'pos' && cartItemCount > 0 && (
                  <span
                    className={`px-1.5 py-0.2 text-[10px] font-bold rounded-full ${
                      isActive ? 'bg-white text-[#0d47a1]' : 'bg-[#0d47a1] text-white'
                    }`}
                  >
                    {cartItemCount}
                  </span>
                )}
              </button>
            );
          })}
        </nav>

        {/* Theme Toggle & Active Cashier Info */}
        <div className="p-2.5 border-t border-[#c6c6cd]/30 dark:border-slate-700/60 bg-[#f8f9ff] dark:bg-[#0b1c30] space-y-1.5">
          {onToggleDarkMode && (
            <button
              onClick={onToggleDarkMode}
              className="w-full py-1.5 px-2.5 bg-[#e3f2fd] dark:bg-slate-800 hover:bg-[#d0e8ff] dark:hover:bg-slate-700 text-[#0d47a1] dark:text-sky-300 rounded-lg text-[11px] font-bold flex items-center justify-between shadow-2xs transition-all active:scale-95 border border-[#2196f3]/20 dark:border-slate-700"
            >
              <div className="flex items-center gap-1.5">
                <span className="material-symbols-outlined text-sm">
                  {isDarkMode ? 'dark_mode' : 'light_mode'}
                </span>
                <span>{isDarkMode ? 'Gelap' : 'Terang'}</span>
              </div>
              <span className="text-[9px] font-mono-code px-1.5 py-0.2 rounded bg-white dark:bg-slate-900 text-[#0d47a1] dark:text-sky-300 font-semibold border border-[#2196f3]/20 dark:border-slate-700">
                {isDarkMode ? 'DARK' : 'LIGHT'}
              </span>
            </button>
          )}

          <div className="bg-[#e3f2fd] dark:bg-slate-800/80 p-2 rounded-lg border border-[#2196f3]/20 flex items-center gap-2">
            <div className="w-6 h-6 rounded-full bg-[#0d47a1] text-white flex items-center justify-center font-bold text-[10px] flex-shrink-0">
              {storeProfile?.cashierName?.[0] || 'K'}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-[10px] font-bold text-[#0b1c30] dark:text-slate-100 truncate">
                {storeProfile?.cashierName || 'Kasir 1'}
              </p>
              <p className="text-[8.5px] text-[#45464d] dark:text-slate-400 truncate">Kasir Aktif</p>
            </div>
          </div>
        </div>
      </aside>
    </>
  );
};
