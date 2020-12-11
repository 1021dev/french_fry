
import 'package:french_fry/provider/store/local/repo/preference_repo.dart';
import 'package:sqflite/sqlite_api.dart';

import 'migrate.dart';

class MigrateV1 implements Migrate {
  @override
  Future<void> create(Batch batch) async {
    await PreferenceRepo().create(batch);
  }

  @override
  Future<void> upgrade(Batch batch) async {
    // With the first version (v1) no need to upgrade anything
    // do nothing here
  }
}
