import { Product, StoreProfile, PrinterSettings, SystemSettings, Transaction } from '../types';

export const INITIAL_PRODUCTS: Product[] = [
  {
    id: 'p1',
    name: 'Latte',
    category: 'Kopi',
    price: 4500,
    stock: 15,
    image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCD5wP3t-xFQxn5XoghNFgauxPU230h6J8bOnRmzYdAKM24saHAtAGNrrCc0E7w6Ximb9DZbx-GQrGDpRcxGYr7ayA7kJuLv3-47yIlRPFCgDf7BqIyUGqaFMERCvlI0W2GyZ3agi820v5oVazBc4_NUoQ5tVSAVkHWJC1wB2WC6tR33FvTbI2ARX8nSEkhwRwxN79kz5z170wuA2VnTS_ASgiYHBXf_UWbPQnCogaLyvT8EH3gQ3jt',
    description: 'Espresso creamy dengan susu segar berkualitas tinggi dan seni latte foam'
  },
  {
    id: 'p2',
    name: 'Butter Croissant',
    category: 'Kue',
    price: 3750,
    stock: 8,
    image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD0bvZcnjyjtHWAyCvb4Z0F_WLrDn5qp0DD-CJa4qY1h0Q0mGsnbnZtNHc5CYD3fsoP8xDbATpRupmhQ5K-j1auHAB9U-91lkczXRrGKuKwWtcDUBwtoR7pZeng_LTEXowm2_ehsRW2dOi6gUK4S3rfjzwkp_zI7cx9IdKeNr71XwKnQxjo45GQ1d7rq9zqCDzXVEFzP3COqyzGgPxsxn_RdR5lGJdyC2K0X9s_0msUPsCpbiT6-C2h',
    description: 'Roti croissant mentega Prancis renyah di luar, lembut berlapis di dalam'
  },
  {
    id: 'p3',
    name: 'Iced Americano',
    category: 'Kopi',
    price: 3500,
    stock: 20,
    image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBMuOWbl70BCHzw1FsgQQJoZ_U6XcE5bEwZ0WL6G1cmXWe3f_JV5GKHi6kuoFPVv3pFEmUMdxXg2TmXreAEY7-nEE0_8YtSSLGgq0sdDFHca2i-mMVJtyBvVxq-BH5LXCR-keAkPC9iZKRbYH77MZuOR5PHuNgEM3kXZoI4nH7PGhBQf4yAKEvs6lj50cMA-oI2yi9_70ralkKxQgm6l4n3dGknvSCxIAFmbc8DOdGJEG1LujIQwRPC',
    description: 'Double shot espresso dingin segar disajikan dengan es batu'
  },
  {
    id: 'p4',
    name: 'Chocolate Chip Cookie',
    category: 'Kue',
    price: 2500,
    stock: 0,
    image: '',
    description: 'Kue kering cokelat lezat beraroma mentega'
  },
  {
    id: 'p5',
    name: 'Campuran Espresso Artisan',
    category: 'Biji Kopi',
    price: 280000,
    stock: 45,
    image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBbr6zfbw-PQCu1WBIJFDrU0UNf-qWDHETwwl7IEDXt5scP_mGdtWzblQOLB4Xn57lTy5Daf2MrSiKWPXLpT_rtTsHdrVQgQNwj3pd4euQgqWBcespQVG_Bqf7HYEjpbxVeaO_6FtySpr7Lr2OFoZnzdSKRjDSAQ6K6NDjuh99xQxafNZi_zZn6cDB8CDGqcqXYO2mZFANl-iq4YPoLoGxn8vCSwl_PKAad5VlDbxcVF1IhX_7BWs9P',
    description: 'Biji kopi pilihan roasted segar dengan nota rasa cokelat dan kacang'
  },
  {
    id: 'p6',
    name: 'Mug Keramik Pour-over',
    category: 'Merchandise',
    price: 180000,
    stock: 2,
    image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBXa_18wnBm7xuaS1fS_jxljlcAODJG3JVz6kjiQskUKIY9p2hdLPQZ9jZYkFCUBpUklZUKtxMlP9PYPWm1NFKx488ohVh-uMbmOXqjA3GTHKC9N4RAolhBMzyGs4zT11liKF7xlu_AJcY--095s8lQZmsNO3HIwz0zNVYpo1Vv_bkmEM2zNyNV6qSnfs-4cgtTexlEHynZiAr6epyn3FbCWS05fqOK3MeLV8oSo6b76NY5Go7oyzzQ',
    description: 'Mug keramik buatan tangan estetis untuk penyeduhan manual'
  },
  {
    id: 'p7',
    name: 'Pitcher Susu Pro 12oz',
    category: 'Merchandise',
    price: 360000,
    stock: 18,
    image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDrMf0UDMcwBL43nauH2_9B41DiUO88J926RW2ORUTHRtwaJ0kQd0X1qR9D2C2cy2FdFOvzpmaJTBf9tj9_eM3RZIt64raS1m5QzvFnkuyXZ8vdTGlfoIbRIxcQ39LPVGUdRTUPJFt1cOiv7oci-B8-Ri-2krnIeVkF-YWsRDg3nqHbluuwk4jXkre0OG46V7pr12q81diU-puaoA6j7BdvJEjQDe2fwTs5RwqpTKfWtblv1pqiulrl',
    description: 'Pitcher frothing susu berbahan stainless steel standar profesional'
  },
  {
    id: 'p8',
    name: 'Teh Hijau Sencha Organik',
    category: 'Minuman',
    price: 220000,
    stock: 0,
    image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAraymmJqyrsOYhVuQZbWvBIcTAacFvfbtGyxXeZkKCAtgt8lWdJ1tITP5243JxJPlJBVYZWKd7RwkV-zmHn9-yum83DF1d6GBWdeZ2uCLEDKI_fq4HwVbH9VDUUjleac-XU8OHYqjTyWjEnYPlo1RBPVxFqA0MNkrtG_ZlCR6VJrZi5YxWarktw5VBAZqS-hVPRDlSEjCJM3SSWYERp7HmTo76Un1B-0Pd2oDjk3ABrl8w9f2A2JJR',
    description: 'Daun teh hijau Sencha impor Jepang kualitas terbaik'
  },
  {
    id: 'p9',
    name: 'Kopi Arabika Gayo',
    category: 'Biji Kopi',
    price: 85000,
    stock: 25,
    image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC8SKvuGbmB7F9xtyyUfJl3vQZUUIcV-LixnQBZcKiXa3feFg6e3A5HGuRiUieSLiSP_iEkn9StmtMDJhy9MqbaExD9tFr7D_4lUSk5fl3M775ZHHYI9AwsCAERM930Xbnib2XKjyHPIFZtIFj6TUugLmoqhBfujjoeB5GDP1KF0wwY6WuKTkISHa44UYVlIzKqVPWmi9VxK2jnGml9OPhZZ0lZ66e5G6ahNeY_3daomZg7WJKKhSuT',
    description: 'Biji kopi Arabika spesialitas Aceh Gayo kemasan 250 gram'
  },
  {
    id: 'p10',
    name: 'Es Kopi Susu Aren',
    category: 'Kopi',
    price: 22000,
    stock: 30,
    image: '',
    description: 'Kopi racikan khas dengan gula aren murni dan susu gurih'
  }
];

