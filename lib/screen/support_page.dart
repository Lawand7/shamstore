import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedIssueKey;

  final List<String> _issueKeys = [
    'type_tech',
    'type_report',
    'type_payment',
    'type_suggestion',
    'type_other'
  ];

  @override
  void initState() {
    super.initState();
    _selectedIssueKey = _issueKeys[0];
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final localization = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        title: Text(
          localization.translate('support_title'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              localization.translate('issue_type_label'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedIssueKey,
                  isExpanded: true,
                  dropdownColor: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
                  icon: Icon(Icons.arrow_drop_down, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary),
                  items: _issueKeys.map((String key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Align(
                        alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(
                          localization.translate(key),
                          style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 13),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedIssueKey = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              localization.translate('issue_details_label'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _messageController,
              maxLines: 6,
              maxLength: 500,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 13),
              decoration: InputDecoration(
                hintText: localization.translate('hint_support_msg'),
                hintStyle: TextStyle(color: isDarkMode ? AppTheme.textSecondary.withOpacity(0.5) : AppTheme.textLight, fontSize: 12),
                fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.white,
                filled: true,
                counterStyle: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDarkMode ? Colors.transparent : AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDarkMode ? Colors.transparent : AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (_messageController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localization.translate('error_empty_msg'), textAlign: isAr ? TextAlign.right : TextAlign.left),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localization.translate('success_msg'), textAlign: isAr ? TextAlign.right : TextAlign.left),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  localization.translate('btn_send_support'),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}