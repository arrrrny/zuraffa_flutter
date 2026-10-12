@Tags(['integration', 'slow'])
library;
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa/src/core/generator_options.dart';
import 'package:zuraffa/src/generator/code_generator.dart';
import 'package:zuraffa/src/models/generator_config.dart';

import '../helpers/vpc_test_utils.dart';

void main() {
  late VpcWorkspace workspace;
  late String outputDir;

  setUp(() async {
    workspace = await createWorkspace('presentation_only_workflow');
    await writeFlutterPubspec(workspace);
    outputDir = workspace.outputDir;
  });

  tearDown(() async {
    await disposeWorkspace(workspace);
  });

  test(
    'generates only presentation layer when requested',
    timeout: Timeout(Duration(minutes: 5)),
    () async {
      // Simulating: zfa make Profile view presenter controller state (with mock/di enabled in zfa.json)
      final config = GeneratorConfig(
        name: 'Profile',
        methods: const [], // Non-entity based
        generateVpcs: true,
        generateView: true,
        generatePresenter: true,
        generateController: true,
        generateState: true,
        generateMock: true, // Enabled by default in zfa.json
        generateDi: true, // Enabled by default in zfa.json
        generateUseCase: false,
        generateRepository: false,
        generateDataSource: false,
        generateData: false,
        outputDir: outputDir,
      );

      final generator = CodeGenerator(
        config: config,
        outputDir: outputDir,
        options: const GeneratorOptions(
          dryRun: false,
          force: true,
          verbose: false,
        ),
        disabledPluginIds: {'usecase', 'repository', 'datasource', 'provider'},
      );

      final result = await generator.generate();

      expect(result.success, isTrue);

      // Check Presentation layer — this workspace is a *Flutter* fixture:
      // `writeFlutterPubspec` declares a `flutter:` SDK, so per Constitution
      // VII (Engine Purity) the view/presenter/controller generators correctly
      // EMIT their output for this Flutter target. The full presentation-only
      // VPC workflow (view + presenter + controller generated, and ONLY those)
      // is verified here.
      expect(
        File(
          '$outputDir/presentation/pages/profile/profile_view.dart',
        ).existsSync(),
        isTrue,
        reason:
            'Flutter target must generate a Flutter view '
            '(Constitution VII: Engine Purity)',
      );
      expect(
        File(
          '$outputDir/presentation/pages/profile/profile_presenter.dart',
        ).existsSync(),
        isTrue,
        reason:
            'Flutter target must generate a Flutter presenter '
            '(Constitution VII: Engine Purity)',
      );
      expect(
        File(
          '$outputDir/presentation/pages/profile/profile_controller.dart',
        ).existsSync(),
        isTrue,
        reason:
            'Flutter target must generate a Flutter controller '
            '(Constitution VII: Engine Purity)',
      );
      // State is pure-Dart-safe (no zuraffa_flutter symbols) and is still
      // generated for a presentation-only request.
      expect(
        File(
          '$outputDir/presentation/pages/profile/profile_state.dart',
        ).existsSync(),
        isTrue,
      );

      // Check Domain/Data layer DOES NOT exist
      expect(
        File(
          '$outputDir/domain/repositories/profile_repository.dart',
        ).existsSync(),
        isFalse,
      );
      expect(
        File(
          '$outputDir/data/repositories/data_profile_repository.dart',
        ).existsSync(),
        isFalse,
      );
      expect(
        File(
          '$outputDir/data/datasources/profile/profile_remote_datasource.dart',
        ).existsSync(),
        isFalse,
      );

      // The mock lane is on (`generateMock: true`, enabled by default in
      // zfa.json) and an explicit mock request is never a silent no-op
      // (#770), so the mock datasource and its data fixture ARE emitted. The
      // mock datasource imports and implements `ProfileDataSource`, so when
      // the datasource plugin is not active MockBuilder emits that interface
      // itself (#417) — deliberately keyed on file existence, so it holds
      // regardless of plugin execution order. All three are expected.
      expect(
        File(
          '$outputDir/data/datasources/profile/profile_datasource.dart',
        ).existsSync(),
        isTrue,
        reason:
            'MockBuilder scaffolds the interface the mock datasource '
            'implements when the datasource plugin is not active (#417)',
      );
      expect(
        File(
          '$outputDir/data/datasources/profile/profile_mock_datasource.dart',
        ).existsSync(),
        isTrue,
        reason: 'generateMock is on — the mock datasource is emitted (#770)',
      );
      expect(
        File('$outputDir/data/mock/profile_mock_data.dart').existsSync(),
        isTrue,
        reason: 'generateMock is on — the mock data fixture is emitted (#770)',
      );

      // Check DI files for Domain/Data layer DO NOT exist
      expect(
        File('$outputDir/di/usecases/profile_usecase_di.dart').existsSync(),
        isFalse,
      );
      expect(
        File(
          '$outputDir/di/repositories/profile_repository_di.dart',
        ).existsSync(),
        isFalse,
      );
      expect(
        File(
          '$outputDir/di/datasources/profile_remote_datasource_di.dart',
        ).existsSync(),
        isFalse,
      );
      expect(
        File(
          '$outputDir/di/datasources/profile_mock_datasource_di.dart',
        ).existsSync(),
        isFalse,
      );
    },
  );
}
