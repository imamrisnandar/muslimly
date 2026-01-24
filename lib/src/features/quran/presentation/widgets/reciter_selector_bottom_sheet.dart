import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';
import '../../domain/entities/reciter.dart';

class ReciterSelectorBottomSheet extends StatelessWidget {
  final AudioSourceType? filterSource;
  const ReciterSelectorBottomSheet({super.key, this.filterSource});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.6.sh,
      decoration: BoxDecoration(
        color: const Color(0xFF0F2027),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              filterSource == AudioSourceType.quranComChapter
                  ? 'Select Reciter (Full Surah)'
                  : filterSource == AudioSourceType.alQuranCloudVerse
                  ? 'Select Reciter (Verse by Verse)'
                  : 'Select Reciter (Qori)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<AudioBloc, AudioState>(
              builder: (context, state) {
                if (state.status == AudioStatus.loading &&
                    state.reciters.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter Logic
                final reciters = filterSource != null
                    ? state.reciters
                          .where((r) => r.source == filterSource)
                          .toList()
                    : state.reciters;

                if (reciters.isEmpty) {
                  return Center(
                    child: Text(
                      "No Reciters Found",
                      style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: reciters.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.white.withOpacity(0.1)),
                  itemBuilder: (context, index) {
                    final reciter = reciters[index];
                    final isSelected = reciter.id == state.selectedReciter?.id;

                    return ListTile(
                      onTap: () {
                        context.read<AudioBloc>().add(SelectReciter(reciter));
                        context.pop();
                      },
                      title: Text(
                        reciter.name,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF00E676)
                              : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (reciter.style != null)
                            Text(
                              reciter.style!,
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12.sp,
                              ),
                            ),
                          Text(
                            reciter.source == AudioSourceType.quranComChapter
                                ? "Full Surah (Gapless)"
                                : "Verse-by-Verse",
                            style: TextStyle(
                              color:
                                  reciter.source ==
                                      AudioSourceType.quranComChapter
                                  ? const Color(0xFF64B5F6) // Light Blue
                                  : const Color(0xFFFFCC80), // Light Orange
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF00E676),
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
