import 'package:flutter/material.dart';
import 'package:sawaari/app_router.dart';
import 'package:sawaari/theme/style.dart';
import 'package:group_button/group_button.dart';

class CancellationReasonsScreen extends StatefulWidget {
  @override
  _CancellationReasonsScreenState createState() => _CancellationReasonsScreenState();
}

class _CancellationReasonsScreenState extends State<CancellationReasonsScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: whiteColor,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(left: 20.0,right: 20.0, bottom: 20.0),
        child: ButtonTheme(
          height: 50.0,
          minWidth: MediaQuery.of(context).size.width-50,
          child: TextButton(
            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            // elevation: 0.0,
            // color: primaryColor,
            // icon: Text(''),
            // label: Text('Submit', style: headingWhite,
            // ),
            onPressed: (){
              Navigator.of(context).pushReplacementNamed(AppRoute.homeScreen);
            }, child: Text('Submit', style: headingWhite,
          ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 50),
              child: Text("Please select the reason for cancellation:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
                maxLines: 2,
              )
            ),
            SizedBox(height: screenSize.height*0.08,),
            GroupButton<String>(
              options: GroupButtonOptions(
                selectedColor: primaryColor,
                unselectedTextStyle: TextStyle(fontSize: 15),
                borderRadius: BorderRadius.circular(8),
              ),
              buttons: const [
                "I don’t want to share",
                "Can't contact the driver",
                "The price is not reasonable",
                "Pickup address is incorrect",
              ],
              onSelected: (value, index, isSelected) {
                print("Selected reason: $value");
              },
            ),
          ],
        ),
      ),
    );
  }
}
