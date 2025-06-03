import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sawaari/Components/ink_well_custom.dart';
import 'package:sawaari/app_router.dart';
import 'package:sawaari/theme/style.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class HistoryDetail extends StatefulWidget {
  final String id;

  HistoryDetail({required this.id});

  @override
  _HistoryDetailState createState() => _HistoryDetailState();
}

class _HistoryDetailState extends State<HistoryDetail> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String? yourReview;
  double? ratingScore;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
        child: ButtonTheme(
          minWidth: screenSize.width,
          height: 50.0,
          child: TextButton(
            child: Text('Submit', style: headingWhite),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRoute.historyScreen);
            },
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 100.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text("History",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    )),
                background: Container(
                  color: whiteColor,
                ),
              ),
            ),
          ];
        },
        body: ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(overscroll: false),
          child: SingleChildScrollView(
            child: InkWellCustom(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoute.driverDetailScreen);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        color: whiteColor,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(70.0),
                              child: SizedBox(
                                height: 70,
                                width: 70,
                                child: Hero(
                                  tag: "avatar_profile",
                                  child: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: CachedNetworkImageProvider(
                                        "https://source.unsplash.com/300x300/?portrait",
                                      )),
                                ),
                              ),
                            ),
                            Container(
                                width: screenSize.width - 100,
                                padding: EdgeInsets.only(left: 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("Steve Bowen", style: textBoldBlack),
                                        Text("08 Jan 2019 15:34", style: textStyle),
                                      ],
                                    ),
                                    Icon(Icons.arrow_forward_ios, color: Colors.grey),
                                  ],
                                ))
                          ],
                        ),
                      ),
                    ),
                    rideHistory(),
                    Container(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
                      color: whiteColor,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text("Bill Details (Cash Payment)",
                                style: TextStyle(
                                    color: blackColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          _billRow("Ride Fare", "\$10.99"),
                          _billRow("Taxes", "\$1.99"),
                          _billRow("Discount", "- \$5.99"),
                          SizedBox(height: 8),
                          _billRow("Total Bill", "\$7.49", isTotal: true),
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Text("Review",
                        style: TextStyle(
                            color: blackColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                    Form(
                      key: formKey,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        color: whiteColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Optional RatingBar (uncomment if needed)
                            // RatingBar.builder(
                            //   initialRating: 4,
                            //   minRating: 1,
                            //   direction: Axis.horizontal,
                            //   allowHalfRating: true,
                            //   itemCount: 5,
                            //   itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            //   itemBuilder: (context, _) => Icon(
                            //     Icons.star,
                            //     color: Colors.amber,
                            //   ),
                            //   onRatingUpdate: (rating) {
                            //     setState(() => ratingScore = rating);
                            //   },
                            // ),
                            SizedBox(height: 10),
                            SizedBox(
                              height: 100.0,
                              child: TextField(
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Write your review",
                                  hintStyle: TextStyle(
                                    color: Colors.black38,
                                    fontFamily: 'Akrobat-Bold',
                                    fontSize: 16.0,
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0)),
                                ),
                                maxLines: 2,
                                keyboardType: TextInputType.multiline,
                                onChanged: (String value) {
                                  setState(() => yourReview = value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _billRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: isTotal ? TextStyle(color: blackColor, fontSize: 16) : textStyle),
          Text(value, style: isTotal ? TextStyle(color: blackColor, fontSize: 16) : textStyle),
        ],
      ),
    );
  }

  Widget rideHistory() {
    return Material(
      elevation: 0.0,
      borderRadius: BorderRadius.circular(15.0),
      color: whiteColor,
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: greyColor, width: 1.0),
          color: whiteColor,
        ),
        child: SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("10:24", style: TextStyle(color: Color(0xFF97ADB6), fontSize: 13.0)),
                    Text("10:50", style: TextStyle(color: Color(0xFF97ADB6), fontSize: 13.0)),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.my_location, color: blackColor),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      height: 25,
                      width: 1.0,
                      color: Colors.grey,
                    ),
                    Icon(Icons.location_on, color: blackColor),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('1, Thrale Street, London, SE19HW, UK',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15)),
                    Text('Ealing Broadway Shopping Centre, London, W55JY, UKK',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
