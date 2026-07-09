import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:asongan_app/features/auth/data/firebase_auth_service.dart';
import 'package:asongan_app/features/auth/model/user_model_firebase.dart';
import 'package:asongan_app/features/buyer/presentation/pages/buyer_store_detail_screen.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Semua', 'Terdekat', 'Makanan', 'Minuman'];
  final PanelController _panelController = PanelController();
  final TextEditingController _searchController = TextEditingController();
  List<UserModelFirebase> _pedagangList = [];
  bool _isLoading = true;
  StreamSubscription<List<UserModelFirebase>>? _pedagangSubscription;

  GoogleMapController? _mapController;
  LatLng _centerLocation = const LatLng(-6.2103253010780115, 106.81296123124808);
  LatLng? _currentLocation;
  String _currentAddress = "Menghubungi GPS...";
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    isDarkModeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _pedagangSubscription?.cancel();
    _searchController.dispose();
    isDarkModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (_mapController != null) {
      _setMapStyle(_mapController!, isDarkModeNotifier.value);
    }
  }

  void _loadData() {
    _pedagangSubscription = FirebaseAuthService().streamAllPedagang().listen((list) {
      if (mounted) {
        setState(() {
          _pedagangList = list;
          _isLoading = false;
        });
        _updateMarkers(isDarkModeNotifier.value);
      }
    });
    _checkLocationPermission();
  }

  LatLng _getSellerLocation(UserModelFirebase seller) {
    final seed = (seller.lokasi != null && seller.lokasi!.isNotEmpty)
        ? seller.lokasi.hashCode
        : (seller.id.hashCode);
    final rand = math.Random(seed);
    // Generate offset between -0.015 and +0.015 degrees (approx 1.5 km)
    final latOffset = -0.015 + (rand.nextDouble() * 0.03);
    final lngOffset = -0.015 + (rand.nextDouble() * 0.03);
    return LatLng(
      -6.2103253010780115 + latOffset,
      106.81296123124808 + lngOffset,
    );
  }

  List<UserModelFirebase> _getFilteredPedagang() {
    final query = _searchController.text.toLowerCase();
    return _pedagangList.where((p) {
      final type = p.jenisProduk ?? '';
      final isActive = p.statusJualan == true;

      // Filter by chip
      if (_selectedFilter == 1 && !isActive) return false;
      if (_selectedFilter == 2 &&
          !type.toLowerCase().contains('makanan') &&
          !type.toLowerCase().contains('berat')) return false;
      if (_selectedFilter == 3 &&
          !type.toLowerCase().contains('minuman')) return false;

      // Filter by search query
      final name = (p.namaToko ?? p.nama ?? '').toLowerCase();
      final foodName = (p.namaMakanan ?? '').toLowerCase();
      final matchesSearch = query.isEmpty ||
          name.contains(query) ||
          type.toLowerCase().contains(query) ||
          foodName.contains(query);

      return matchesSearch;
    }).toList();
  }

  void _updateMarkers(bool isDark) {
    final newMarkers = <Marker>{};

    if (_currentLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId("current_location"),
          position: _currentLocation!,
          infoWindow: InfoWindow(
            title: "Lokasi Anda",
            snippet: _currentAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    final filtered = _getFilteredPedagang();
    for (var p in filtered) {
      final isActive = p.statusJualan == true;
      final sellerLoc = _getSellerLocation(p);

      newMarkers.add(
        Marker(
          markerId: MarkerId("seller_${p.id ?? p.namaToko ?? p.nama}"),
          position: sellerLoc,
          infoWindow: InfoWindow(
            title: p.namaToko ?? p.nama ?? 'Pedagang',
            snippet: "${p.jenisProduk ?? ''} • ${p.lokasi ?? ''}",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuyerStoreDetailScreen(seller: p),
                ),
              );
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isActive ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueRed,
          ),
        ),
      );
    }

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentAddress = "Layanan lokasi dinonaktifkan.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = "Izin lokasi ditolak.";
        });
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentAddress = "Izin lokasi ditolak permanen.";
      });
      return;
    } 

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _currentLocation = latLng;
        _centerLocation = latLng;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 14.5),
          ),
        );
      }

      await _getAddressFromLatLng(position.latitude, position.longitude);
      _updateMarkers(isDarkModeNotifier.value);
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = "${place.street}, ${place.subLocality}, ${place.locality}";
        });
      }
    } catch (e) {
      debugPrint("Error geocoding: $e");
      setState(() {
        _currentAddress = "Lokasi tidak diketahui";
      });
    }
  }

  void _setMapStyle(GoogleMapController controller, bool isDark) {
    if (isDark) {
      controller.setMapStyle(_darkMapStyle);
    } else {
      controller.setMapStyle(null);
    }
  }

  static const String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [
        {"color": "#212121"}
      ]
    },
    {
      "elementType": "labels.icon",
      "stylers": [
        {"visibility": "off"}
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#757575"}
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {"color": "#212121"}
      ]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [
        {"color": "#757575"}
      ]
    },
    {
      "featureType": "poi",
      "elementType": "geometry",
      "stylers": [
        {"color": "#181818"}
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": [
        {"color": "#2c2c2c"}
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        {"color": "#000000"}
      ]
    }
  ]
  ''';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color scaffoldBg = isDark
            ? const Color(0xFF1C1C1E)
            : Colors.white;
        final Color panelBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFF5A623)),
                )
              : Column(
                  children: [
                    // Custom AppBar
                    _buildAppBar(context, isDark),
                    // Map + Sliding Panel
                    Expanded(
                      child: SlidingUpPanel(
                        controller: _panelController,
                        minHeight: 200,
                        maxHeight: 340,
                        color: panelBg,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        body: _buildMapArea(isDark),
                        panel: _buildSlidePanel(isDark),
                        parallaxEnabled: true,
                        parallaxOffset: 0.3,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  // --- AppBar with SVG logo ---
  Widget _buildAppBar(BuildContext context, bool isDark) {
    final Color bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color iconColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return Container(
      color: bgColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 12,
        right: 12,
        bottom: 12,
      ),
      child: Row(
        children: [
          // SVG Logo
          SvgPicture.asset(
            "assets/images/logo_asongan.svg",
            width: 32,
            height: 32,
            semanticsLabel: "logo asongan",
          ),
          const SizedBox(width: 10),
          // Title section
          Text(
            'Temukan Pedagang',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const Spacer(),
          // IconButton(
          //   onPressed: () {
          //     isDarkModeNotifier.value = !isDarkModeNotifier.value;
          //   },
          //   icon: Icon(
          //     isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          //     color: iconColor,
          //     size: 22,
          //   ),
          // ),

          IconButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            icon: Icon(Icons.menu_rounded, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }

  // --- Search bar ---
  Widget _buildSearchBar(bool isDark) {
    final Color searchBg = isDark ? const Color(0xFF2A2A2C) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final Color hintColor = isDark
        ? const Color(0xFF9A9A9A)
        : const Color(0xFF7A7A7C);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: searchBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF5A623), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search_rounded, color: hintColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {});
                  _updateMarkers(isDarkModeNotifier.value);
                },
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                ),
                decoration: InputDecoration(
                  hintText: 'Cari pedagang atau produk...',
                  hintStyle: TextStyle(
                    color: hintColor,
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Filter chips ---
  Widget _buildFilterChips(bool isDark) {
    final Color chipBg = isDark ? const Color(0xFF2A2A2C) : Colors.white;
    final Color chipBorderColor = isDark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFE2E8F0);
    final Color inactiveTextColor = isDark
        ? const Color(0xFF9A9A9A)
        : const Color(0xFF7A7A7C);

    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(_filters.length, (index) {
            final selected = _selectedFilter == index;
            final Color bg = selected ? const Color(0xFFF5A623) : chipBg;
            final Color border = selected
                ? const Color(0xFFF5A623)
                : chipBorderColor;
            final Color text = selected ? Colors.white : inactiveTextColor;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = index;
                  });
                  _updateMarkers(isDarkModeNotifier.value);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    _filters[index],
                    style: TextStyle(
                      color: text,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // --- Map area with markers ---
  Widget _buildMapArea(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE8EDF2),
          child: Stack(
            children: [
              // Real Google Map
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _centerLocation,
                    zoom: 14.5,
                  ),
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    _setMapStyle(controller, isDark);
                  },
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                ),
              ),

              // Floating Search Bar & Filter Chips at the top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSearchBar(isDark),
                    _buildFilterChips(isDark),
                  ],
                ),
              ),

              // My location button
              Positioned(
                right: 16,
                bottom: 220,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2C) : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        if (_currentLocation != null && _mapController != null) {
                          _mapController!.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: _currentLocation!,
                                zoom: 14.5,
                              ),
                            ),
                          );
                        } else {
                          _checkLocationPermission();
                        }
                      },
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFFF5A623),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Bottom sliding panel ---
  Widget _buildSlidePanel(bool isDark) {
    final Color panelBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color dragHandleColor = isDark
        ? const Color(0xFF5A5A5C)
        : const Color(0xFFE2E8F0);
    final Color headerColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    final filteredList = _getFilteredPedagang();
    final activeFiltered = filteredList.where((p) => p.statusJualan == true).toList();
    final totalActiveCount = activeFiltered.length;

    return Container(
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 14),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: dragHandleColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedagang Aktif ($totalActiveCount)',
                  style: TextStyle(
                    color: headerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: Color(0xFFF5A623),
                      fontSize: 13,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Horizontal pedagang cards
          SizedBox(
            height: 80,
            child: totalActiveCount == 0
                ? const Center(
                    child: Text(
                      'Belum ada pedagang.',
                      style: TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  )
                : ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ...activeFiltered
                          .map((p) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BuyerStoreDetailScreen(seller: p),
                                    ),
                                  );
                                },
                                child: _buildPedagangCard(
                                  name: p.namaToko ?? p.nama ?? 'Pedagang',
                                  distance: p.lokasi != null && p.lokasi!.isNotEmpty
                                      ? p.lokasi!
                                      : 'Tidak ada lokasi',
                                  imagePath: 'assets/images/tukang_bubur.png', // Placeholder
                                  isDark: isDark,
                                  fotoToko: p.fotoToko,
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPedagangCard({
    required String name,
    required String distance,
    required String imagePath,
    required bool isDark,
    String? fotoToko,
  }) {
    final Color cardBg = isDark ? const Color(0xFF2A2A2C) : Colors.white;
    final Color cardBorderColor = isDark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFE2E8F0);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final Color distanceColor = isDark
        ? const Color(0xFF9A9A9A)
        : const Color(0xFF7A7A7C);

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardBorderColor),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isDark
                      ? const Color(0xFF3A3A3C)
                      : const Color(0xFFF1F5F9),
                  child: ClipOval(
                    child: fotoToko != null && fotoToko.isNotEmpty
                        ? Image.file(
                            File(fotoToko),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Image.asset(
                              imagePath,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            imagePath,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.storefront_rounded,
                              color: Color(0xFFF5A623),
                              size: 20,
                            ),
                          ),
                  ),
                ),
                // Green online indicator dot
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CD964),
                      shape: BoxShape.circle,
                      border: Border.all(color: cardBg, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFFF5A623),
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          distance,
                          style: TextStyle(
                            color: distanceColor,
                            fontSize: 11,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

