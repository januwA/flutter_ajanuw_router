import 'package:flutter_ajanuw_router/util/remove_first_string.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test('test replaceFirst function.', () {
    expect(removeFirstString('/www/home'), 'www/home');
    expect(removeFirstString('www/home'), 'www/home');
    expect('www/home'.replaceFirst('/', ''), 'wwwhome');

    expect(removeFirstString(':id'), ':id');
    expect(removeFirstString(':id', ':'), 'id');
  });
}
