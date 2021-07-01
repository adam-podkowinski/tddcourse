import 'package:flutter/material.dart';
import 'package:tddcource/features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'package:tddcource/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Trivia',
      theme: ThemeData(
        primaryColor: Colors.green.shade700,
        accentColor: Colors.green.shade500,
      ),
      home: NumberTriviaPage(),
    );
  }
}
