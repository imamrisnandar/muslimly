import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/di_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/quran_folder.dart';
import '../bloc/folder/folder_bloc.dart';
import '../bloc/folder/folder_event.dart';
import '../bloc/folder/folder_state.dart';

/// Result of the folder picker. `null` future value means the sheet was
/// dismissed without choosing; a record with `folderId == null` means
/// "save without a folder".
typedef BookmarkFolderChoice = ({int? folderId});

/// Shows the "save bookmark to folder" sheet and resolves with the user's
/// choice, or `null` if they dismissed it.
///
/// [mode] is the bookmark mode ('list' | 'mushaf') — folders are scoped per
/// mode, matching the Bookmarks page.
Future<BookmarkFolderChoice?> showBookmarkFolderPicker(
  BuildContext context, {
  required String mode,
}) {
  return showModalBottomSheet<BookmarkFolderChoice>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _BookmarkFolderPickerSheet(mode: mode),
  );
}

class _BookmarkFolderPickerSheet extends StatefulWidget {
  final String mode;

  const _BookmarkFolderPickerSheet({required this.mode});

  @override
  State<_BookmarkFolderPickerSheet> createState() =>
      _BookmarkFolderPickerSheetState();
}

class _BookmarkFolderPickerSheetState
    extends State<_BookmarkFolderPickerSheet> {
  // FolderBloc is a lazy singleton shared app-wide — grab the same instance the
  // Bookmarks page uses so a folder created here shows up there too.
  final FolderBloc _folderBloc = getIt<FolderBloc>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_folderBloc.state is FolderInitial) {
        final l10n = AppLocalizations.of(context)!;
        _folderBloc.add(
          LoadFolders(
            hapalanLabel: l10n.lblFolderHapalan,
            bacaanLabel: l10n.lblFolderBacaan,
          ),
        );
      }
    });
  }

  void _showCreateFolderDialog() {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    String? error;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            void submit() {
              final name = controller.text.trim();
              if (name.isEmpty) {
                setDialogState(() => error = l10n.errFolderNameRequired);
                return;
              }
              _folderBloc.add(CreateFolder(widget.mode, name));
              Navigator.of(dialogContext).pop();
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF152730),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Text(
                l10n.lblAddFolder,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Outfit',
                ),
              ),
              content: TextField(
                controller: controller,
                autofocus: true,
                maxLength: 30,
                style: const TextStyle(color: Colors.white),
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  hintText: l10n.hintFolderName,
                  hintStyle: const TextStyle(color: Colors.white38),
                  errorText: error,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (_) => submit(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    MaterialLocalizations.of(context).cancelButtonLabel,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: submit,
                  child: Text(
                    l10n.btnCreateFolder,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _folderBloc,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF152730),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        padding: EdgeInsets.only(
          top: 12.h,
          bottom: 12.h + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.lblSaveToFolder,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Flexible(
              child: Material(
                color: Colors.transparent,
                child: BlocBuilder<FolderBloc, FolderState>(
                  builder: (context, state) {
                    final folders = state is FolderLoaded
                        ? state.forMode(widget.mode)
                        : const <QuranFolder>[];

                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.bookmark_add_outlined,
                              color: Colors.white70,
                            ),
                            title: Text(
                              l10n.lblSaveWithoutFolder,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            onTap: () => Navigator.of(
                              context,
                            ).pop<BookmarkFolderChoice>((folderId: null)),
                          ),
                          for (final folder in folders)
                            ListTile(
                              leading: const Icon(
                                Icons.folder_outlined,
                                color: AppColors.accent,
                              ),
                              title: Text(
                                folder.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              onTap: () => Navigator.of(context)
                                  .pop<BookmarkFolderChoice>(
                                    (folderId: folder.id),
                                  ),
                            ),
                          if (state is FolderLoading)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: const CircularProgressIndicator(
                                color: AppColors.accent,
                              ),
                            ),
                          Divider(
                            color: Colors.white.withValues(alpha: 0.08),
                            height: 1,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.create_new_folder_outlined,
                              color: Colors.white54,
                            ),
                            title: Text(
                              l10n.lblAddFolder,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            onTap: _showCreateFolderDialog,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
