
import 'package:birthday_app/models/person.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BirthdaysDB {

  static final BirthdaysDB instance = BirthdaysDB._init();
  static Database? _database;

  BirthdaysDB._init();

  Future<Database> get database async {
    if(_database != null){
      return _database!;
    }

    _database = await _initDB('birthdays.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 1,
      onCreate: _createDB,
      onOpen: (db) {
        _createDB(db, 1);
      },
    );
  }

  Future _createDB(Database db, int version) async {

    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const integerType = 'INTEGER NOT NULL';
    const textType = 'TEXT NOT NULL';
    const textNullableType = 'TEXT';

    await db.execute("CREATE TABLE IF NOT EXISTS People (person_id $idType, fullname $textType, birthdate $textType, avatar_path $textType, zodiac_sign $textType, notes $textNullableType)");
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // ------------------------

  Future<int> createNewPerson(Person person) async {
    final db = await instance.database;
    final id = await db.insert("People", person.toMap());

    return id;
  }

  Future<Person?> getPersonFromDB(int personID) async {
    final db = await instance.database;

    final maps = await db.query(
      "People",
      columns: ['person_id', 'fullname', 'birthdate', 'avatar_path', 'zodiac_sign', 'notes'],
      where: 'person_id = ?',
      whereArgs: [personID]
    );

    if(maps.isNotEmpty){
      return Person.fromMap(maps.first);
    }
    else{
      return null;
    }
  }

  Future<List<Person>> getAllPeopleFromDB() async {
    final db = await instance.database;

    final maps = await db.query("People");

    List<Person> people = [];
    for(var m in maps){
      people.add(Person.fromMap(m));
    }
    return people;
  }

  Future<bool> deletePersonFromDB(int personID) async {
    final db = await instance.database;

    int res = await db.delete(
      "People",
      where: "person_id = ?",
      whereArgs: [personID]
    );

    if(res == 0){
      return false;
    }
    else{
      return true;
    }
  }
}