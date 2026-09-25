import 'package:flutter/material.dart';

class AppStatusBar extends StatelessWidget {
  const AppStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cutout = MediaQuery.viewPaddingOf(context).top;
    final height = (cutout > 0 ? cutout : 28.0) + 10;

    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      alignment: Alignment.bottomCenter,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: const Row(
        children: [
          Text(
            'movie:time',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              letterSpacing: 0.2,
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          _StaticBattery(),
        ],
      ),
    );
  }
}

class _StaticBattery extends StatelessWidget {
  const _StaticBattery();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.white70, width: 1),
          ),
          padding: const EdgeInsets.all(1.5),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.82,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3DDC84),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 1),
        Container(
          width: 2,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}