export const KASIRKU_LOGO = 'https://lh3.googleusercontent.com/aida-public/AB6AXuDHsGLOsUm9DlHUA9xeRpCapc2k1euPnzJcmzpRt_wjWQPVJ88L-F49scQ4D_RlATOmxa6YMFv0pCAsI4x-dd6QdWtAB905MfQ3qhy3SOvLTO3cs4m0qbR2VW1p_HjznuBoJlpBAzfz-sdyrHgJPXGqln6c8EYAzHv3zIYHz9ttb0WPoyhCysDwpOqTnI-xPbgNTL0sIJRDK-l4OsaXraEo8hWnDzmq1zLD29zlhgkabE8Nt99H39twcjRBwCh9wxz6tg';

export const INITIAL_STORE_PROFILE: StoreProfile = {
  name: 'Toko Kopi Senja',
  cashierName: 'Ahmad (Kasir 1)',
  address: 'Jl. Sudirman No. 123, Jakarta Selatan',
  phone: '0812-3456-7890',
  logoUrl: KASIRKU_LOGO,
  isConfigured: true
};

export const INITIAL_PRINTER_SETTINGS: PrinterSettings = {
  activePrinter: 'Epson TM-T82X (USB)',
  autoPrintReceipt: true,
  footerMessage: 'Terima kasih atas kunjungan Anda!\nBarang yang sudah dibeli tidak dapat ditukar.'
};

