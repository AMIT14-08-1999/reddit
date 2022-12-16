import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/theme/pallet.dart';
import 'package:routemaster/routemaster.dart';

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});
  void navigateToType(BuildContext context, String type) {
    Routemaster.of(context).push('/add-profile/$type');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double cardHeightWidth = 120;
    double iconSize = 60;
    final color = ref.watch(themeNotifierProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => navigateToType(context, 'image'),
          child: SizedBox(
            height: cardHeightWidth,
            width: cardHeightWidth,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: color.backgroundColor,
              elevation: 16,
              child: Center(
                  child: Icon(
                Icons.image_outlined,
                size: iconSize,
              )),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => navigateToType(context, 'text'),
          child: SizedBox(
            height: cardHeightWidth,
            width: cardHeightWidth,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: color.backgroundColor,
              elevation: 16,
              child: Center(
                  child: Icon(
                Icons.font_download_rounded,
                size: iconSize,
              )),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => navigateToType(context, 'link'),
          child: SizedBox(
            height: cardHeightWidth,
            width: cardHeightWidth,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: color.backgroundColor,
              elevation: 16,
              child: Center(
                  child: Icon(
                Icons.link_outlined,
                size: iconSize,
              )),
            ),
          ),
        ),
      ],
    );
  }
}
