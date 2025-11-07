import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/dashboard_provider.dart';
import 'package:TrustTags_DMS/features/home/widgets/story_full_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/dashboard_response.dart';

class StoriesSection extends StatelessWidget {
  const StoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardData = context.watch<DashboardProvider>().data;
    final List<TopStory> stories = dashboardData?.topStories ?? [];

    if (stories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: AutoTranslateText(
            "Top Stories",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        // const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              final String thumbUrl = story.thumbnailUrl ?? '';
              final String mainImage = story.assetUrl ?? '';

              return GestureDetector(
                onTap: () {
                  if (mainImage.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StoryFullScreen(
                          imageUrl: mainImage,
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 2),
                    image: thumbUrl.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(thumbUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: thumbUrl.isEmpty
                      ? const Icon(Icons.image_not_supported, color: Colors.grey)
                      : null,
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
