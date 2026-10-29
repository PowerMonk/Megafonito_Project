import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/opportunities_detail.dart';

class OpportunityContentScreen extends StatefulWidget {
  final String title;

  const OpportunityContentScreen({super.key, required this.title});

  @override
  State<OpportunityContentScreen> createState() =>
      _OpportunityContentScreenState();
}

class _OpportunityContentScreenState extends State<OpportunityContentScreen> {
  final List<Map<String, String>> _scholarships = List.generate(
    10,
    (index) => {
      'image': index.isEven
          ? 'assets/test_images/Beca_movilidad.jpeg'
          : 'assets/test_images/Beca_santander.png',
      'title': 'Beca ${index + 1}',
    },
  );

  final List<Map<String, String>> _courses = List.generate(
    8,
    (index) => {
      'image': index.isEven
          ? 'assets/test_images/Python_logo.png'
          : 'assets/test_images/Cisco_logo.png',
      'title': 'Curso ${index + 1}',
    },
  );

  final List<Map<String, String>> _jobs = List.generate(
    12,
    (index) => {
      'image': index.isEven
          ? 'assets/test_images/BMW_logo.png'
          : 'assets/test_images/Supabase_logo.png',
      'title': 'Trabajo ${index + 1}',
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: ListView(
            padding: const EdgeInsets.all(AppDesign.pagePadding),
            children: [
              _buildCategorySection('Becas', _scholarships),
              const SizedBox(height: 28),
              _buildCategorySection('Cursos y Certificaciones', _courses),
              const SizedBox(height: 28),
              _buildCategorySection('Bolsa de Trabajo', _jobs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, List<Map<String, String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: 198,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return SizedBox(
                width: 148,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _showOpportunity(item),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(
                                item['image']!,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    ColoredBox(
                                      color: AppDesign.page,
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                          child: Text(
                            item['title']!,
                            style: Theme.of(context).textTheme.labelLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showOpportunity(Map<String, String> item) {
    final opportunity = <String, dynamic>{
      'title': item['title'],
      'author_name': 'Instituto Educativo',
      'content':
          'Esta es una descripción detallada sobre ${item['title']}. Aquí encontrarás toda la información relevante sobre esta oportunidad incluyendo requisitos, beneficios y fechas importantes.',
      'has_attachment': true,
      'attachment_url': item['image'],
      'expiry_date': '30 jun 2025',
    };

    OpportunitiesDetail.show(context, opportunity);
  }
}
