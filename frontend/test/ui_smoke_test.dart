import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_megafonito/main.dart';
import 'package:flutter_megafonito/screens/anuncios_screen.dart';
import 'package:flutter_megafonito/screens/contact_screen.dart';
import 'package:flutter_megafonito/screens/crear_anuncio_screen.dart';
import 'package:flutter_megafonito/screens/oppscontent_screen.dart';
import 'package:flutter_megafonito/theme/app_theme.dart';
import 'package:flutter_megafonito/widgets/actions_buttons.dart';
import 'package:flutter_megafonito/widgets/navbar.dart';
import 'package:flutter_megafonito/widgets/notice_card.dart';
import 'package:flutter_megafonito/widgets/notices_filter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app opts into the shared Material 3 theme', (tester) async {
    await tester.pumpWidget(const MyApp());

    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).useMaterial3, isTrue);
    expect(Theme.of(context).colorScheme.brightness, Brightness.light);
  });

  testWidgets('shell preserves five destinations at compact and wide widths',
      (tester) async {
    _setLogicalSize(tester, const Size(390, 844));
    addTearDown(() => _resetLogicalSize(tester));
    await tester.pumpWidget(_shell());

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(AppNavigationRail), findsNothing);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Oportunidades'), findsOneWidget);
    expect(find.text('Procesos'), findsOneWidget);
    expect(find.text('Cuenta'), findsOneWidget);
    expect(find.byTooltip('Soporte'), findsOneWidget);

    await tester.tap(find.text('Contactos'));
    await tester.pumpAndSettle();
    expect(find.text('Directorio escolar'), findsOneWidget);

    await tester.tap(find.text('Oportunidades'));
    await tester.pumpAndSettle();
    await tester.pump();
    expect(find.text('Explora oportunidades'), findsOneWidget);

    await tester.tap(find.text('Procesos'));
    await tester.pumpAndSettle();
    expect(find.text('Procesos escolares'), findsOneWidget);

    await tester.tap(find.text('Cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Tu horario'), findsOneWidget);

    await tester.tap(find.byTooltip('Soporte'));
    await tester.pumpAndSettle();
    expect(find.text('Estamos para ayudarte'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    _setLogicalSize(tester, const Size(1024, 768));
    await tester.pumpWidget(_shell(key: const ValueKey('wide-shell')));
    await tester.pump();

    expect(find.byType(AppNavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Contactos'), findsOneWidget);
    await tester.tap(find.text('Procesos'));
    await tester.pumpAndSettle();
    expect(find.text('Procesos escolares'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  });

  testWidgets('notice card uses supplied metadata and remains tappable',
      (tester) async {
    _setLogicalSize(tester, const Size(320, 720));
    addTearDown(() => _resetLogicalSize(tester));
    var opened = false;
    final notice = <String, dynamic>{
      'title': 'Aviso de prueba',
      'author_name': 'Coordinación Académica con un nombre largo',
      'category': 'Convocatorias',
      'created_at': DateTime(2026, 10, 13),
      'has_attachment': true,
    };

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              NoticeCard(
                anuncio: notice,
                onTap: (_) => opened = true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Aviso de prueba'), findsOneWidget);
    expect(find.text('13 oct'), findsOneWidget);
    expect(find.byTooltip('Incluye un archivo adjunto'), findsOneWidget);
    await tester.tap(find.text('Aviso de prueba'));
    expect(opened, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('category chips notify selection and can be cleared',
      (tester) async {
    final selected = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: NoticesFilter(
            onCategorySelected: selected.add,
            onSortOptionSelected: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Eventos'));
    await tester.pump();
    expect(selected, ['Eventos']);

    await tester.tap(find.text('Eventos'));
    await tester.pump();
    expect(selected, ['Eventos', '']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('contacts fit a narrow, large-text layout and expose copy labels',
      (tester) async {
    _setLogicalSize(tester, const Size(320, 720));
    addTearDown(() => _resetLogicalSize(tester));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.35)),
          child: const Scaffold(body: ContactosEscolaresScreen()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Directorio escolar'), findsOneWidget);
    final copyPhoneButton = find.byTooltip('Copiar Teléfono').first;
    expect(copyPhoneButton, findsOneWidget);
    final targetSize = tester.getSize(copyPhoneButton);
    expect(targetSize.width, greaterThanOrEqualTo(48));
    expect(targetSize.height, greaterThanOrEqualTo(48));
    expect(tester.takeException(), isNull);
  });

  testWidgets('notice composer scrolls within a narrow keyboard viewport',
      (tester) async {
    _setLogicalSize(tester, const Size(360, 640));
    addTearDown(() => _resetLogicalSize(tester));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              viewInsets: const EdgeInsets.only(bottom: 260),
            ),
            child: child!,
          );
        },
        home: const CrearNuevoAnuncioScreen(
          onAnuncioCreado: _ignoreCreatedNotice,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Nuevo anuncio'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.byType(Card), findsNothing);
    for (final textField
        in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(textField.decoration?.filled, isFalse);
      expect(textField.decoration?.enabledBorder, InputBorder.none);
    }
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -220));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('opportunity art is contained and the next card is previewed',
      (tester) async {
    _setLogicalSize(tester, const Size(390, 844));
    addTearDown(() => _resetLogicalSize(tester));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const OpportunityContentScreen(title: 'Ingeniería en Sistemas'),
      ),
    );
    await tester.pump();

    final firstCard = find.byType(Card).first;
    final cardSize = tester.getSize(firstCard);
    expect(cardSize.width, 148);
    expect(tester.widget<Image>(find.byType(Image).first).fit, BoxFit.contain);

    final nextCardTitle = tester.getRect(find.text('Beca 3'));
    expect(nextCardTitle.left, lessThan(390));
    expect(nextCardTitle.right, greaterThan(390));
    expect(tester.takeException(), isNull);
  });

  testWidgets('expanded create actions have unique Hero tags', (tester) async {
    _setLogicalSize(tester, const Size(390, 844));
    addTearDown(() => _resetLogicalSize(tester));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Stack(
            children: [
              ActionButtons(
                isSuperUser: true,
                showExtraFabs: true,
                onShowExtraFabs: () {},
                onCreateNotice: () {},
                onDismissBlur: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('Crear nueva oportunidad'), findsOneWidget);
    expect(find.byTooltip('Crear nuevo mensaje'), findsOneWidget);
    expect(find.byTooltip('Crear nuevo anuncio'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('create actions transition smoothly without backdrop blur',
      (tester) async {
    _setLogicalSize(tester, const Size(390, 844));
    addTearDown(() => _resetLogicalSize(tester));
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(const _ActionMenuHarness());
    expect(find.bySemanticsLabel('Más acciones de creación'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Más acciones de creación'));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Crear nueva oportunidad'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tapAt(const Offset(10, 100));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Más acciones de creación'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}

Widget _shell({Key? key}) {
  return MaterialApp(
    key: key,
    theme: AppTheme.light,
    home: const AnunciosScreen(
      userName: 'Demo User',
      userEmail: 'demo@example.test',
    ),
  );
}

void _ignoreCreatedNotice(
  String title,
  String content,
  Color color,
  String category,
  bool hasAttachment,
  String? fileUrl,
  String? fileKey,
) {}

class _ActionMenuHarness extends StatefulWidget {
  const _ActionMenuHarness();

  @override
  State<_ActionMenuHarness> createState() => _ActionMenuHarnessState();
}

class _ActionMenuHarnessState extends State<_ActionMenuHarness> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Stack(
          children: [
            ActionButtons(
              isSuperUser: true,
              showExtraFabs: _isExpanded,
              onShowExtraFabs: () => setState(() => _isExpanded = true),
              onCreateNotice: () {},
              onDismissBlur: () => setState(() => _isExpanded = false),
            ),
          ],
        ),
      ),
    );
  }
}

void _setLogicalSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
}

void _resetLogicalSize(WidgetTester tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}
