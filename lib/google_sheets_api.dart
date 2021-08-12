import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  // create credentials
  static const _credentials = r'''
  {
    "type": "service_account",
    "project_id": "flutter-gsheets-tutorial",
    "private_key_id": "bb7227929010cc3b2bcaaf553cf4b8981ec869ba",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC8b93jz/i+ATNz\n4NGmDsQJeXOhSMUvRyZ46zx2LEqnPBSfIMogyXQ08e5i1CiclVvJV79a1Z87ekQd\ni9TVupfq/+BAgKIQTzBIIjjPde8ojUQTeD+MCr6/zHKxMM7GD2t+hHn7lvBThmvE\nPwWLxEnLsNjinDkDQWqz9yVpCRTkpcOv1/PyqLar+HQsdI04OcX9fUpUdW+1wvHp\nx9NtzSnLbzOkdgoUETiMo9JCOD98yvvI/fL0aU5/rJfdtlNr4MgtmxYTX0pPmfbE\nW+137wy1sdOlUrGPyBjG1fduU/KFUF61XSJokkFfLKZtb6rz014tIXpa3F9TxylR\nC74sgwmlAgMBAAECgf8kt4EwQAQswPBB9C8UoTRg/3G8qdGkwhuu/8jvKTIzl1MD\nZRRzNgWovh0nIDob9jk4DrQa3Fd2SPlNsPxwJGlWsSJi4eWGDqRdb7SdtQiC3wmq\noShlfSgztyHc0DJT33beWgfvJl1Q8ezFnahLlchMxyOY/lTLMmGLsP5WK9ImX7vW\nZpL+sBbWtVC+oQ/ZHe/5+F9eOkcfkI8vT4CbNHgFl7KwUloylRRrT4JPcVzTJyNZ\nt3tnGeS0KA9nlvfB7bON3iQvR+vpkoxv8/iE2PpSTD/k1CrjYU0PyfQwZCiA+ppJ\n64Blh6GdlJd68hLEGEuvjkksE3Q0chpSwnh93hkCgYEA7mmzUiheuDCl9A75XxYI\nZKEBrjq00hgvwWufv3qN9147s1eaYjVGdncMRjtmi7jg5XLbxlVfW+C1h7shUcs2\nEe3rKxdqjVi7h9fC8hUtM4Hk9owhmvyOlqbzOwS9/yvI4wO55PdVNIA31fGsBiAl\nRO94btoXeEOifTcM7ZB9Ht0CgYEAylZl4pwvk96I98+LqGNfciLtDg7MECCLMC+K\n2pyLdCgiOXhOV4BUverx46eP6VctGRtIzVCsBVlDhA9wAse73hTyy/eAwBn0TCig\nRFZue7xkP+j+RyzLrALYBfuKDUD20zPnPWkdK68xsJF8wiox8sjTtRuaclOYwzsw\njbGaVWkCgYEAjtM5vwU6QUO7l2sFD2amnoop9JNs0dP1f/0WlWI4/DEyuKzJav4Z\neUy2SLi7JQcbi7l0Weu5FdSXS3naayK/AJy0XntHtOesaKPkQJxZGNs/LEgktbGJ\nRk07t2aO3/f9/6myyq01GR+a04tVD9JgIV0Im/gBSWXTSQoar5L4se0CgYB/Mmck\nWQkzzO6P0oI6HhZPWxNpBfZUoRC+/vQsT8L/B4fUVwPwz/T12y+q7Jh0mN/564QN\nxgwN5Lqj10yUAtngV4z2miXvHaHNCrENpMQZtynSX3cSaV+0R6ljwWhcwp0n0nYo\nzd6PqrfzBtLGAN6bgJJORQcHnfPnr1rriF28GQKBgQDj8r4gKiTyPwg60YGJZZ+g\nsKdeN1LBDrbIcaHXByddLqhLgCz3bmeKZGP1Of00mCli+kz1Y9PlzN0cDZflYwRt\ns/RQBtVPI/Es/SOSFbT8/lwVPEs9zG1vvHLVh6aCl33mhZAYYYBU/kyjOHsLwqCB\noqzG56nxuE6BM9DrBjbu8g==\n-----END PRIVATE KEY-----\n",
    "client_email": "flutter-gsheets-tutorial@flutter-gsheets-tutorial.iam.gserviceaccount.com",
    "client_id": "110329908939319495227",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/flutter-gsheets-tutorial%40flutter-gsheets-tutorial.iam.gserviceaccount.com"
  }

  ''';

  // set up & connect to the spreadsheet
  static final _spreadsheetId = '1RXVFt65CNLcbDUik2uqQL0z0cQyexfiGxQHg1myojAo';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  // some variables to keep track of..
  static int numberOfNotes = 0;
  static List<String> currentNotes = [];
  static bool loading = true;

  // initialise the spreadsheet!
  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Worksheet1');
    countRows();
  }

  // count the number of notes
  static Future countRows() async {
    while (
        (await _worksheet!.values.value(column: 1, row: numberOfNotes + 1)) !=
            '') {
      numberOfNotes++;
    }
    // now we know how many notes to load, now let's load them!
    loadNotes();
  }

  // insert a new note
  static Future insert(String note) async {
    if (_worksheet == null) return;
    numberOfNotes++;
    currentNotes.add(note);
    await _worksheet!.values.appendRow([note]);
  }

  // load existing notes from the spreadsheet
  static Future loadNotes() async {
    if (_worksheet == null) return;

    for (int i = 0; i < numberOfNotes; i++) {
      final String newNote =
          await _worksheet!.values.value(column: 1, row: i + 1);
      if (currentNotes.length < numberOfNotes) {
        currentNotes.add(newNote);
      }
    }
    // this will stop the circular loading indicator
    loading = false;
  }
}
