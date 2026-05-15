import 'package:expense_tracker/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/expense_provider.dart';

class SliderExample extends StatefulWidget {
  const SliderExample({super.key});

  @override
  State<SliderExample> createState() => _SliderExampleState();
}

class _SliderExampleState extends State<SliderExample> {
  double _currentSliderValue = 20;
  double _currentDiscreteSliderValue = AppConstants.budget;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: <Widget>[
        Slider(
          value: _currentDiscreteSliderValue,
          max: 10000,
          divisions: 10,
          label: _currentDiscreteSliderValue.round().toString(),
          onChanged: (double value) {
            setState(() {
              _currentDiscreteSliderValue = value;
            });
          },
        ),
      ],
    );
  }
}
