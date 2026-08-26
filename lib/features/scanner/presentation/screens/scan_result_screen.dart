import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/currency_note.dart';
import '../providers/scanner_bloc.dart';
import '../providers/scanner_event.dart';
import '../providers/scanner_state.dart';
import '../widgets/result_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_bloc.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../auth/presentation/providers/auth_event.dart';

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final note =
        ModalRoute.of(context)!.settings.arguments as CurrencyNote;

    return BlocListener<ScannerBloc, ScannerState>(
      listener: (context, state) {
        if (state is ScannerSuccess && state.savedToHistory) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Scan saved to history'),
              backgroundColor: AppColors.authentic,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: isDark ? Colors.white : AppColors.textPrimary),
              onPressed: () {
                context.read<ScannerBloc>().add(const ScannerReset());
                Navigator.of(context).pop();
              },
            );
          }),
          title: Builder(builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Text(
              'Scan Result',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            );
          }),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResultCard(note: note),
              const SizedBox(height: 12),

              _VerifiedChip(note: note),
              const SizedBox(height: 20),

              _DetailSection(note: note),
              const SizedBox(height: 28),

              BlocBuilder<ScannerBloc, ScannerState>(
                builder: (context, state) {
                  final isSaving = state is ScannerSaving;
                  final alreadySaved =
                      state is ScannerSuccess && state.savedToHistory;

                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: alreadySaved
                            ? AppColors.primaryBlueDark
                            : AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: alreadySaved || isSaving
                          ? null
                          : () {
                              final authState = context.read<AuthBloc>().state;
                              final isGuest = authState is AuthAuthenticated && authState.user.isGuest;
                              
                              if (isGuest) {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Account Required'),
                                    content: const Text('Please create an account or sign in to save your scans to history.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          context.read<AuthBloc>().add(const AuthSignOutRequested());
                                          Navigator.of(context).pushNamedAndRemoveUntil('/register', (route) => false);
                                        },
                                        child: const Text('Create Account'),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                context.read<ScannerBloc>().add(const ScannerSaveToHistory());
                              }
                            },
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                              ),
                            )
                          : Icon(
                              alreadySaved
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.add_circle_outline_rounded,
                              color: Colors.white,
                            ),
                      label: Text(
                        alreadySaved ? 'Saved to History' : 'Add to History',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.goldAccent,
                    side: const BorderSide(
                        color: AppColors.goldAccent, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    context.read<ScannerBloc>().add(const ScannerReset());
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifiedChip extends StatelessWidget {
  final CurrencyNote note;
  const _VerifiedChip({required this.note});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue;
    final isSuspicious = note.verdict == ScanVerdict.suspicious || note.verdict == ScanVerdict.counterfeit;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.2 : 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_done_outlined,
                  size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                'Cloud Verified',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (isSuspicious)
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/learn');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: note.verdict == ScanVerdict.suspicious 
                  ? AppColors.suspicious 
                  : AppColors.counterfeit,
              side: BorderSide(
                color: note.verdict == ScanVerdict.suspicious 
                    ? AppColors.suspicious 
                    : AppColors.counterfeit,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.info_outline, size: 18),
            label: const Text(
              'Verify',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  final CurrencyNote note;
  const _DetailSection({required this.note});

  @override
  Widget build(BuildContext context) {
    final formattedTime =
        DateFormat('MMM d, hh:mm a').format(note.timestamp);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            const BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Authentication Details',
                style: AppTextStyles.sectionLabel.copyWith(
                  color: isDark ? Colors.white : null,
                )),
          ),
          Divider(height: 1, color: isDark ? Colors.white12 : AppColors.divider),

          _DetailRow(
            label: 'Value',
            value: note.displayLabel, // already returns "MWK ..."
          ),
          Divider(
              height: 1, color: isDark ? Colors.white12 : AppColors.divider, indent: 16),
          _DetailRow(
            label: 'Confidence',
            value: '',
            trailing: _ConfidenceBar(
                score: note.confidenceScore,
                label: note.confidenceLabel),
          ),
          Divider(
              height: 1, color: isDark ? Colors.white12 : AppColors.divider, indent: 16),
          _DetailRow(
            label: 'Timestamp',
            value: formattedTime,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _DetailRow(
      {required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.detailKey.copyWith(
            color: isDark ? Colors.white70 : null,
          )),
          trailing ?? Text(value, style: AppTextStyles.detailValue.copyWith(
            color: isDark ? Colors.white : null,
          )),
        ],
      ),
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  final double score;
  final String label;
  const _ConfidenceBar({required this.score, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 88), // empty space to maintain position
        Text(label, style: AppTextStyles.detailValue.copyWith(color: isDark ? Colors.white : AppColors.textPrimary)),
      ],
    );
  }
}
