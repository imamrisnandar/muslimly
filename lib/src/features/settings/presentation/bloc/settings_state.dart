import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final Locale? locale;
  final String userName;
  final int dailyTarget;
  final int dailyAyahTarget;
  final String targetUnit;
  final int hijriAdjustment; // Current month's adjustment
  final List<Map<String, dynamic>> hijriAdjustments; // All adjustments

  const SettingsState({
    this.locale,
    this.userName = '',
    this.dailyTarget = 4,
    this.dailyAyahTarget = 20,
    this.targetUnit = 'page',
    this.hijriAdjustment = 0,
    this.hijriAdjustments = const [],
  });

  factory SettingsState.initial() => const SettingsState(locale: Locale('id'));

  SettingsState copyWith({
    Locale? locale,
    String? userName,
    int? dailyTarget,
    int? dailyAyahTarget,
    String? targetUnit,
    int? hijriAdjustment,
    List<Map<String, dynamic>>? hijriAdjustments,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      userName: userName ?? this.userName,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      dailyAyahTarget: dailyAyahTarget ?? this.dailyAyahTarget,
      targetUnit: targetUnit ?? this.targetUnit,
      hijriAdjustment: hijriAdjustment ?? this.hijriAdjustment,
      hijriAdjustments: hijriAdjustments ?? this.hijriAdjustments,
    );
  }

  @override
  List<Object?> get props => [
    locale,
    userName,
    dailyTarget,
    dailyAyahTarget,
    targetUnit,
    hijriAdjustment,
    hijriAdjustments,
  ];
}
