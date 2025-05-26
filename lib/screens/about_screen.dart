import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:othello/config/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with company logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AppTheme.primaryLight,
              child: Column(
                children: [
                  const Text(
                    'Strato Inc.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Innovative Mobile Solutions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      'SI',
                      style: TextStyle(
                        color: AppTheme.primaryLight,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // App information section
            _buildSection(
              context,
              title: 'About the App',
              content: 'Othello (also known as Reversi) is a classic strategy board game for two players. '
                  'This implementation offers multiple game modes including playing against AI, '
                  'local multiplayer, and online matches with friends.\n\n'
                  'The game features a sleek, professional interface with customizable themes '
                  'and smooth animations to enhance your gaming experience.',
            ),
            
            // Features section with expandable cards
            _buildSection(
              context,
              title: 'Features',
              content: '',
              child: Column(
                children: [
                  _buildFeatureCard(
                    context,
                    title: 'AI Opponent',
                    description: 'Challenge yourself against our intelligent AI with multiple difficulty levels.',
                    icon: Icons.smart_toy,
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Local Multiplayer',
                    description: 'Play against a friend on the same device.',
                    icon: Icons.people,
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Online Matches',
                    description: 'Create or join rooms to play with friends online.',
                    icon: Icons.public,
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Theme Options',
                    description: 'Choose between light and dark themes for comfortable play.',
                    icon: Icons.palette,
                  ),
                ],
              ),
            ),
            
            // Developer information
            _buildSection(
              context,
              title: 'Developer',
              content: 'This app was developed by Strato Inc., a company focused on creating '
                  'high-quality mobile applications with intuitive user interfaces and robust functionality.',
            ),
            
            // Contact information with interactive links
            _buildSection(
              context,
              title: 'Connect With Us',
              content: '',
              child: Column(
                children: [
                  _buildContactItem(
                    context,
                    icon: Icons.link,
                    title: 'LinkedIn',
                    subtitle: 'Connect with us on LinkedIn',
                    onTap: () => _launchUrl('https://www.linkedin.com/in/utso/'),
                  ),
                  _buildContactItem(
                    context,
                    icon: Icons.email,
                    title: 'Email',
                    subtitle: 'Send us your feedback',
                    onTap: () => _launchUrl('mailto:contact@stratoinc.com'),
                  ),
                  _buildContactItem(
                    context,
                    icon: Icons.web,
                    title: 'Website',
                    subtitle: 'Visit our website',
                    onTap: () => _launchUrl('https://stratoinc.com'),
                  ),
                ],
              ),
            ),
            
            // Version information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    Widget? child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryLight,
            ),
          ),
          const SizedBox(height: 8),
          if (content.isNotEmpty)
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          if (child != null) 
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: child,
            ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: Icon(
          icon,
          color: AppTheme.accentLight,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(description),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.accentLight,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
  ///url launching
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}