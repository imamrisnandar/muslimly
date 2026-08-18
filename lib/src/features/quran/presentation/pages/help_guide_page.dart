import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/app_transparent_app_bar.dart';

class HelpGuidePage extends StatelessWidget {
  const HelpGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppTransparentAppBar(
        title: l10n.guideTitle,
        titleFontSize: 20.sp,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          _buildGuideSection(
            context,
            l10n.guideTargetTitle,
            l10n.guideTargetDesc,
            '🎯',
          ),
          SizedBox(height: 16.h),
          _buildGuideSection(
            context,
            l10n.guideMushafTitle,
            l10n.guideMushafDesc,
            '📖',
          ),
          SizedBox(height: 16.h),
          _buildGuideSection(
            context,
            l10n.guideListTitle,
            l10n.guideListDesc,
            '🔢',
          ),
          SizedBox(height: 16.h),
          _buildGuideSection(
            context,
            l10n.guideInsightTitle,
            l10n.guideInsightDesc,
            '📊',
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildGuideSection(
    BuildContext context,
    String title,
    String desc,
    String icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDarker,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(icon, style: TextStyle(fontSize: 20.sp)),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(padding: EdgeInsets.all(16.w), child: _buildStyledText(desc)),
        ],
      ),
    );
  }

  Widget _buildStyledText(String text) {
    // Split lines to handle bullet points nicely
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final content = line.trim();
        final isBullet = content.startsWith('•');
        final cleanContent = isBullet ? content.substring(1).trim() : content;

        if (cleanContent.isEmpty) return const SizedBox.shrink();

        final textWidget = RichText(
          text: TextSpan(
            children: _parseFormatting(cleanContent),
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
              height: 1.5,
              fontFamily: 'Outfit',
            ),
          ),
        );

        if (isBullet) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "•",
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(child: textWidget),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: textWidget,
        );
      }).toList(),
    );
  }

  List<TextSpan> _parseFormatting(String text) {
    final List<TextSpan> spans = [];
    // Split by ** for bold
    final boldParts = text.split('**');

    for (int i = 0; i < boldParts.length; i++) {
      final isBold = i % 2 == 1;
      final part = boldParts[i];

      if (isBold) {
        // Bold segments: render as bold white
        spans.add(
          TextSpan(
            text: part,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      } else {
        // Normal segments: check for *italics*
        final italicParts = part.split('*');
        for (int j = 0; j < italicParts.length; j++) {
          final isItalic = j % 2 == 1;
          final subPart = italicParts[j];
          if (subPart.isNotEmpty) {
            spans.add(
              TextSpan(
                text: subPart,
                style: isItalic
                    ? const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      )
                    : null,
              ),
            );
          }
        }
      }
    }
    return spans;
  }
}
