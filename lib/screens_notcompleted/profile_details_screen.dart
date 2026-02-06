import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:judotalk/data/country_data.dart';
import 'package:judotalk/data/hosts_data.dart';

class ProfileDetailsScreen extends StatelessWidget {
  final HostData host;

  const ProfileDetailsScreen({super.key, required this.host});

  @override
  Widget build(BuildContext context) {
    final List<String> images = host.images ?? [];

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Image Gallery
            SizedBox(
              height: 350,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    images[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            /// 🔹 Basic Info
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      host.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flag.fromCode(
                    host.country.flagCode,
                    height: 24,
                    width: 36,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Text(
                '${host.level} • ${23} yrs',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔹 About / Profile
            _sectionTitle('About'),
            // _sectionContent(host['profile']),

            /// 🔹 Languages
            _sectionTitle('Languages Spoken'),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              // child: Wrap(
              //   spacing: 8,
              //   children: (host['languages'] as List<String>)
              //       .map(
              //         (lang) => Chip(
              //           label: Text(lang),
              //           backgroundColor: Colors.grey.shade200,
              //         ),
              //       )
              //       .toList(),
              // ),
            ),

            const SizedBox(height: 20),

            /// 🔹 Gifts Received
            _sectionTitle('Gifts Received'),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard, size: 22),
                  const SizedBox(width: 8),
                  // Text(
                  //   // '${host['gifts']} gifts',
                  //   style: const TextStyle(fontSize: 16),
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// 🔹 Section Title Widget
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 🔹 Section Content Widget
  // Widget _sectionContent(String content) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     child: Text(
  //       content,
  //       style: TextStyle(
  //         fontSize: 15,
  //         color: Colors.grey.shade700,
  //       ),
  //     ),
  //   );
  // }
}
