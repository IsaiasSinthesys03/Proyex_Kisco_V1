import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../data/datasources/api_service.dart';
import 'ranking_wait_page.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final ApiService _apiService = ApiService(baseUrl: AppConstants.baseUrl);
  late Future<List<dynamic>> _rankingFuture;

  @override
  void initState() {
    super.initState();
    _rankingFuture = _fetchRanking();
  }

  Future<List<dynamic>> _fetchRanking() async {
    try {
      final response = await _apiService.getProjects(); // En una API real habría un endpoint /ranking
      // Simulamos la lógica de negocio: si el ranking está prohibido por el servidor
      return []; 
    } catch (e) {
      if (e.toString().contains('403')) {
        return [null]; // Marcamos como bloqueado
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _rankingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const RankingWaitScreen();
        }

        // Si el servidor devolvió prohibido (RF-FRONT-08)
        if (snapshot.data!.isNotEmpty && snapshot.data![0] == null) {
          return const RankingWaitScreen();
        }

        final ranking = snapshot.data!;
        if (ranking.isEmpty) return const RankingWaitScreen();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Ranking Final', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ranking.length,
            itemBuilder: (context, index) {
              final item = ranking[index];
              return _buildRankingItem(context, index + 1, item);
            },
          ),
        );
      },
    );
  }

  Widget _buildRankingItem(BuildContext context, int pos, dynamic item) {
    bool isTop3 = pos <= 3;
    Color medalColor = pos == 1 ? Colors.amber : (pos == 2 ? Colors.grey.shade400 : Colors.brown.shade300);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isTop3 ? medalColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text('$pos', style: TextStyle(fontWeight: FontWeight.bold, color: isTop3 ? Colors.white : null)),
          ),
        ),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(item.category),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${item.voteCount} votos',
            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
