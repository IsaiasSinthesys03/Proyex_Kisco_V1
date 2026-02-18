import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../data/datasources/api_service.dart';
import 'ranking_wait_page.dart';
import '../../data/models/ranking_model.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final ApiService _apiService = ApiService(baseUrl: AppConstants.baseUrl);
  Future<RankingResponse>? _rankingFuture;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  // Método para cargar/recargar los datos
  Future<void> _loadRanking() async {
    setState(() {
      _rankingFuture = _apiService.getRanking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: RefreshIndicator(
        onRefresh: _loadRanking,
        color: theme.colorScheme.primary,
        child: FutureBuilder<RankingResponse>(
          future: _rankingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _rankingFuture != null) {
              return const Center(child: CircularProgressIndicator());
            }

            // Si hay error o está oculto (isPublic == false)
            if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.isPublic) {
              return ListView( // Usamos ListView para que el RefreshIndicator funcione
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: const RankingWaitScreen(),
                  ),
                ],
              );
            }

            final ranking = snapshot.data!.items;

            if (ranking.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: const RankingWaitScreen(),
                  ),
                ],
              );
            }

            return SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Text(
                      'Ranking Final',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 34,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: ranking.length,
                      itemBuilder: (context, index) {
                        final item = ranking[index];
                        return _buildRankingItem(context, index + 1, item);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRankingItem(BuildContext context, int pos, RankingItem item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    BoxDecoration cardDecoration;
    Color rankColor;
    
    if (pos == 1) {
      cardDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFFC5A059), const Color(0xFF8B6B3F)] 
            : [const Color(0xFFFDE49E), const Color(0xFFE5B95B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      );
      rankColor = isDark ? Colors.white : const Color(0xFF8B6B3F);
    } else if (pos == 2) {
      cardDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFFB0B0B0), const Color(0xFF606060)] 
            : [const Color(0xFFF2F2F2), const Color(0xFFD1D1D1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      );
      rankColor = isDark ? Colors.white : const Color(0xFF606060);
    } else if (pos == 3) {
      cardDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFFCD7F32).withOpacity(0.8), const Color(0xFF8B4513).withOpacity(0.8)] 
            : [const Color(0xFFFFCC99), const Color(0xFFE69966)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      );
      rankColor = isDark ? Colors.white : const Color(0xFF8B4513);
    } else {
      cardDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? theme.colorScheme.surface : Colors.white,
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      );
      rankColor = theme.colorScheme.onSurface.withOpacity(0.4);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: cardDecoration,
      height: 90,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                SizedBox(
                  width: 35,
                  child: Text(
                    '$pos',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: rankColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (pos <= 3 && !isDark) 
                              ? Colors.black.withOpacity(0.1) 
                              : theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            color: (pos <= 3 && !isDark) ? Colors.black87 : theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2F2E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.averageScore.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.chevron_right_rounded, color: rankColor.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
