import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class BeneficiosScreen extends StatefulWidget {
  @override
  _BeneficiosScreenState createState() => _BeneficiosScreenState();
}

class _BeneficiosScreenState extends State<BeneficiosScreen> {
  bool _isGridView = true;
  List<Map<String, String>> careerLogos = [];

  @override
  void initState() {
    super.initState();
    _loadAssetNames();
  }

  Future<void> _loadAssetNames() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    // Map of filename patterns to proper titles - make sure keys match exact filenames without path/extension
    final Map<String, String> titleMapping = {
      'itsu_logo': 'General',
      'ing_admin_logo': 'Ing. en Administración',
      'ing_agricola_logo': 'Ing. en Innovación Agrícola',
      'ing_alimentarias_logo': 'Ing. en Industrias Alimentarias',
      'ing_civil_logo': 'Ing. Civil',
      'ing_electronica_logo': 'Ing. Electrónica',
      'ing_industrial_logo': 'Ing. Industrial',
      'ing_mecanica_logo': 'Ing. Mecánica',
      'ing_mecatronica_logo': 'Ing. Mecatrónica',
      'ing_sistemas_logo': 'Ing. en Sistemas Computacionales',
    };

    List<String> imagePaths = manifestMap.keys
        .where((String key) => key.startsWith('assets/logos_carreras/'))
        .toList();

    // Debug: Print found image paths to check what's available
    // print('Found image paths: $imagePaths');

    imagePaths.sort((a, b) {
      if (a.contains('itsu_logo')) return -1;
      if (b.contains('itsu_logo')) return 1;
      return a.compareTo(b);
    });

    careerLogos = imagePaths.map((path) {
      // Extract base filename without extension - use a better method
      String filename = path.split('/').last;
      String filenameBase = filename.substring(0, filename.lastIndexOf('.'));

      // Debug: Print what we're extracting
      print('Path: $path, Filename: $filename, Base: $filenameBase');

      // Use the mapping to get proper title, or fall back to the filename
      String title = titleMapping[filenameBase] ?? filenameBase;

      return {'image': path, 'title': title};
    }).toList();

    // Take only the first 10 or whatever is available
    if (careerLogos.length > 10) {
      careerLogos = careerLogos.sublist(0, 10);
    }

    setState(() {});
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isGridView
                      ? Icons.grid_view
                      : Icons.format_line_spacing_outlined,
                  color: Colors.black,
                ),
                onPressed: _toggleView,
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: careerLogos.isEmpty
                ? Center(child: CircularProgressIndicator())
                : _isGridView
                    ? _buildGridView(context)
                    : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double itemWidth =
            (constraints.maxWidth - 16 * 2) / 2; // Two items with spacing
        final double itemHeight = itemWidth + 20; // Add space for the subtitle

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: itemWidth / itemHeight,
          ),
          itemCount: careerLogos.length,
          itemBuilder: (context, index) {
            return _buildGridItem(
              careerLogos[index]['image']!,
              careerLogos[index]['title']!,
            );
          },
        );
      },
    );
  }

  Widget _buildGridItem(String imageAsset, String title) {
    return Container(
      decoration: BoxDecoration(
        // Border for the container
        borderRadius: BorderRadius.circular(10),
        // boxShadow: [
        //   BoxShadow(
        //     color: const Color.fromARGB(66, 175, 174, 174),
        //     blurRadius: 2.2,
        //     offset: Offset(0, 2),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: const Color.fromARGB(66, 175, 174, 174)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                // Added ClipRRect here
                borderRadius: BorderRadius.circular(
                    9), // Slightly smaller than container border
                child: Padding(
                  padding: const EdgeInsets.all(0.0), // Added some padding
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit
                        .cover, // Changed to contain to preserve aspect ratio
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: careerLogos.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image in a container with fixed size and border
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 218, 215, 215)),
                  borderRadius: BorderRadius.circular(15),
                ),
                // padding: EdgeInsets.all(10.0),
                child: Image.asset(
                  careerLogos[index]['image']!,
                  fit: BoxFit.fitWidth,
                ),
              ),
              // Text OUTSIDE the container, next to it
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  careerLogos[index]['title']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
