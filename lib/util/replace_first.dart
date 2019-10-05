/// 移除path第一个 '/'
///
/// ```dart
/// removeFirstString('/www/home'); // www/home
/// removeFirstString('www/home');  // www/home
/// removeFirstString(':id', ':');  // id
/// ```
removeFirstString(String str, [String r = '/']) {
  return str.replaceFirst(RegExp('^$r'), '');
}
