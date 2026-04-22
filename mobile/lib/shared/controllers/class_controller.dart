import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/core/graphql_client.dart';
import 'package:mobile/core/models/class.dart';

class ClassController extends ChangeNotifier {
  List<Class> classes = [];
  bool loaded = false;

  ClassController() {
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    classes = await _fetchClasses();
    loaded = true;
    notifyListeners();
  }

  Future<List<Class>> _fetchClasses() async {
    final client = await GraphqlClient.get();
    const query = r'''
      query {
        classes {
          id
          name
        }
      }
    ''';

    final result = await client.query(QueryOptions(document: gql(query)));
    if (result.hasException) return [];
    return (result.data?['classes'] as List)
        .map((c) => Class.fromJson(c))
        .toList();
  }
}
