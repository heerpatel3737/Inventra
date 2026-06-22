import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../widgets/buttons/luxury_button.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../providers/settings_providers.dart';

class OfflineSyncScreen extends ConsumerWidget {
  const OfflineSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncAsync = ref.watch(syncStatusProvider);
    final refresh = ref.read(syncRefreshProvider);

    return LuxuryScaffold(
      route: AppRoutes.offlineSync,
      title: 'Offline Sync',
      header: const EditorialHeader(
        eyebrow: 'Reliability Layer',
        title: 'Synchronization Health',
        subtitle: 'Observe queue state, sync quality, and conflict posture across offline operations.',
      ),
      children: [
        syncAsync.when(
          loading: () => const AppLoadingView(message: 'Loading sync status...'),
          error: (error, _) => AppErrorView(
            message: 'Unable to load sync status.\n$error',
            onRetry: refresh,
          ),
          data: (status) => Column(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.cloud_done_outlined),
                  title: const Text('Last successful sync'),
                  subtitle: Text(formatSyncTimestamp(status.lastSuccessfulSync)),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.pending_actions_outlined),
                  title: const Text('Pending records'),
                  subtitle: Text('${status.pendingRecords} queued inventory events'),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.sync_problem_outlined),
                  title: const Text('Conflicts'),
                  subtitle: Text(
                    status.conflictCount == 0
                        ? 'No active conflicts detected'
                        : '${status.conflictCount} conflicts require review',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              LuxuryButton(
                label: status.isSyncing ? 'Syncing...' : 'Sync Now',
                icon: Icons.sync_rounded,
                onPressed: status.isSyncing
                    ? null
                    : () async {
                        await ref.read(syncStatusProvider.notifier).syncNow();
                        if (context.mounted) {
                          AppSnackbar.showSuccess(context, 'Sync Complete');
                        }
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
