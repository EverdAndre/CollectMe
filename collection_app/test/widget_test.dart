import 'package:collection_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('abre a tela inicial', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Bem Vindo a Sua Colecao'), findsOneWidget);
    expect(find.text('Meus Itens'), findsOneWidget);
  });
}
