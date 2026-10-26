import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'oppscontent_screen.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  List<Map<String, String>> _careerLogos = [];
  bool _hasAssetError = false;

  @override
  void initState() {
    super.initState();
    _loadCareerLogos();
  }

  Future<void> _loadCareerLogos() async {
    const titleMapping = <String, String>{
      'itsu_logo': 'General',
      'ing_admin_logo': 'Ing. en Administración',
      'ing_agricola_logo': 'Ing. en Innovación Agrícola',
      'ing_alimentarias_logo': 'Ing. en Industrias Alimentarias',
      'ing_civil_logo': 'Ing. Civil',
      'ing_electronica_logo': 'Ing. Electrónica',
      'ing_industrial_logo': 'Ing. Industrial',
      'ing_mecanica_logo': 'Ing. Mecánica',
      'ing_mecatronica_logo': 'Ing. en Mecatrónica',
      'ing_sistemas_logo': 'Ing. en Sistemas Computacionales',
    };

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final imagePaths = manifest
          .listAssets()
          .where((path) => path.startsWith('assets/logos_carreras/'))
          .toList()
        ..sort((a, b) {
          final aIsItsu = a.contains('itsu_logo');
          final bIsItsu = b.contains('itsu_logo');
          if (aIsItsu) return -1;
          if (bIsItsu) return 1;
          return a.compareTo(b);
        });

      final logos = imagePaths.map((path) {
        final filename = path.split('/').last;
        final filenameBase = filename.contains('.')
            ? filename.substring(0, filename.lastIndexOf('.'))
            : filename;
        return {
          'image': path,
          'title': titleMapping[filenameBase] ??
              filenameBase.replaceAll('_logo', '').replaceAll('_', ' '),
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _careerLogos = logos;
        _hasAssetError = false;
      });
    } catch (error) {
      debugPrint('Unable to load career logos: $error');
      if (!mounted) return;
      setState(() => _hasAssetError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: AppDesign.page,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(AppDesign.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explora oportunidades',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Recursos organizados por área académica.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: _careerLogos.isEmpty
                      ? _buildLoadingState()
                      : _buildListView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    if (!_hasAssetError) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.image_not_supported_outlined, size: 40),
          const SizedBox(height: 12),
          const Text('No se pudieron cargar las categorías.'),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _loadCareerLogos,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      itemCount: _careerLogos.length,
      padding: EdgeInsets.zero,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _careerLogos[index];
        return Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Image.asset(
                item['image']!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported_outlined,
                ),
              ),
            ),
            title: Text(
              item['title']!,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OpportunityContentScreen(title: item['title']!),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
