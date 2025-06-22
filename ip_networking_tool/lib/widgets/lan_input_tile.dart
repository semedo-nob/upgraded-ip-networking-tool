import 'package:flutter/material.dart';

class LanInputTile extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController usersController;
  final VoidCallback onRemove;

  const LanInputTile({
    super.key,
    required this.nameController,
    required this.usersController,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'LAN Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: usersController,
                decoration: const InputDecoration(
                  labelText: 'Users',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}