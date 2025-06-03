import 'package:flutter/material.dart';
import 'package:sawaari/Blocs/place_bloc.dart';
import 'package:sawaari/Screen/Directions/directions_view.dart';
import 'package:provider/provider.dart';

class DirectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var placeBloc = Provider.of<PlaceBloc>(context);

    return Scaffold(
      body: DirectionsView(
        placeBloc: placeBloc,
      ),
    );
  }
}
