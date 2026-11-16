import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import 'models.dart';

/// Opens an attachment in the phone's own viewer / browser.
Future<void> openAttachment(BuildContext context, Attachment a) async {
  final url = a.url;
  var ok = false;
  if (url != null) {
    try {
      ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } on Object {
      ok = false;
    }
  }
  if (!ok && context.mounted) {
    GHaptics.error();
    GToast.show(context, context.l10n.attachmentOpenFailed, icon: GIcons.error);
  }
}

/// Photos as a grid, other files as rows; a tap opens the file.
class AttachmentsView extends StatelessWidget {
  const AttachmentsView({super.key, required this.attachments});
  final List<Attachment> attachments;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = context.t;
    final l = context.l10n;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final images = attachments.where((a) => a.isImage && a.url != null).toList();
    final files = attachments.where((a) => !images.contains(a)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (images.isNotEmpty)
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final a in images)
                GPressable(
                  onTap: () => unawaited(openAttachment(context, a)),
                  semanticLabel: '${l.openFile}: ${a.name}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      a.url!,
                      fit: BoxFit.cover,
                      cacheWidth: (104 * dpr).round(),
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: c.surface2,
                        child: Center(child: GIcon(GIcons.image, color: c.ink3)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        for (final a in files)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GCard(
              color: c.surface2,
              onTap: a.url == null ? null : () => unawaited(openAttachment(context, a)),
              semanticLabel: '${l.openFile}: ${a.name}',
              child: Row(
                children: [
                  GIcon(GIcons.file, color: c.ink2),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(a.name, style: t.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  GIcon(GIcons.openInNew, size: 20, color: c.ink3),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
