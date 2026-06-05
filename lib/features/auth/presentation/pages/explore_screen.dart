import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "Temukan Pedagang",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: Colors.white),
          ),
          IconButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            icon: Icon(Icons.menu_rounded, color: Color(0xffffffff)),
          ),
        ],
      ),
      body: SlidingUpPanel(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/map_jakarta_light.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),

        color: Color(0xff1c1c1e),
        minHeight: 60,
        maxHeight: 300,

        borderRadius: const BorderRadius.vertical(
          top: Radius.elliptical(64, 20),
        ),
        panel: Column(
          children: [
            SizedBox(height: 12),
            Container(
              width: 64,
              height: 6,
              decoration: BoxDecoration(
                color: Color(0xffE8E8E8),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // SizedBox(height: 24),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          "Pedagang Aktif ()",
                          style: TextStyle(
                            color: Color(0xffffffff),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 96),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Lihat Semua",
                            style: TextStyle(color: Color(0xfff5a623)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 200,
                            height: 64,
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    child: Image.asset(
                                      "assets/images/tukang1.png",
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    "Siomay Ujang Edun",
                                    style: TextStyle(color: Color(0xffffffff)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            height: 64,
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    child: Image.asset(
                                      "assets/images/tukang2.png",
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    "Siomay Ujang Edun",
                                    style: TextStyle(color: Color(0xffffffff)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
