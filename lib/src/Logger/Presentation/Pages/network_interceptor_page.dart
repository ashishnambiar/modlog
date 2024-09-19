import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../Controller/controller.dart';
import '../../Utils/logger_appbar.dart';
import '../../Utils/netowork_interceptor.dart';
import 'network_details_page.dart';

class NetworkInterceptorPage extends StatefulWidget {
  const NetworkInterceptorPage({super.key});

  @override
  State<NetworkInterceptorPage> createState() => _NetworkInterceptorPageState();
}

class _NetworkInterceptorPageState extends State<NetworkInterceptorPage> {
  final loggerController = GetIt.I<LoggerController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LoggerAppBar(
        title: 'Network ',
        actions: [
          IconButton(
            onPressed: () {
              loggerController.clearNetworkLogs();
            },
            icon: const Icon(Icons.delete),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                scrollControlDisabledMaxHeightRatio: 0.8,
                clipBehavior: Clip.antiAlias,
                builder: (context) {
                  return const NetLogFilterWidget();
                },
              );
            },
            icon: const Icon(
              Icons.filter_alt,
            ),
          ),
        ],
      ),
      body: StreamBuilder<NetworkLoggerState>(
        initialData: loggerController.state.networkLoggerState,
        stream: loggerController.networkLoggerStream,
        builder: (context, snapshot) {
          return Scrollbar(
            thickness: 7,
            thumbVisibility: true,
            interactive: true,
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final log = loggerController //
                      .state
                      .networkLoggerState
                      .filteredLogs
                      .values
                      .toList()[index];
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NetworkDetailsPage(
                            networkLog: log,
                          ),
                        ),
                      );
                    },
                    trailing: Text(
                      log.endTime == null
                          ? 'null'
                          : '${(log.endTime! - TimeOfDay.now()).inMinutes}m ago',
                      style: const TextStyle(color: Colors.black38),
                    ),
                    subtitle: Text(log.request?.uri.withoutQuery ?? 'null'),
                    title: Text(
                        '${log.request?.method} ${log.result?.response?.statusCode ?? 'null'}'),
                    tileColor: index % 2 == 0 //
                        ? Colors.amber[100]
                        : Colors.transparent,
                  );
                },
                itemCount: loggerController.state.networkLoggerState.count,
              ),
            ),
          );
        },
      ),
    );
  }
}

class NetLogFilterWidget extends StatefulWidget {
  const NetLogFilterWidget({super.key});

  @override
  State<NetLogFilterWidget> createState() => _NetLogFilterWidgetState();
}

class _NetLogFilterWidgetState extends State<NetLogFilterWidget> {
  final loggerController = GetIt.I<LoggerController>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NetworkLoggerState>(
      initialData: loggerController.state.networkLoggerState,
      stream: loggerController.networkLoggerStream,
      builder: (context, snapshot) {
        final netLogState = snapshot.data;
        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Status Filter',
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          loggerController.clearStatusFilter();
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 10,
                    children: List.generate(
                      StatusFilter.visible.length,
                      (index) {
                        return FilterChip(
                          showCheckmark: false,
                          onSelected: (value) {
                            loggerController.filterLogs(
                              statusFilter: StatusFilter.visible[index],
                            );
                          },
                          selected: netLogState?.statusFilter ==
                              StatusFilter.visible[index],
                          label: Text(
                            StatusFilter //
                                .visible[index]
                                .name,
                          ),
                        );
                      },
                    ),
                  ),

                  //
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Method Filter',
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          loggerController.clearMethodFilter();
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 10,
                    children: List.generate(
                      MethodFilter.visible.length,
                      (index) {
                        return FilterChip(
                          showCheckmark: false,
                          onSelected: (value) {
                            loggerController.filterLogs(
                              methodFilter: MethodFilter.visible[index],
                            );
                          },
                          selected: netLogState?.methodFilter ==
                              MethodFilter.visible[index],
                          label: Text(
                            MethodFilter //
                                .visible[index]
                                .name
                                .toUpperCase(),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

extension TimeOfDayExtension on TimeOfDay {
  Duration operator -(TimeOfDay other) {
    final m = (other.minute + (other.hour * 60)) - (minute + (hour * 60));
    return Duration(minutes: m);
  }
}
