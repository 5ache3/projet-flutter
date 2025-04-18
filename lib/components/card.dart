import 'package:flutter/material.dart';

class PlayerCard extends StatelessWidget {
  final int position;
  final String name;
  final String team;
  final int points;

  const PlayerCard({
    super.key,
    required this.position,
    required this.name,
    required this.team,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$position",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
              width: 230,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  FittedBox(
                    child:Text(team,

                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  )
                ],
              ),
            ),
            Text(
              "$points pts",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
