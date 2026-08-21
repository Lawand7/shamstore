import 'package:flutter/material.dart';
import 'package:shamstore/features/support/repositories/support_repository.dart';
import 'package:shamstore/screen/my_support_requests_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/app_localizations.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final SupportRepository _supportRepository = SupportRepository();
  final TextEditingController _messageController = TextEditingController();
  String? _selectedIssueKey;
  bool _isSubmitting = false;

  final List<String> _issueKeys = [
    'type_tech',
    'type_report',
    'type_payment',
    'type_suggestion',
    'type_other',
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

  Future<void> _submitQuestion() async {
    final localization = AppLocalizations.of(context);
    final question = _messageController.text.trim();
    final subjectKey = _selectedIssueKey;

    if (question.isEmpty || subjectKey == null) {
      AppFeedback.error(context, localization.translate('error_empty_msg'));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _supportRepository.sendQuestion(
        subject: localization.translate(subjectKey),
        question: question,
      );

      if (!mounted) return;

      AppFeedback.success(context, localization.translate('success_msg'));
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst('Exception: ', '').trim();

      AppFeedback.error(
        context,
        message.isNotEmpty
            ? message
            : localization.translate('error_empty_msg'),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final localization = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.background,
      appBar: AppBar(
        title: Text(
          localization.translate('support_title'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
          crossAxisAlignment: isAr
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              localization.translate('issue_type_label'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.transparent : AppTheme.border,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedIssueKey,
                  isExpanded: true,
                  dropdownColor: isDarkMode
                      ? AppTheme.cardBackground
                      : AppTheme.white,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
                  ),
                  items: _issueKeys.map((String key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Align(
                        alignment: isAr
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Text(
                          localization.translate(key),
                          style: TextStyle(
                            color: isDarkMode
                                ? AppTheme.textPrimary
                                : AppTheme.textDark,
                            fontSize: 13,
                          ),
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 6,
              maxLength: 500,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: localization.translate('hint_support_msg'),
                hintStyle: TextStyle(
                  color: isDarkMode
                      ? AppTheme.textSecondary.withValues(alpha: 0.5)
                      : AppTheme.textLight,
                  fontSize: 12,
                ),
                fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.white,
                filled: true,
                counterStyle: TextStyle(
                  color: isDarkMode
                      ? AppTheme.textSecondary
                      : AppTheme.textLight,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.transparent : AppTheme.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.transparent : AppTheme.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? AppTheme.accentBlue
                      : AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        localization.translate('btn_send_support'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MySupportRequestsPage(),
                          ),
                        );
                      },
                icon: const Icon(Icons.history_outlined, size: 18),
                label: Text(localization.translate('view_my_requests')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
