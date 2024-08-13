import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ScrollAwareFutureBuilder<T> extends StatefulWidget {
  final Future<T> Function() future;
  final AsyncWidgetBuilder builder;

  const ScrollAwareFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
  });

  @override
  State<ScrollAwareFutureBuilder<T>> createState() =>
      _ScrollAwareFutureBuilderState<T>();
}

class _ScrollAwareFutureBuilderState<T>
    extends State<ScrollAwareFutureBuilder<T>> {
  Future<T>? _future;

  void _createDeferredFuture() {
    if (!context.mounted) {
      // Polling: Wait until scrolling is done or context no longer recommends deferring loading
      SchedulerBinding.instance.scheduleFrameCallback((_) {
        scheduleMicrotask(_createDeferredFuture);
      });
      return;
    }
    // Check if loading should be deferred
    if (Scrollable.recommendDeferredLoadingForContext(context)) {
      setState(() {
        _future = null;
      });

      // Polling: Wait until scrolling is done or context no longer recommends deferring loading
      SchedulerBinding.instance.scheduleFrameCallback((_) {
        scheduleMicrotask(_createDeferredFuture);
      });
      return;
    }

    setState(() {
      _future = widget.future();
    });
  }

  @override
  Widget build(BuildContext context) {
    _createDeferredFuture();
    if (_future == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<T>(
      future: _future,
      builder: widget.builder,
    );
  }
}
