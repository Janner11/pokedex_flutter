import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

/// Configura la conexión con la API GraphQL de PokeAPI.
/// Este cliente será usado globalmente en la app.
ValueNotifier<GraphQLClient> buildGqlClient() {
  final httpLink = HttpLink('https://beta.pokeapi.co/graphql/v1beta');

  return ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    ),
  );
}
