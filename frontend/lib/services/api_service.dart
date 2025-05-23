import 'dart:convert';

/// Mock API service with no real backend connections
/// Uses in-memory storage for temporary data during development
class ApiService {
  // Mock token and user data
  static String? _token = "mock_development_token";
  static String? _userRole = "Admin";
  static int? _userId = 1;

  // Getters
  static String? get token => _token;
  static String? get userRole => _userRole;
  static int? get userId => _userId;

  // Mock login that always succeeds
  static Future<Map<String, dynamic>> login(String username) async {
    await Future.delayed(Duration(milliseconds: 800)); // Simulate network delay

    return {
      'token': 'mock_development_token',
      'role': 'Admin',
      'userId': 1,
      'name': username
    };
  }

  // Mock authenticated request that returns dummy data
  static Future<MockResponse> authenticatedRequest(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
  }) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay

    // Return different mock responses based on endpoint
    if (endpoint.contains('/notices')) {
      return MockResponse(200, jsonEncode(getMockNotices()));
    } else if (endpoint.contains('/upload/s3')) {
      return MockResponse(
          201,
          jsonEncode({
            'success': true,
            'fileUrl': 'https://example.com/mock-file.pdf',
            'fileKey': 'mock-file-key-${DateTime.now().millisecondsSinceEpoch}',
            'originalName': 'mock-file.pdf',
            'size': 12345,
            'type': 'application/pdf',
          }));
    }

    // Default response
    return MockResponse(200, jsonEncode({'message': 'Mock response success'}));
  }

  // Get mock notices
  static Future<Map<String, dynamic>> getNotices({
    int page = 1,
    int limit = 5,
    String? category,
    bool? hasFiles,
  }) async {
    await Future.delayed(Duration(milliseconds: 800)); // Simulate network delay

    // Filter notices if category provided
    var notices = getMockNotices();
    var data = notices['data'] as List;

    if (category != null && category.isNotEmpty && category != 'All') {
      data = data.where((notice) => notice['category'] == category).toList();
    }

    if (hasFiles != null) {
      data =
          data.where((notice) => notice['has_attachment'] == hasFiles).toList();
    }

    // Update pagination info
    var totalItems = data.length;
    var totalPages = (totalItems / limit).ceil();

    // Apply pagination
    var start = (page - 1) * limit;
    var end = start + limit;
    if (end > data.length) end = data.length;
    if (start > data.length) start = data.length;

    data = data.sublist(start, end);

    return {
      'data': data,
      'pagination': {
        'currentPage': page,
        'pageSize': limit,
        'totalItems': totalItems,
        'totalPages': totalPages,
      }
    };
  }

  // Clears token (for logout)
  static void clearToken() {
    _token = null;
    _userRole = null;
    _userId = null;
  }

  // Mock notices data
  static Map<String, dynamic> getMockNotices() {
    return {
      'data': [
        {
          'id': 1,
          'title': 'Bienvenidos al semestre agosto-diciembre',
          'content':
              'Les damos la bienvenida a todos los estudiantes al nuevo semestre.',
          'category': 'General',
          'author_name': 'Coordinación Académica',
          'created_at': '2023-10-15T14:30:00.000Z',
          'has_attachment': true,
          'attachment_url': 'https://example.com/mock-calendar.pdf',
          'attachment_key': 'mock-calendar-key',
        },
        {
          'id': 2,
          'title': 'Convocatoria Beca Benito Juarez',
          'content': 'Se abre la convocatoria para la beca Benito Juarez.',
          'category': 'Convocatorias',
          'author_name': 'Departamento de Becas',
          'created_at': '2023-10-15T14:30:00.000Z',
          'has_attachment': true,
          'attachment_url': 'https://example.com/mock-scholarship.pdf',
          'attachment_key': 'mock-scholarship-key',
        },
        {
          'id': 3,
          'title': 'Torneo Deportivo Intercampus',
          'content':
              'Invitamos a todos los estudiantes a participar en el torneo deportivo.',
          'category': 'Deportivos',
          'author_name': 'Coordinación de Deportes',
          'created_at': '2023-10-15T14:30:00.000Z',
          'has_attachment': false,
          'attachment_url': null,
          'attachment_key': null,
        },
        {
          'id': 4,
          'title':
              'Conferencia sobre Inteligencia Artificial en el Auditorio de la Universidad',
          'content':
              'Conferencia magistral sobre los avances en IA. No faltes!',
          'category': 'Eventos',
          'author_name': 'Academia de Sistemas',
          'created_at': '2023-10-15T14:30:00.000Z',
          'has_attachment': false,
          'attachment_url': null,
          'attachment_key': null,
        },
        {
          'id': 5,
          'title': 'Cambios en el plan de estudios',
          'content':
              'Informamos sobre los cambios en el plan de estudios para el siguiente semestre.',
          'category': 'Materias',
          'author_name': 'Dirección Académica',
          'created_at': '2023-10-15T14:30:00.000Z',
          'has_attachment': true,
          'attachment_url': 'https://example.com/mock-curriculum.pdf',
          'attachment_key': 'mock-curriculum-key',
        },
        {
          'id': 6,
          'title': 'Taller de Desarrollo Web',
          'content':
              'Inscríbete al taller de desarrollo web con React y Flutter. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
          'category': 'Comunidad',
          'author_name': 'Club de Programación',
          'created_at': '2023-10-15T14:30:00.000Z',
          'has_attachment': true,
          'attachment_url':
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdSYD20ZhA_YJ_ijTDssLT1Z-MtyGlMhQe5A&s",
          'attachment_key': "anuel-picture-lmao",
        },
        {
          'id': 7,
          'title': 'Lorem 400',
          'content':
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.",
          'category': 'Eventos',
          'author_name': 'Programa Delfín',
          'created_at': '2023-10-14T14:30:00.000Z',
          'has_attachment': true,
          'attachment_url':
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdSYD20ZhA_YJ_ijTDssLT1Z-MtyGlMhQe5A&s",
          'attachment_key': "anuel-picture-lmao",
        },
      ],
      'pagination': {
        'currentPage': 1,
        'pageSize': 5,
        'totalItems': 6,
        'totalPages': 2,
      }
    };
  }
}

// Mock response class to simulate HTTP responses
class MockResponse {
  final int statusCode;
  final String body;

  MockResponse(this.statusCode, this.body);
}
