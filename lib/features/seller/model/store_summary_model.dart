class StoreSummaryModel {
  final bool isStoreOpen;
  final int totalMenu;
  final int todayVisitors;
  final List<String> bestSellingMenu;
  final List<String> lowStockMenu;

  StoreSummaryModel({
    required this.isStoreOpen,
    required this.totalMenu,
    required this.todayVisitors,
    required this.bestSellingMenu,
    required this.lowStockMenu,
  });

  bool get isOpen => isStoreOpen;
  int get todayVisitor => todayVisitors;
}

// Dummy data yang bisa diakses dari berbagai halaman
final StoreSummaryModel dummyStoreSummary = StoreSummaryModel(
  isStoreOpen: true,
  totalMenu: 24,
  todayVisitors: 156,
  bestSellingMenu: ['Nasi Goreng Spesial', 'Es Teh Manis', 'Ayam Bakar'],
  lowStockMenu: ['Kerupuk Udang', 'Sambal Bawang'],
);
