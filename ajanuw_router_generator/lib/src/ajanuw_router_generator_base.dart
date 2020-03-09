import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:flutter_ajanuw_router/ajanuw_route_argument.dart';

class AjanuwRouterGenerator
    extends GeneratorForAnnotation<AjanuwRouteArgument> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    return _g(element);
  }

  String _g(Element element) {
    var visitor = ModelVisitor();
    element.visitChildren(visitor);
    return visitor.toClass();
  }
}

class ModelVisitor extends SimpleElementVisitor {
  /// class name
  DartType className;

  /// 属性字段
  Map<String, DartType> fields = {};

  @override
  void visitConstructorElement(ConstructorElement element) {
    className = element.type.returnType;
  }

  @override
  void visitFieldElement(FieldElement el) {
    // 跳过静态属性
    if (!el.isStatic) {
      fields[el.name] = el.type;

      print(el.computeConstantValue());
      print(el.constantValue);
    }
  }

  String toClass() {
    var classBuffer = StringBuffer();
    final argName = '${className}Arguments';

    classBuffer.writeln('class $argName {');

    for (var name in fields.keys) {
      classBuffer.writeln('${fields[name]} ${name};');
    }

    classBuffer.writeln('$argName({');
    for (var paramKey in fields.keys) {
      classBuffer.writeln('this.${paramKey},');
    }
    classBuffer.writeln('});');

    classBuffer.writeln('@override');
    classBuffer.writeln("String toString() => '''{");
    for (var name in fields.keys) {
      classBuffer.writeln('  "$name": \$$name,');
    }
    classBuffer.writeln("}''';");

    classBuffer.writeln('Map toMap() => {');
    for (var name in fields.keys) {
      classBuffer.writeln("'$name': $name,");
    }
    classBuffer.writeln('};');

    classBuffer.writeln('}');
    return classBuffer.toString();
  }
}
