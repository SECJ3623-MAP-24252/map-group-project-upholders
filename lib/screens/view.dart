// lib/screens/view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodel.dart'; // Assuming viewmodel.dart is in the same directory (lib/screens/)

/// A general-purpose View.
/// Consider renaming this to something more specific if it represents a particular screen.
/// This View expects a `ViewModel` to be provided by an ancestor `ChangeNotifierProvider`.
class View extends StatelessWidget {
  const View({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ViewModel provided by a ChangeNotifierProvider higher in the widget tree.
    // Example of how to provide it (e.g., in your main.dart or route setup):
    // ChangeNotifierProvider(create: (_) => ViewModel(), child: View())
    final viewModel = Provider.of<ViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.pageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.isLoading ? null : () => viewModel.loadData(),
            tooltip: 'Load Data',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (viewModel.isLoading)
                const CircularProgressIndicator()
              else if (viewModel.errorMessage != null)
                Column(
                  children: [
                    Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => viewModel.clearError(),
                      child: const Text('Dismiss Error'),
                    )
                  ],
                )
              else ...[
                const Text(
                  'This is a general view. Counter value:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '${viewModel.counter}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.isLoading ? null : () => viewModel.incrementCounter(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}