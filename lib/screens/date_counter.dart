// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';

class DayCounter extends StatefulWidget {
  final DateTime targetDate;
  final double scale;
  const DayCounter({super.key, required this.targetDate, this.scale = 1.0});

  @override
  State<DayCounter> createState() => _DayCounterState();
}

class _DayCounterState extends State<DayCounter> {
  late Timer _timer;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateDuration();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateDuration();
        });
      }
    });
  }

  void _updateDuration() {
    final now = DateTime.now();
    if (widget.targetDate.isAfter(now)) {
      _duration = widget.targetDate.difference(now);
    } else {
      _duration = Duration.zero;
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _duration.inDays;
    final hours = _duration.inHours % 24;
    final minutes = _duration.inMinutes % 60;
    final seconds = _duration.inSeconds % 60;

    return Container(
      padding:
          EdgeInsets.symmetric(vertical: 14 * widget.scale, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B9EC1).withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimeColumn(days.toString().padLeft(2, '0'), 'DAYS'),
          _buildDivider(),
          _buildTimeColumn(hours.toString().padLeft(2, '0'), 'HOURS'),
          _buildDivider(),
          _buildTimeColumn(minutes.toString().padLeft(2, '0'), 'MINS'),
          _buildDivider(),
          _buildTimeColumn(seconds.toString().padLeft(2, '0'), 'SECS'),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 24 * widget.scale,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C4A6F),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 3 * widget.scale),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 9 * widget.scale,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7B9EC1),
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30 * widget.scale,
      width: 1,
      color: const Color(0xFFD4AF37).withOpacity(0.3),
    );
  }
}
