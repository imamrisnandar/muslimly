import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';

class ReciterSelectorBottomSheet extends StatelessWidget {
  const ReciterSelectorBottomSheet({super.key});

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
              'Select Reciter (Qori)',
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

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: state.reciters.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.white.withOpacity(0.1)),
                  itemBuilder: (context, index) {
                    final reciter = state.reciters[index];
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
                      subtitle: reciter.style != null
                          ? Text(
                              reciter.style!,
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12.sp,
                              ),
                            )
                          : null,
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