export const INITIAL_SYSTEM_SETTINGS: SystemSettings = {
  language: 'Indonesia',
  darkMode: false
};

export const INITIAL_TRANSACTIONS: Transaction[] = [
  {
    id: 'tx-142',
    invoiceNumber: 'INV-20231024-142',
    timestamp: new Date().toISOString(),
    timeString: '14:32',
    items: [
      { productId: 'p1', name: 'Latte', price: 45000, quantity: 1 },
      { productId: 'p3', name: 'Iced Americano', price: 35000, quantity: 1 }
    ],
    itemCount: 2,
    subtotal: 80000,
    tax: 0,
    discount: 0,
    total: 80000,
    status: 'Lunas',
    paymentMethod: 'QRIS',
    cashierName: 'Ahmad (Kasir 1)'
  },
  {
    id: 'tx-141',
    invoiceNumber: 'INV-20231024-141',
    timestamp: new Date(Date.now() - 17 * 60000).toISOString(),
    timeString: '14:15',
    items: [
      { productId: 'p1', name: 'Latte', price: 45000, quantity: 1 }
    ],
    itemCount: 1,
    subtotal: 45000,
    tax: 0,
    discount: 0,
    total: 45000,
    status: 'Lunas',
    paymentMethod: 'Tunai',
    cashierName: 'Ahmad (Kasir 1)'
  },
  {
    id: 'tx-140',
    invoiceNumber: 'INV-20231024-140',
    timestamp: new Date(Date.now() - 34 * 60000).toISOString(),
    timeString: '13:58',
    items: [
      { productId: 'p9', name: 'Kopi Arabika Gayo', price: 85000, quantity: 1 },
      { productId: 'p2', name: 'Butter Croissant', price: 37500, quantity: 1 }
    ],
    itemCount: 2,
    subtotal: 122500,
    tax: 0,
    discount: 0,
    total: 122500,
    status: 'Lunas',
    paymentMethod: 'Kartu Debit',
    cashierName: 'Ahmad (Kasir 1)'
  },
  {
    id: 'tx-139',
    invoiceNumber: 'INV-20231024-139',
    timestamp: new Date(Date.now() - 52 * 60000).toISOString(),
    timeString: '13:40',
    items: [
      { productId: 'p1', name: 'Latte', price: 45000, quantity: 1 },
      { productId: 'p2', name: 'Butter Croissant', price: 37500, quantity: 1 }
    ],
    itemCount: 2,
    subtotal: 82500,
    tax: 0,
    discount: 0,
    total: 82500,
    status: 'Refund',
    paymentMethod: 'Tunai',
    cashierName: 'Ahmad (Kasir 1)'
  },
  {
    id: 'tx-138',
    invoiceNumber: 'INV-20231024-138',
    timestamp: new Date(Date.now() - 70 * 60000).toISOString(),
    timeString: '13:22',
    items: [
      { productId: 'p3', name: 'Iced Americano', price: 35000, quantity: 2 }
    ],
    itemCount: 2,
    subtotal: 70000,
    tax: 0,
    discount: 0,
    total: 70000,
    status: 'Lunas',
    paymentMethod: 'QRIS',
    cashierName: 'Ahmad (Kasir 1)'
  }
];
