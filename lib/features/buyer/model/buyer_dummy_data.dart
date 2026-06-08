class NearbySeller {
  final String id;
  final String name;
  final String distance;
  final double rating;
  final bool isSelling;
  final String imagePath;

  NearbySeller({
    required this.id,
    required this.name,
    required this.distance,
    required this.rating,
    required this.isSelling,
    required this.imagePath,
  });
}

class RecommendedProduct {
  final String id;
  final String sellerId;
  final String name;
  final int price;
  final String imagePath;

  RecommendedProduct({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.price,
    required this.imagePath,
  });
}

// Dummy Data
final List<NearbySeller> dummyNearbySellers = [
  NearbySeller(
    id: 's1',
    name: 'Siomay Pak Budi',
    distance: '200m dari kamu',
    rating: 4.8,
    isSelling: true,
    imagePath: 'assets/images/siomay.png',
  ),
  NearbySeller(
    id: 's2',
    name: 'Sate Padang Ajo',
    distance: '450m dari kamu',
    rating: 4.5,
    isSelling: true,
    imagePath: 'assets/images/sate.png',
  ),
];

final List<RecommendedProduct> dummyRecommendedProducts = [
  RecommendedProduct(
    id: 'p1',
    sellerId: 's3',
    name: 'Es Cendol Durian',
    price: 15000,
    imagePath: 'assets/images/cendol.png',
  ),
  RecommendedProduct(
    id: 'p2',
    sellerId: 's1',
    name: 'Batagor Spesial',
    price: 18000,
    imagePath: 'assets/images/batagor.png',
  ),
  RecommendedProduct(
    id: 'p3',
    sellerId: 's4',
    name: 'Bakso Urat Mantap',
    price: 20000,
    imagePath: 'assets/images/bakso.png',
  ),
  RecommendedProduct(
    id: 'p4',
    sellerId: 's5',
    name: 'Kue Klepon Lumer',
    price: 10000,
    imagePath: 'assets/images/klepon.png',
  ),
];
