import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        title: Text(
          AppLocalizations.of(context).translate('About App'),
          style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/mylogo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'ShamStore',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              AppLocalizations.of(context).translate('Your integrated platform for shopping and services'),
              style: TextStyle(fontSize: 13, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
            ),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Text(
                AppLocalizations.of(context).translate('ShamStore description text'),
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                AppLocalizations.of(context).translate('What makes ShamStore special?'),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
              ),
            ),
            const SizedBox(height: 12),

            _buildFeatureRow(context, Icons.bolt, 'Super fast browsing of products and orders', isDarkMode),
            _buildFeatureRow(context, Icons.shield_outlined, 'Full security and protection for user and store data', isDarkMode),
            _buildFeatureRow(context, Icons.layers_outlined, 'Diversity of sections (clothing, electronics, and service ads)', isDarkMode),
            _buildFeatureRow(context, Icons.support_agent, 'Continuous technical support to solve problems and follow up reports', isDarkMode),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context).translate('Version'),
                  style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, fontWeight: FontWeight.w500),
                ),
                Text(
                  ' 1.0.0',
                  style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).translate('All rights reserved © 2026'),
              style: TextStyle(fontSize: 11, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String translationKey, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (isDarkMode ? AppTheme.accentBlue : AppTheme.primary).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context).translate(translationKey),
              style: TextStyle(fontSize: 13, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }
}