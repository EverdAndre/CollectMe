import 'package:flutter/material.dart';

class CollectionSobreScreen extends StatelessWidget {
  const CollectionSobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CollectMe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Aplicativo para organizar seus itens de colecao.'),
            SizedBox(height: 8),
            Text('Versao 1.0.0'),
          ],
        ),
      ),
    );
  }
}
