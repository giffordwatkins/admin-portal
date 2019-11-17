import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:flutter/foundation.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/models/entities.dart';

part 'pref_state.g.dart';

abstract class PrefState implements Built<PrefState, PrefStateBuilder> {
  factory PrefState() {
    return _$PrefState._(
      layout: AppLayout.tablet,
      menuSidebarMode: AppSidebarMode.collapse,
      historySidebarMode: AppSidebarMode.visible,
      isMenuVisible: false,
      isHistoryVisible: true,
      enableDarkMode: true,
      requireAuthentication: false,
      emailPayment: false,
      autoStartTasks: false,
      longPressSelectionIsDefault: false,
      addDocumentsToInvoice: false,
      companyPrefs: BuiltList(
          List<int>.generate(kMaxNumberOfCompanies, (i) => i + 1)
              .map((index) => CompanyPrefState())
              .toList()),
    );
  }

  PrefState._();

  AppLayout get layout;

  AppSidebarMode get menuSidebarMode;

  AppSidebarMode get historySidebarMode;

  bool get isMenuVisible;

  bool get isHistoryVisible;

  bool get enableDarkMode;

  bool get longPressSelectionIsDefault;

  bool get requireAuthentication;

  bool get emailPayment;

  bool get autoStartTasks;

  bool get addDocumentsToInvoice;

  BuiltList<CompanyPrefState> get companyPrefs;

  bool get isTablet => layout != AppLayout.mobile;

  bool get isMobile => layout == AppLayout.mobile;

  bool get isMenuFloated =>
      layout == AppLayout.mobile || menuSidebarMode == AppSidebarMode.float;

  bool get isHistoryFloated =>
      layout == AppLayout.mobile || historySidebarMode == AppSidebarMode.float;

  bool get showMenu =>
      (isMenuVisible && menuSidebarMode == AppSidebarMode.visible) ||
      menuSidebarMode == AppSidebarMode.collapse;

  bool get showHistory =>
      isHistoryVisible && historySidebarMode == AppSidebarMode.visible;

  bool get isMenuCollapsed =>
      isTablet && menuSidebarMode == AppSidebarMode.collapse && !isMenuVisible;

  static Serializer<PrefState> get serializer => _$prefStateSerializer;
}

abstract class CompanyPrefState
    implements Built<CompanyPrefState, CompanyPrefStateBuilder> {
  factory CompanyPrefState({
    String accentColor,
  }) {
    return _$CompanyPrefState._(
      accentColor: kDefaultAccentColor,
      historyList: BuiltList<HistoryRecord>(),
    );
  }

  CompanyPrefState._();

  String get accentColor;

  BuiltList<HistoryRecord> get historyList;

  static Serializer<CompanyPrefState> get serializer =>
      _$companyPrefStateSerializer;
}

class AppLayout extends EnumClass {
  const AppLayout._(String name) : super(name);

  static Serializer<AppLayout> get serializer => _$appLayoutSerializer;

  static const AppLayout mobile = _$mobile;
  static const AppLayout tablet = _$tablet;
  static const AppLayout desktop = _$desktop;

  static BuiltSet<AppLayout> get values => _$values;

  static AppLayout valueOf(String name) => _$valueOf(name);
}

class AppSidebar extends EnumClass {
  const AppSidebar._(String name) : super(name);

  static Serializer<AppSidebar> get serializer => _$appSidebarSerializer;
  static const AppSidebar menu = _$menu;
  static const AppSidebar history = _$history;

  static BuiltSet<AppSidebar> get values => _$valuesSidebar;

  static AppSidebar valueOf(String name) => _$valueOfSidebar(name);
}

class AppSidebarMode extends EnumClass {
  const AppSidebarMode._(String name) : super(name);

  static Serializer<AppSidebarMode> get serializer =>
      _$appSidebarModeSerializer;

  static const AppSidebarMode float = _$float;
  static const AppSidebarMode visible = _$visible;
  static const AppSidebarMode collapse = _$collapse;

  static BuiltSet<AppSidebarMode> get values => _$valuesSidebarMode;

  static AppSidebarMode valueOf(String name) => _$valueOfSidebarMode(name);
}

abstract class HistoryRecord
    implements Built<HistoryRecord, HistoryRecordBuilder> {
  factory HistoryRecord({
    @required String id,
    @required EntityType entityType,
  }) {
    return _$HistoryRecord._(
      id: id,
      entityType: entityType,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  HistoryRecord._();

  String get id;

  EntityType get entityType;

  int get timestamp;

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  bool matchesRecord(HistoryRecord record) =>
      record.id == id && record.entityType == entityType;

  static Serializer<HistoryRecord> get serializer => _$historyRecordSerializer;
}
