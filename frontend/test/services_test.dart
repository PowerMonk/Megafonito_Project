import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_megafonito/services/notices_service.dart';
import 'package:flutter_megafonito/services/server_config.dart';

void main() {
  test('normalizes server URLs for QR and manual entry', () {
    expect(
      ServerConfig.normalize('192.168.137.1:8787'),
      'http://192.168.137.1:8787',
    );
    expect(
      ServerConfig.normalize('http://192.168.137.1:8787/'),
      'http://192.168.137.1:8787',
    );
    expect(
      ServerConfig.normalize('megafonito://192.168.137.1:8787'),
      'http://192.168.137.1:8787',
    );
    expect(ServerConfig.normalize(''), isNull);
    expect(ServerConfig.normalize('ftp://example.com'), isNull);
  });

  test('announcement drafts keep the group audience intact', () {
    const draft = AnnouncementDraft(
      title: 'Prueba',
      content: 'Contenido',
      category: 'Eventos',
      audience: 'groups',
      group: 'Ingeniería Mecánica',
    );

    expect(draft.toBody()['audience'], 'groups');
    expect(draft.toBody()['groups'], ['Ingeniería Mecánica']);
    expect(draft.audienceLabel, 'Ingeniería Mecánica');

    const everyone = AnnouncementDraft(
      title: 'General',
      content: 'Contenido',
      category: 'General',
      audience: 'all',
    );
    expect(everyone.toBody()['groups'], isEmpty);
    expect(everyone.audienceLabel, 'Todos los estudiantes');
  });
}
