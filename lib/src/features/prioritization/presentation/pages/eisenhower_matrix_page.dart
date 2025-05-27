import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/prioritization/presentation/bloc/prioritization_bloc.dart';
import 'package:planning/src/features/prioritization/presentation/widgets/eisenhower_matrix.dart';
import 'package:planning/src/features/prioritization/presentation/widgets/magic_prioritization_button.dart';
import 'package:planning/src/core/utils/logger.dart';

/// A page that displays the Eisenhower Matrix for task prioritization
class EisenhowerMatrixPage extends StatefulWidget { // Changed to StatefulWidget
  /// Creates an EisenhowerMatrixPage
  const EisenhowerMatrixPage({Key? key}) : super(key: key);

  @override
  State<EisenhowerMatrixPage> createState() => _EisenhowerMatrixPageState();
}

class _EisenhowerMatrixPageState extends State<EisenhowerMatrixPage> {
  @override
  void initState() {
    super.initState();
    // Explicitly trigger loading tasks when the page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log.info('EisenhowerMatrixPage: Triggering LoadPrioritizedTasks');
      context.read<PrioritizationBloc>().add(const LoadPrioritizedTasks());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eisenhower Matrix'),
        automaticallyImplyLeading: false, // Disable automatic back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            try {
              // Try to use GoRouter first
              GoRouter.of(context).go('/');
            } catch (e) {
              // If that fails, try regular navigation
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }
          },
          tooltip: 'Back',
        ),
        actions: [
          BlocBuilder<PrioritizationBloc, PrioritizationState>(
            builder: (context, state) {
              if (state is PrioritizationLoadSuccess) {
                return IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterDialog(context),
                  tooltip: 'Filter tasks',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Add a debug button to reload tasks
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              log.info('EisenhowerMatrixPage: Manual refresh triggered');
              context.read<PrioritizationBloc>().add(const LoadPrioritizedTasks());
            },
            tooltip: 'Reload tasks',
          ),
        ],
      ),
      body: BlocBuilder<PrioritizationBloc, PrioritizationState>(
        builder: (context, state) {
          if (state is PrioritizationInitial) {
            // Dispatch the load event when we enter the page
            context.read<PrioritizationBloc>().add(const LoadPrioritizedTasks());
            return const Center(child: CircularProgressIndicator());
          } else if (state is PrioritizationLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PrioritizationLoadSuccess) {
            if (state.currentFilter != null) {
              // Show filtered view
              return _buildFilteredView(context, state);
            } else {
              // Show matrix view
              return EisenhowerMatrix(
                tasks: state.tasks,
                onTaskTap: (task) {
                  // Handle task tap - e.g., navigate to task details
                },
                onPriorityChanged: (task, newPriority) {
                  context.read<PrioritizationBloc>().add(
                        UpdateTaskPriority(
                          task: task,
                          newPriority: newPriority,
                        ),
                      );
                },
                onRefreshRequired: () {
                  // Trigger refresh to sync bloc state with local matrix changes
                  log.info('EisenhowerMatrixPage: Auto-refresh triggered after priority change');
                  context.read<PrioritizationBloc>().add(const LoadPrioritizedTasks());
                },
              );
            }
          } else if (state is PrioritizationLoadFailure) {
            return _buildErrorView(context, state);
          }
          
          // Default fallback
          return const Center(child: Text('Something went wrong'));
        },
      ),
      floatingActionButton: BlocBuilder<PrioritizationBloc, PrioritizationState>(
        builder: (context, state) {
          if (state is PrioritizationLoadSuccess) {
            // Get unprioritized tasks for the magic button
            final unprioritizedTasks = state.tasks.where(
              (task) => task.priority == EisenhowerCategory.unprioritized
            ).toList();
            
            return MagicPrioritizationButton(
              unprioritizedTasks: unprioritizedTasks,
              onRefreshRequired: () {
                log.info('EisenhowerMatrixPage: Auto-refresh triggered from magic button');
                context.read<PrioritizationBloc>().add(const LoadPrioritizedTasks());
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilteredView(
    BuildContext context,
    PrioritizationLoadSuccess state,
  ) {
    return Column(
      children: [
        // Filter header
        Container(
          padding: const EdgeInsets.all(16.0),
          color: state.currentFilter?.color.withOpacity(0.1),
          child: Row(
            children: [
              Text(
                'Filtered: ${state.currentFilter?.name}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  context.read<PrioritizationBloc>().add(const FilterTasks(null));
                },
                tooltip: 'Clear filter',
              ),
            ],
          ),
        ),
        
        // Task list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: state.tasks.length,
            itemBuilder: (context, index) {
              final task = state.tasks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  title: Text(
                    task.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Handle task tap - e.g., navigate to task details
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    PrioritizationLoadFailure state,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load tasks: ${state.message}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<PrioritizationBloc>().add(const LoadPrioritizedTasks());
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Filter Tasks'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Tasks'),
                onTap: () {
                  context.read<PrioritizationBloc>().add(const FilterTasks(null));
                  Navigator.of(dialogContext).pop();
                },
              ),
              ...EisenhowerCategory.values.map((category) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: category.color,
                    radius: 12,
                  ),
                  title: Text(category.name),
                  onTap: () {
                    context.read<PrioritizationBloc>().add(FilterTasks(category));
                    Navigator.of(dialogContext).pop();
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
