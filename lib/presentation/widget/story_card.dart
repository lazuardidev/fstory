import 'package:flutter/material.dart';
import 'package:fstory/domain/entity/story_entity.dart';
import 'package:fstory/presentation/widget/loading.dart';

class StoryCard extends StatelessWidget {
  final StoryEntity? story;
  final void Function()? onClick;

  const StoryCard({super.key, this.story, this.onClick});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Image.network(
                  'https://story-api.dicoding.dev/images/stories/photos-1641623658595_dummy-pic.png',
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return const Loading();
                    }
                  },
                  errorBuilder: (_, __, ___) {
                    return Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.grey[400],
                    );
                  },
                ),
              ),
            ),
            Text(
              'story.name',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
            ),
            Text(
              'story.description',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              maxLines: 3,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontWeight: FontWeight.w300, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
