import 'package:flutter/material.dart';
import 'package:sawaari/theme/style.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app_router.dart';

class IntroScreen extends StatefulWidget {



  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  SwiperController? _controller;
  int currentIndex = 0;
  bool isGrantedLocation = false;

  List<Map<String, dynamic>> listItem = [
    {
      "id": '0',
      "title": 'Book a Ride Instantly',
      "description": "With Sawaari, booking a ride is just a tap away. Whether you're heading to work, home, or out with friends — we’ve got you covered, anytime, anywhere.",
      "image": "assets/image/image_taxi_1.png"
    },
    {
      "id": "1",
      "title": "Live Tracking & ETA",
      "description": "Stay informed with live location tracking of your driver, accurate arrival time, and status updates — giving you complete peace of mind.",
      "image": "assets/image/image_taxi_2.png"
    },
    {
      "id": "2",
      "title": "Transparent Fare & Quick Payments",
      "description": "Sawaari offers upfront pricing with no hidden charges. Pay your way — cash, card, or wallet — safely and instantly after every ride.",
      "image": "assets/image/image_taxi_3.png"
    },
  ];

  Future<void> requestPermission() async {
    isGrantedLocation = await Permission.location.request().isGranted;
  }

  Future<void> completeIntroAndProceed() async {
    await requestPermission();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenIntro', true);

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoute.homeScreen,
          (Route<dynamic> route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: screenSize.height * 0.09,
              left: screenSize.width * 0.1,
              right: screenSize.width * 0.1,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  "${listItem[currentIndex]['title']}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  child: Text(
                    "${listItem[currentIndex]['description']}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: screenSize.height * 0.58,
              width: double.infinity,
              padding: EdgeInsets.only(top: 20.0),
              child: Swiper(
                curve: Curves.easeInOut,
                controller: _controller,
                itemCount: listItem.length,
                itemHeight: 200.0,
                viewportFraction: 0.6,
                scale: 0.6,
                loop: false,
                outer: true,
                index: currentIndex,
                onIndexChanged: (int index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(listItem[index]['image']),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  );
                },
                pagination: SwiperPagination(
                  alignment: Alignment.bottomCenter,
                  builder: DotSwiperPaginationBuilder(
                    size: 5.0,
                    activeSize: 10.0,
                    space: 5.0,
                    color: greyColor2,
                    activeColor: blackColor,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: currentIndex == 2
                ? Container(
              padding: EdgeInsets.only(
                bottom: screenSize.height * 0.06,
                left: screenSize.width * 0.1,
                right: screenSize.width * 0.1,
              ),
              child: Container(
                height: 50,
                color: primaryColor,
                child: TextButton(
                  onPressed: completeIntroAndProceed,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Continue To App',
                    style: TextStyle(color: whiteColor, fontSize: 16),
                  ),
                ),
              ),
            )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
