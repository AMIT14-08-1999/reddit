import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/commons/error_text.dart';
import 'package:reddit/core/commons/loader.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/theme/pallet.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({super.key, required this.type});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final linkController = TextEditingController();
  File? bannerFile;
  List<Community> communities = [];
  Community? selectCommunities;
  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descController.dispose();
    linkController.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void sharePost() {
    if (widget.type == 'image' &&
        bannerFile != null &&
        titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareImagePost(
            context: context,
            title: titleController.text.trim(),
            selectCommunity: selectCommunities ?? communities[0],
            image: bannerFile,
          );
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
            context: context,
            title: titleController.text.trim(),
            selectCommunity: selectCommunities ?? communities[0],
            description: descController.text.trim(),
          );
    } else if (widget.type == 'link' &&
        titleController.text.isNotEmpty &&
        linkController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
            context: context,
            title: titleController.text.trim(),
            selectCommunity: selectCommunities ?? communities[0],
            link: linkController.text.trim(),
          );
    } else {
      showSnackBar(context, 'Please enter all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';
    final isLoading = ref.watch(postControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Post ${widget.type}'),
        actions: [
          TextButton(
            onPressed: sharePost,
            child: const Text(
              "Share",
            ),
          ),
        ],
      ),
      body: isLoading
          ? Loader()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'Enter Title Here',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                      maxLength: 30,
                    ),
                    SizedBox(height: 10),
                    if (isTypeImage)
                      GestureDetector(
                        onTap: selectBannerImage,
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: Radius.circular(10),
                          dashPattern: [10, 4],
                          strokeCap: StrokeCap.round,
                          color: currentTheme.textTheme.bodyText2!.color!,
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: bannerFile != null
                                ? Image.file(bannerFile!)
                                : Center(
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 40,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    if (isTypeText)
                      TextField(
                        controller: descController,
                        decoration: InputDecoration(
                          filled: true,
                          hintText: 'Enter Description Here',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18),
                        ),
                        maxLines: 5,
                      ),
                    if (isTypeLink)
                      TextField(
                        controller: linkController,
                        decoration: InputDecoration(
                          filled: true,
                          hintText: 'Enter Link Here',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18),
                        ),
                        maxLines: 5,
                      ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Select Community",
                      ),
                    ),
                    ref.watch(userCommunityProvider).when(
                          data: (data) {
                            communities = data;
                            if (data.isEmpty) {
                              return SizedBox();
                            }
                            return DropdownButton(
                              value: selectCommunities ?? data[0],
                              items: data
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectCommunities = val;
                                });
                              },
                            );
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () => Loader(),
                        ),
                  ],
                ),
              ),
            ),
    );
  }
}
