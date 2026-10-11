import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'pending_case.dart';
import 'screening_record.dart';

/// Banco de dados local (SQLite). Fica num arquivo dentro do celular e
/// funciona sem internet. Sobrevive a fechar o app e a reiniciar o aparelho.
///
/// Um banco é um conjunto de TABELAS. Cada tabela é como uma planilha:
/// colunas (os campos) e linhas (um registro por linha).
class CaseDatabase {
  CaseDatabase._(this._db);

  final Database _db;

  /// Abre o banco (e cria as tabelas na primeira vez que o app roda).
  static Future<CaseDatabase> open() async {
    final folder = await getDatabasesPath(); // pasta privada do app no celular
    final path = p.join(folder, 'retinova.db'); // junta pasta + nome do arquivo

    final db = await openDatabase(
      path,
      version: 1,
      // onCreate roda UMA vez, quando o arquivo ainda não existe.
      onCreate: (db, version) async {
        // Tabela dos casos incertos que vão para o especialista.
        //  - id: identificador único do caso (PRIMARY KEY = não repete)
        //  - probs: as 3 probabilidades, em texto
        //  - created_at: quando foi criado (milissegundos)
        //  - status: 'pending' (falta enviar) ou 'sent' (já enviado)
        await db.execute('''
          CREATE TABLE cases (
            id TEXT PRIMARY KEY,
            probs TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            status TEXT NOT NULL DEFAULT 'pending'
          )
        ''');

        // Tabela de TODAS as triagens (alimenta os contadores e o histórico).
        //  - id: número que o próprio banco gera (AUTOINCREMENT)
        //  - risk: 0, 1 ou 2; vazio (NULL) = "não sei"
        await db.execute('''
          CREATE TABLE screenings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            risk INTEGER,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
    return CaseDatabase._(db);
  }

  // ---------- Tabela cases ----------

  /// INSERT: grava uma linha nova. Se já existir o mesmo id, substitui.
  Future<void> insertCase(PendingCase c) async {
    await _db.insert(
      'cases',
      c.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// SELECT: lê só os casos com status 'pending', do mais antigo ao mais novo.
  Future<List<PendingCase>> pendingCases() async {
    final rows = await _db.query(
      'cases',
      where: 'status = ?', // o ? é preenchido por whereArgs (mais seguro)
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );
    return rows.map(PendingCase.fromMap).toList();
  }

  /// UPDATE: muda o status de um caso para 'sent' (não apaga, só marca).
  Future<void> markSent(String id) async {
    await _db.update(
      'cases',
      {'status': 'sent'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------- Tabela screenings ----------

  Future<void> insertScreening(ScreeningRecord r) async {
    await _db.insert('screenings', r.toMap());
  }

  Future<List<ScreeningRecord>> screenings() async {
    final rows = await _db.query('screenings', orderBy: 'created_at ASC');
    return rows.map(ScreeningRecord.fromMap).toList();
  }
}
