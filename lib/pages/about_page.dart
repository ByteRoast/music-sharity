/*
 * Music Sharity - Convert music links between streaming platforms
 * Copyright (C) 2025 Sikelio (Byte Roast)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Center(
            child: Image.asset(
              'assets/images/brandings/logo.png',
              width: 100,
              height: 100,
            ),
          ),

          const SizedBox(height: 16),

          const Center(
            child: Text(
              'Music Sharity',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 4),

          Center(
            child: Text(
              'Version $_version',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 8),

          const Center(
            child: Text(
              'Convert music links between streaming platforms',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 32),

          _buildSectionTitle('Links'),

          _buildLinkCard(
            icon: Icons.code,
            title: 'GitHub Repository',
            subtitle: 'View source code',
            onTap: () =>
                _launchUrl('https://github.com/byteroast/music-sharity'),
          ),

          _buildLinkCard(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () =>
                _launchUrl('https://music-sharity.byteroast.fr/PRIVACY'),
          ),

          _buildLinkCard(
            icon: Icons.gavel,
            title: 'License',
            subtitle: 'GPL v3',
            onTap: () => _launchUrl(
              'https://music-sharity.byteroast.fr/LICENSE.md',
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('Developer'),

          _buildLinkCard(
            icon: Icons.person_outline,
            title: 'Sikelio (Byte Roast)',
            subtitle: 'Created by',
            onTap: () => _launchUrl('https://github.com/Sikelio'),
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('Supported Platforms'),

          _buildPlatformChips(),

          const SizedBox(height: 32),

          Center(
            child: Text(
              'Made with ❤️ using Flutter',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              '© 2025 Byte Roast',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLinkCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildPlatformChips() {
    final platforms = [
      'Spotify',
      'Deezer',
      'Apple Music',
      'YouTube Music',
      'Tidal',
    ];

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: platforms.map((platform) {
        return Chip(
          label: Text(platform),
          avatar: const Icon(Icons.music_note, size: 16),
        );
      }).toList(),
    );
  }
}
