import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Utils/logger_appbar.dart';

import '../../Controller/controller.dart';
import '../../Utils/netowork_interceptor.dart';

class NetworkDetailsPage extends StatefulWidget {
  const NetworkDetailsPage({
    required this.networkLog,
    super.key,
  });
  final NetworkLoggerData networkLog;

  @override
  State<NetworkDetailsPage> createState() => _NetworkDetailsPageState();
}

class _NetworkDetailsPageState extends State<NetworkDetailsPage> {
  NetworkError? get error => widget.networkLog.result?.error;
  Response<dynamic>? get response => widget.networkLog.result?.response;
  RequestOptions get request => widget.networkLog.request ?? RequestOptions();

  bool _collapseResponseBody = false;
  bool _collapseRequestBody = false;

  void _toggleResponseBody() => setState(() {
        _collapseResponseBody = !_collapseResponseBody;
      });

  void _toggleRequestBody() => setState(() {
        _collapseRequestBody = !_collapseRequestBody;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LoggerAppBar(title: 'Details'),
      body: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (response?.requestOptions.cURL == null) {
                        logger(message: 'unable to get cURL');
                      }
                      Clipboard.setData(
                        ClipboardData(
                          text: response!.requestOptions.cURL,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('cURL'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: request.uri.toString(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('URL'),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TitleWidget('URI: '),
                Expanded(child: Text('${request.uri}')),
              ],
            ),
            Row(
              children: [
                const _TitleWidget('Method: '),
                Expanded(child: Text(request.method)),
              ],
            ),
            if (request.extra.isNotEmpty) ...[
              const _TitleWidget('Extra: '),
              Text('${request.extra}'),
            ],
            if (request.tryJson.isNotEmpty) ...[
              const _TitleWidget('Body'),
              InkWell(
                onTap: _toggleRequestBody,
                child: Container(
                  color: Colors.amber.withValues(alpha: .3),
                  child: Text(
                    const JsonEncoder.withIndent(
                      '    ',
                    ).convert(request.tryJson),
                    overflow: TextOverflow.fade,
                    maxLines: _collapseRequestBody ? 2 : null,
                  ),
                ),
              ),
            ],
            const _TitleWidget('Headers:', 2),
            ...List.generate(
              request.headers.length,
              (index) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleWidget('${request.headers.keys.elementAt(index)}: '),
                  Expanded(
                    child: Text('${request.headers.values.elementAt(index)}'),
                  ),
                ],
              ),
            ),
            const Divider(),
            if (error != null) ...[
              Container(
                color: Colors.red[100],
                child: Column(
                  children: [
                    Text('Error: ${error?.error}'),
                    const Divider(),
                    Text('Message: ${error?.message}'),
                    const Divider(),
                    Text('StackTrace: ${error?.stackTrace}'),
                    const Divider(),
                    Text('Type: ${error?.type}'),
                  ],
                ),
              ),
            ],
            Row(
              children: [
                const _TitleWidget('Status Code: '),
                Text('${response?.statusCode}'),
              ],
            ),
            const _TitleWidget('Response: ', 2),
            if (response != null)
              Stack(
                children: [
                  InkWell(
                    onTap: _toggleResponseBody,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.blue.withValues(alpha: .2),
                      child: Text(
                        const JsonEncoder.withIndent(
                          '    ',
                        ).convert(response?.data),
                        overflow: TextOverflow.fade,
                        maxLines: _collapseResponseBody ? 2 : null,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: const JsonEncoder.withIndent(
                              '    ',
                            ).convert(response?.data),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _TitleWidget extends StatelessWidget {
  const _TitleWidget(
    this.text, [
    this.priority,
  ]);
  final String text;
  final int? priority;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: switch (priority) {
          1 => Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
          2 => Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
          3 => Theme.of(context).textTheme.titleSmall,
          _ => Theme.of(context).textTheme.titleSmall,
        });
  }
}
