import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/conversion_history_entry.dart';
import '../services/conversion_history_service.dart';

class ConversionHistoryPage extends StatefulWidget {
  const ConversionHistoryPage({super.key});

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

    _history = _conversionHistoryService.getEntryList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversion History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: _history.length,
        itemBuilder: (context, index) => _buildHistoryCard(_history[index]),
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
}
