import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final Locale locale;
  final String? userName;
  final int dailyTarget;
  final int dailyAyahTarget;
  final String targetUnit; // 'page' or 'ayah'

  const SettingsState({
    required this.locale,
    this.userName,
    this.dailyTarget = 4,
    this.dailyAyahTarget = 50,
    this.targetUnit = 'page',
  });

  factory SettingsState.initial() {
    return const SettingsState(
      locale: Locale('id'),
      userName: null,
      dailyTarget: 4,
      dailyAyahTarget: 50,
      targetUnit: 'page',
    );
  }

  SettingsState copyWith({
    Locale? locale,
    String? userName,
    int? dailyTarget,
    int? dailyAyahTarget,
    String? targetUnit,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      userName: userName ?? this.userName,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      dailyAyahTarget: dailyAyahTarget ?? this.dailyAyahTarget,
      targetUnit: targetUnit ?? this.targetUnit,
    );
  }

  @override
  List<Object?> get props => [
    locale,
    userName,
    dailyTarget,
    dailyAyahTarget,
    targetUnit,
  ];
}
