import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:innocence_flutter/core/local/offline_store.dart';

void main() {
  test(
      'SQLite v5 upgrade retains legacy task IDs, completion and actual minutes',
      () async {
    sqfliteFfiInit();
    final dir =
        await Directory.systemTemp.createTemp('innocence-assistant-upgrade-');
    final path = '${dir.path}/v5.db';
    final old = await databaseFactoryFfi.openDatabase(path,
        options: OpenDatabaseOptions(
            version: 5,
            onCreate: (db, version) async {
              await db.execute(
                  'CREATE TABLE local_daily_plan(owner_scope TEXT,plan_date TEXT,plan_name TEXT,PRIMARY KEY(owner_scope,plan_date))');
              await db.execute(
                  'CREATE TABLE local_daily_plan_item(owner_scope TEXT,plan_date TEXT,item_id INTEGER,title TEXT,completed INTEGER,planned_minutes INTEGER,actual_minutes INTEGER,start_slot INTEGER,end_slot INTEGER,sort_order INTEGER)');
              await db.insert('local_daily_plan', {
                'owner_scope': 'local:legacy',
                'plan_date': '2026-10-04',
                'plan_name': 'Legacy'
              });
              await db.insert('local_daily_plan_item', {
                'owner_scope': 'local:legacy',
                'plan_date': '2026-10-04',
                'item_id': 17,
                'title': 'Legacy task',
                'completed': 1,
                'planned_minutes': 60,
                'actual_minutes': 55,
                'start_slot': 18,
                'end_slot': 20,
                'sort_order': 0
              });
            }));
    await old.close();
    final store = OfflineStore(
        databaseFactory: databaseFactoryFfi,
        databasePathProvider: () async => path);
    try {
      await store.initialize();
      final plan = await store.loadDailyPlan('local:legacy', '2026-10-04');
      expect(plan.items.single.id, 17);
      expect(plan.items.single.completed, true);
      expect(plan.items.single.actualMinutes, 55);
      expect(plan.dayRevision, 0);
      final db = await databaseFactoryFfi.openDatabase(path);
      expect(await db.getVersion(), 6);
    } finally {
      await store.close();
      expect(dir.absolute.path, startsWith(Directory.systemTemp.absolute.path));
      await dir.delete(recursive: true);
    }
  });
}
