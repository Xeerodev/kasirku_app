export type ActiveView = 'setup' | 'login' | 'pos' | 'stok' | 'riwayat' | 'laporan' | 'pengaturan';

export interface Product {
  id: string;
  name: string;
  category: string;
  price: number;
  stock: number;
  image: string;
  description?: string;
}

export interface CartItem {
  product: Product;
  quantity: number;
}

export interface TransactionItem {
  productId: string;
  name: string;
  price: number;
  quantity: number;
}

export interface Transaction {
  id: string;
  invoiceNumber: string;
  timestamp: string;
  timeString: string;
  items: TransactionItem[];
  itemCount: number;
  subtotal: number;
  tax: number;
  discount: number;
  total: number;
  status: 'Lunas' | 'Refund' | 'Pending';
  paymentMethod: 'Tunai' | 'QRIS' | 'Kartu Debit';
  cashierName?: string;
}

export interface StoreProfile {
  name: string;
  cashierName: string;
  address: string;
  phone: string;
  logoUrl: string;
  isConfigured: boolean;
}

export interface PrinterSettings {
  activePrinter: string;
  autoPrintReceipt: boolean;
  footerMessage: string;
}

export interface SystemSettings {
  language: 'Indonesia' | 'English';
  darkMode: boolean;
}
