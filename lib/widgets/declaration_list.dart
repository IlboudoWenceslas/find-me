import 'package:appodcgroupe/declaration_detail_page.dart';
import 'package:appodcgroupe/widgets/declaration_card.dart';
import 'package:flutter/material.dart';

class DeclarationList extends StatelessWidget {
  final List<Map<String, dynamic>> declarations;

  const DeclarationList({
    super.key,
    required this.declarations,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: declarations.length,
      itemBuilder: (context, index) {
        final declaration = declarations[index];

        return DeclarationCard(
          declaration: declaration,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeclarationDetailsPage(
                  declaration: declaration,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
