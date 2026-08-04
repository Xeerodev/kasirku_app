import React, { useState } from 'react';

interface LoginViewProps {
  onLoginSuccess: () => void;
  onSwitchToSetup: () => void;
}

export const LoginView: React.FC<LoginViewProps> = ({
  onLoginSuccess,
  onSwitchToSetup
}) => {
  const [username, setUsername] = useState('kasirku_admin');
  const [password, setPassword] = useState('123456');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onLoginSuccess();
  };

  return (
    <div className="bg-[#eff4ff] min-h-screen flex items-center justify-center p-4 font-sans text-[#0b1c30]">
      <main className="w-full max-w-md bg-white rounded-2xl shadow-xl border border-[#c6c6cd]/50 overflow-hidden flex flex-col">
        {/* Header / Logo Area */}
        <div className="flex flex-col items-center pt-8 pb-4 px-6">
          <div className="w-56 h-auto mb-4 p-2 bg-blue-50/50 rounded-xl border border-[#2196f3]/20 flex items-center justify-center">
            <img
              src="https://lh3.googleusercontent.com/aida-public/AB6AXuDHsGLOsUm9DlHUA9xeRpCapc2k1euPnzJcmzpRt_wjWQPVJ88L-F49scQ4D_RlATOmxa6YMFv0pCAsI4x-dd6QdWtAB905MfQ3qhy3SOvLTO3cs4m0qbR2VW1p_HjznuBoJlpBAzfz-sdyrHgJPXGqln6c8EYAzHv3zIYHz9ttb0WPoyhCysDwpOqTnI-xPbgNTL0sIJRDK-l4OsaXraEo8hWnDzmq1zLD29zlhgkabE8Nt99H39twcjRBwCh9wxz6tg"
              alt="Kasirku Logo"
              className="w-full h-auto object-contain rounded-lg"
            />
          </div>
          <h1 className="text-2xl font-bold text-[#0b1c30] text-center">
            Masuk ke Kasirku
          </h1>
          <p className="text-sm text-[#45464d] text-center mt-1.5">
            Kelola toko Anda dengan mudah dan cepat.
          </p>
        </div>

        {/* Login Form */}
        <form onSubmit={handleSubmit} className="flex flex-col px-6 pb-8 gap-4">
          <div className="flex flex-col gap-1.5">
            <label htmlFor="username" className="text-xs font-semibold font-mono-code text-[#0b1c30]">
              Username
            </label>
            <div className="relative">
              <span className="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-[#76777d] text-xl">
                person
              </span>
              <input
                id="username"
                type="text"
                required
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                placeholder="Masukkan username Anda"
                className="w-full h-12 pl-11 pr-4 bg-[#f8f9ff] rounded-xl border border-[#c6c6cd] focus:border-[#0d47a1] focus:ring-1 focus:ring-[#0d47a1] outline-none transition-colors text-sm text-[#0b1c30] placeholder:text-[#c6c6cd]"
              />
            </div>
          </div>

          <div className="flex flex-col gap-1.5">
            <label htmlFor="password" className="text-xs font-semibold font-mono-code text-[#0b1c30]">
              Password
            </label>
            <div className="relative">
              <span className="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-[#76777d] text-xl">
                lock
              </span>
              <input
                id="password"
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Masukkan password Anda"
                className="w-full h-12 pl-11 pr-4 bg-[#f8f9ff] rounded-xl border border-[#c6c6cd] focus:border-[#0d47a1] focus:ring-1 focus:ring-[#0d47a1] outline-none transition-colors text-sm text-[#0b1c30] placeholder:text-[#c6c6cd]"
              />
            </div>
          </div>

          <button
            type="submit"
            className="mt-3 w-full h-12 bg-[#131b2e] hover:bg-[#0d47a1] text-white rounded-full font-semibold text-sm transition-all duration-200 active:scale-[0.98] shadow-md flex items-center justify-center gap-2"
          >
            <span>Login</span>
            <span className="material-symbols-outlined text-xl material-symbols-filled">
              login
            </span>
          </button>

          <div className="flex flex-col sm:flex-row justify-between items-center mt-3 gap-2">
            <button
              type="button"
              onClick={onSwitchToSetup}
              className="text-xs font-semibold text-[#0d47a1] hover:underline"
            >
              Atur Toko Baru
            </button>
            <button
              type="button"
              onClick={() => alert('Fitur lupa kata sandi: Silakan hubungi administrator toko atau developer.')}
              className="text-xs text-[#45464d] hover:text-[#0d47a1] transition-colors"
            >
              Hubungi Developer
            </button>
          </div>
        </form>
      </main>
    </div>
  );
};
