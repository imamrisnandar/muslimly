import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final Locale locale;
  final String? userName;
  final int dailyTarget;

  const SettingsState({
    required this.locale,
    this.userName,
    this.dailyTarget = 4,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      locale: Locale('en'),
      userName: null,
      dailyTarget: 4,
    );
  }

  SettingsState copyWith({Locale? locale, String? userName, int? dailyTarget}) {
    return SettingsState(
      locale: locale ?? this.locale,
      userName: userName ?? this.userName,
      dailyTarget: dailyTarget ?? this.dailyTarget,
    );
  }

  @override
  List<Object?> get props => [locale, userName, dailyTarget];
}
