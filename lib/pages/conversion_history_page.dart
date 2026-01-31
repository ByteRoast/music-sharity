import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/conversion_history_entry.dart';
import '../services/conversion_history_service.dart';

class ConversionHistoryPage extends StatefulWidget {
  final VoidCallback? onNavigateToHome;

  const ConversionHistoryPage({super.key, this.onNavigateToHome});

  @override
  State<ConversionHistoryPage> createState() => _ConversionHistoryPageState();
}

class _ConversionHistoryPageState extends State<ConversionHistoryPage> {
  final ConversionHistoryService _conversionHistoryService =
      ConversionHistoryService();

  List<ConversionHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();

    _history = _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion History'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              offset: const Offset(0, 48),
              onSelected: (String value) async {
                switch (value) {
                  case 'clear_history':
                    _showConfirmClearHistoryDialog();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  enabled: _history.isNotEmpty,
                  value: 'clear_history',
                  child: Text('Clear history'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _history.isEmpty
          ? _buildEmptyListCard()
          : ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: _history.length,
              itemBuilder: (context, index) =>
                  _buildHistoryCard(_history[index]),
            ),
    );
  }

  List<ConversionHistoryEntry> _loadHistory() {
    return _conversionHistoryService.getEntryList();
  }

  Widget _buildEmptyListCard() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20.0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No conversion history',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your conversion history will appear here',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: widget.onNavigateToHome,
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(ConversionHistoryEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            SizedBox(
              width: 55,
              height: 55,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: entry.metadata?.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: entry.metadata!.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image),
                      )
                    : const Icon(Icons.broken_image, size: 40),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.metadata?.title ?? 'Unknown title',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.metadata?.artist ?? 'Unknown artist',
                    style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('History clear confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to clear your entire history. Do you wish to continue?',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('This cannot be undone after been executed.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              await _clearHistory();
            },
            child: const Text('Clear'),
          ),
          ElevatedButton.icon(
            label: Text('Cancel'),
            icon: Icon(Icons.cancel),
            onPressed: () {
              Navigator.pop(dialogContext);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _clearHistory() async {
    bool delSuccess = await _conversionHistoryService.deleteEntryList();

    if (delSuccess) {
      setState(() {
        _history = _loadHistory();
      });

      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to clear history!'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
