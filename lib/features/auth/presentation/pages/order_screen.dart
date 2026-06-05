import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DummyPedagang {
  final String namaToko;
  final String jenisProduk;
  final String namaMakanan;
  final int stokAwal;
  final int sisaStok;
  final bool isBerjualan;

  DummyPedagang({
    required this.namaToko,
    required this.jenisProduk,
    required this.namaMakanan,
    required this.stokAwal,
    required this.sisaStok,
    required this.isBerjualan,
  });
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final List<DummyPedagang> dummyData = [
    DummyPedagang(
      namaToko: "Siomay Ujang Edun",
      jenisProduk: "Makanan Berat",
      namaMakanan: "Siomay & Batagor",
      stokAwal: 100,
      sisaStok: 25,
      isBerjualan: true,
    ),
    DummyPedagang(
      namaToko: "Es Teh Solo Kang Asep",
      jenisProduk: "Minuman",
      namaMakanan: "Es Teh Jumbo",
      stokAwal: 200,
      sisaStok: 150,
      isBerjualan: true,
    ),
    DummyPedagang(
      namaToko: "Cimol Bojot Neng Putri",
      jenisProduk: "Makanan Ringan",
      namaMakanan: "Cimol & Basreng",
      stokAwal: 80,
      sisaStok: 0,
      isBerjualan: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2c2c2e), // Set background color to dark
      appBar: AppBar(
        backgroundColor: Color(0xff1c1c1e),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: SvgPicture.asset(
            "assets/images/logo_asongan.svg",
            width: 32,
            height: 32,
            semanticsLabel: "logo asongan",
            // colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),

        title: Text(
          "Pedagang Terdekat Anda",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            icon: Icon(Icons.menu_rounded, color: Color(0xffffffff)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyData.length,
        itemBuilder: (context, index) {
          final pedagang = dummyData[index];
          return Card(
            color: Color(0xFF1c1c1e),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pedagang.namaToko,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: pedagang.isBerjualan
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          pedagang.isBerjualan ? "Sedang Berjualan" : "Tutup",
                          style: TextStyle(
                            color: pedagang.isBerjualan
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    pedagang.namaMakanan,
                    style: TextStyle(color: Color(0xFFF5a623), fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Jenis: ${pedagang.jenisProduk}",
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Stok",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${pedagang.stokAwal}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Sisa Stok",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${pedagang.sisaStok}",
                            style: TextStyle(
                              color: pedagang.sisaStok > 10
                                  ? Colors.white
                                  : Colors.redAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: pedagang.sisaStok / pedagang.stokAwal,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pedagang.sisaStok > 10
                          ? Color(0xFFF5a623)
                          : Colors.redAccent,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 8,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
