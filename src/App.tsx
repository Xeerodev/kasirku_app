import { useState, useEffect } from 'react';
import {
  ActiveView,
  Product,
  CartItem,
  Transaction,
  StoreProfile,
  PrinterSettings,
  SystemSettings
} from './types';
import {
  INITIAL_PRODUCTS,
  INITIAL_STORE_PROFILE,
  INITIAL_PRINTER_SETTINGS,
  INITIAL_SYSTEM_SETTINGS,
  INITIAL_TRANSACTIONS
} from './data/initialData';

import { Navigation } from './components/Navigation';
import { SetupStoreView } from './views/SetupStoreView';
import { LoginView } from './views/LoginView';
import { PosView } from './views/PosView';
import { CartDrawer } from './views/CartDrawer';
import { PaymentModal } from './components/PaymentModal';
import { StockView } from './views/StockView';
import { ProductFormModal } from './components/ProductFormModal';
import { ReportsView } from './views/ReportsView';
import { HistoryView } from './views/HistoryView';
import { SettingsView } from './views/SettingsView';

export default function App() {
  // Navigation State
  const [activeView, setActiveView] = useState<ActiveView>('pos');

  // Persistence States
  const [storeProfile, setStoreProfile] = useState<StoreProfile>(() => {
    const saved = localStorage.getItem('kasirku_store_profile');
    return saved ? JSON.parse(saved) : INITIAL_STORE_PROFILE;
  });

  const [printerSettings, setPrinterSettings] = useState<PrinterSettings>(() => {
    const saved = localStorage.getItem('kasirku_printer_settings');
    return saved ? JSON.parse(saved) : INITIAL_PRINTER_SETTINGS;
  });

  const [systemSettings, setSystemSettings] = useState<SystemSettings>(() => {
    const saved = localStorage.getItem('kasirku_system_settings');
    return saved ? JSON.parse(saved) : INITIAL_SYSTEM_SETTINGS;
  });

  const [products, setProducts] = useState<Product[]>(() => {
    const saved = localStorage.getItem('kasirku_products');
    return saved ? JSON.parse(saved) : INITIAL_PRODUCTS;
  });

  const [transactions, setTransactions] = useState<Transaction[]>(() => {
    const saved = localStorage.getItem('kasirku_transactions');
    return saved ? JSON.parse(saved) : INITIAL_TRANSACTIONS;
  });

  // Cart & Modals State
  const [cart, setCart] = useState<CartItem[]>([]);
  const [isCartOpen, setIsCartOpen] = useState(false);
  const [isPaymentModalOpen, setIsPaymentModalOpen] = useState(false);
  const [paymentSummary, setPaymentSummary] = useState({ subtotal: 0, tax: 0, total: 0 });

  // Product Edit Modal State
  const [isProductModalOpen, setIsProductModalOpen] = useState(false);
  const [productToEdit, setProductToEdit] = useState<Product | null>(null);

  // Sync state to localStorage
  useEffect(() => {
    localStorage.setItem('kasirku_store_profile', JSON.stringify(storeProfile));
  }, [storeProfile]);

  useEffect(() => {
    localStorage.setItem('kasirku_printer_settings', JSON.stringify(printerSettings));
  }, [printerSettings]);

  useEffect(() => {
    localStorage.setItem('kasirku_system_settings', JSON.stringify(systemSettings));
    if (systemSettings.darkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [systemSettings]);

  useEffect(() => {
    localStorage.setItem('kasirku_products', JSON.stringify(products));
  }, [products]);

  useEffect(() => {
    localStorage.setItem('kasirku_transactions', JSON.stringify(transactions));
  }, [transactions]);

  // Handle Cart Operations
  const handleAddToCart = (product: Product) => {
    if (product.stock <= 0) return;

    setCart((prevCart) => {
      const existingIndex = prevCart.findIndex((item) => item.product.id === product.id);

      if (existingIndex > -1) {
        const currentQty = prevCart[existingIndex].quantity;
        if (currentQty >= product.stock) {
          alert(`Stok ${product.name} hanya tersisa ${product.stock}!`);
          return prevCart;
        }

        const updated = [...prevCart];
        updated[existingIndex] = {
          ...updated[existingIndex],
          quantity: currentQty + 1
        };
        return updated;
      } else {
        return [...prevCart, { product, quantity: 1 }];
      }
    });
  };

  const handleRemoveFromCart = (product: Product) => {
    setCart((prevCart) => {
      const existingIndex = prevCart.findIndex((item) => item.product.id === product.id);
      if (existingIndex === -1) return prevCart;

      const currentQty = prevCart[existingIndex].quantity;
      if (currentQty <= 1) {
        return prevCart.filter((item) => item.product.id !== product.id);
      } else {
        const updated = [...prevCart];
        updated[existingIndex] = {
          ...updated[existingIndex],
          quantity: currentQty - 1
        };
        return updated;
      }
    });
  };

  const handleUpdateQuantity = (productId: string, newQty: number) => {
    if (newQty <= 0) {
      handleRemoveItem(productId);
      return;
    }

    setCart((prevCart) => {
      return prevCart.map((item) => {
        if (item.product.id === productId) {
          if (newQty > item.product.stock) {
            alert(`Stok maksimum tercapai (${item.product.stock})`);
            return item;
          }
          return { ...item, quantity: newQty };
        }
        return item;
      });
    });
  };

  const handleRemoveItem = (productId: string) => {
    setCart((prevCart) => prevCart.filter((item) => item.product.id !== productId));
  };

  const handleClearCart = () => {
    setCart([]);
  };

  // Payment flow
  const handleProceedToPayment = (subtotal: number, tax: number, total: number) => {
    setPaymentSummary({ subtotal, tax, total });
    setIsCartOpen(false);
    setIsPaymentModalOpen(true);
  };

  const handlePaymentSuccess = (newTransaction: Transaction) => {
    // Deduct stock
    setProducts((prevProducts) =>
      prevProducts.map((p) => {
        const cartItem = cart.find((item) => item.product.id === p.id);
        if (cartItem) {
          const newStock = Math.max(0, p.stock - cartItem.quantity);
          return { ...p, stock: newStock };
        }
        return p;
      })
    );

    // Save transaction
    setTransactions((prevTx) => [newTransaction, ...prevTx]);

    // Clear cart
    setCart([]);
  };

  // Product Add/Edit Operations
  const handleSaveProduct = (productData: Partial<Product>) => {
    if (productData.id) {
      // Edit existing
      setProducts((prev) =>
        prev.map((p) => (p.id === productData.id ? ({ ...p, ...productData } as Product) : p))
      );
    } else {
      // Add new
      const newProd: Product = {
        id: 'p-' + Date.now(),
        name: productData.name || 'Produk Baru',
        category: productData.category || 'Kopi',
        price: productData.price || 0,
        stock: productData.stock || 0,
        image: productData.image || '',
        description: productData.description || ''
      };
      setProducts((prev) => [newProd, ...prev]);
    }
  };

  const handleDeleteProduct = (productId: string) => {
    setProducts((prev) => prev.filter((p) => p.id !== productId));
  };

  // Refund toggle
  const handleToggleRefund = (transactionId: string) => {
    setTransactions((prev) =>
      prev.map((tx) => (tx.id === transactionId ? { ...tx, status: 'Refund' } : tx))
    );
  };

  const cartItemCount = cart.reduce((sum, item) => sum + item.quantity, 0);

  // Render setup/login views without bottom bar
  if (activeView === 'setup') {
    return (
      <SetupStoreView
        storeProfile={storeProfile}
        onSaveProfile={(updatedProfile) => {
          setStoreProfile(updatedProfile);
          setActiveView('pos');
        }}
        onSwitchToLogin={() => setActiveView('login')}
      />
    );
  }

  if (activeView === 'login') {
    return (
      <LoginView
        onLoginSuccess={() => setActiveView('pos')}
        onSwitchToSetup={() => setActiveView('setup')}
      />
    );
  }

  const handleToggleDarkMode = () => {
    setSystemSettings((prev) => ({
      ...prev,
      darkMode: !prev.darkMode
    }));
  };

  const existingCategories = Array.from(
    new Set([
      'Kopi',
      'Kue',
      'Merchandise',
      'Biji Kopi',
      'Teh',
      'Minuman',
      ...products.map((p) => p.category).filter(Boolean)
    ])
  );

  return (
    <div className={`min-h-screen ${systemSettings.darkMode ? 'dark bg-[#0b1c30]' : 'bg-[#f8f9ff]'}`}>
      {/* Navigation Shell */}
      <Navigation
        activeView={activeView}
        onSelectView={(view) => setActiveView(view)}
        cartItemCount={cartItemCount}
        storeProfile={storeProfile}
        isDarkMode={systemSettings.darkMode}
        onToggleDarkMode={handleToggleDarkMode}
      />

      {/* Main View Switcher */}
      {activeView === 'pos' && (
        <PosView
          products={products}
          cart={cart}
          storeProfile={storeProfile}
          onAddToCart={handleAddToCart}
          onRemoveFromCart={handleRemoveFromCart}
          onOpenCart={() => setIsCartOpen(true)}
        />
      )}

      {activeView === 'stok' && (
        <StockView
          products={products}
          onOpenAddModal={() => {
            setProductToEdit(null);
            setIsProductModalOpen(true);
          }}
          onOpenEditModal={(product) => {
            setProductToEdit(product);
            setIsProductModalOpen(true);
          }}
          onDeleteProduct={handleDeleteProduct}
        />
      )}

      {activeView === 'laporan' && (
        <ReportsView
          transactions={transactions}
          storeProfile={storeProfile}
          onViewAllTransactions={() => setActiveView('riwayat')}
        />
      )}

      {activeView === 'riwayat' && (
        <HistoryView
          transactions={transactions}
          storeProfile={storeProfile}
          onToggleRefund={handleToggleRefund}
        />
      )}

      {activeView === 'pengaturan' && (
        <SettingsView
          storeProfile={storeProfile}
          printerSettings={printerSettings}
          systemSettings={systemSettings}
          onSaveProfile={(p) => setStoreProfile(p)}
          onSavePrinter={(pr) => setPrinterSettings(pr)}
          onSaveSystem={(sys) => setSystemSettings(sys)}
          onLogout={() => setActiveView('login')}
        />
      )}

      {/* Cart Drawer */}
      <CartDrawer
        isOpen={isCartOpen}
        cart={cart}
        onClose={() => setIsCartOpen(false)}
        onUpdateQuantity={handleUpdateQuantity}
        onRemoveItem={handleRemoveItem}
        onClearCart={handleClearCart}
        onProceedToPayment={handleProceedToPayment}
      />

      {/* Payment Modal */}
      <PaymentModal
        isOpen={isPaymentModalOpen}
        cart={cart}
        subtotal={paymentSummary.subtotal}
        tax={paymentSummary.tax}
        total={paymentSummary.total}
        storeProfile={storeProfile}
        printerSettings={printerSettings}
        onClose={() => setIsPaymentModalOpen(false)}
        onPaymentSuccess={handlePaymentSuccess}
      />

      {/* Product Form Modal (Add / Edit) */}
      <ProductFormModal
        isOpen={isProductModalOpen}
        productToEdit={productToEdit}
        existingCategories={existingCategories}
        onClose={() => setIsProductModalOpen(false)}
        onSaveProduct={handleSaveProduct}
      />
    </div>
  );
}
