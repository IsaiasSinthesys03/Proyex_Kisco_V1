import 'package:flutter/material.dart';

class RankingWaitScreen extends StatelessWidget {
  const RankingWaitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.watch_later_outlined,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'La Evaluación todavía no ha concluido, espere un poco más por favor',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
