import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/ajanuw_router_generator_base.dart';


Builder ajanuwRouter(BuilderOptions opt) =>
    SharedPartBuilder([AjanuwRouterGenerator()], 'ajanuw_router');