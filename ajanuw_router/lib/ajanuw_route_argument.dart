class AjanuwRouteArgument {
  const AjanuwRouteArgument();
}

///
/// ## Example
/// ```dart
/// import 'package:flutter_ajanuw_router/ajanuw_route_argument.dart';
/// 
/// part 'dog.g.dart';
/// 
/// @ara
/// class Dog extends StatefulWidget {
///  final String id;
///   const Dog({Key key, this.id}) : super(key: key);
///   @override
///   _DogState createState() => _DogState();
/// }
/// ```
/// 
/// generator a DogArguments:
/// ```dart
/// class DogArguments {
///   String id;
///   DogArguments({
///     this.id,
///   });
///   @override
///   String toString() => '''{
///   "id": $id,
/// }''';
///   Map toMap() => {
///         'id': id,
///       };
/// }
/// ```
///
const ara = AjanuwRouteArgument();
