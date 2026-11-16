import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Material Symbols Rounded (design-system §2.8). Outline by default; pass
/// `fill: 1` to [GIcon] for the active tab, status pills and checks.
abstract final class GIcons {
  static const today = Symbols.light_mode_rounded;
  static const week = Symbols.calendar_view_week_rounded;
  static const grades = Symbols.insights_rounded;
  static const tasks = Symbols.task_alt_rounded;
  static const family = Symbols.family_home_rounded;
  static const inbox = Symbols.inbox_rounded;
  static const bell = Symbols.notifications_rounded;
  static const room = Symbols.door_front_rounded;
  static const swap = Symbols.swap_horiz_rounded;
  static const excuse = Symbols.event_busy_rounded;
  static const checkIn = Symbols.photo_camera_front_rounded;
  static const location = Symbols.location_on_rounded;
  static const synced = Symbols.cloud_done_rounded;
  static const syncing = Symbols.cloud_upload_rounded;
  static const syncFailed = Symbols.cloud_off_rounded;
  static const homework = Symbols.edit_note_rounded;
  static const summary = Symbols.checklist_rounded;
  static const plan = Symbols.menu_book_rounded;
  static const mic = Symbols.mic_rounded;
  static const attach = Symbols.attach_file_rounded;
  static const search = Symbols.search_rounded;
  static const listView = Symbols.view_agenda_rounded;
  static const gridView = Symbols.grid_view_rounded;
  static const timer = Symbols.timer_rounded;
  static const teachers = Symbols.groups_rounded;
  static const payments = Symbols.payments_rounded;
  static const chat = Symbols.chat_rounded;
  static const ok = Symbols.check_circle_rounded;
  static const error = Symbols.error_rounded;
  static const info = Symbols.info_rounded;
  static const undo = Symbols.undo_rounded;
  static const password = Symbols.key_rounded;
  static const code = Symbols.qr_code_scanner_rounded;
  static const faceId = Symbols.face_rounded;
  static const fingerprint = Symbols.fingerprint_rounded;
  static const language = Symbols.translate_rounded;
  static const theme = Symbols.dark_mode_rounded;
  static const logout = Symbols.logout_rounded;
  static const lock = Symbols.lock_rounded;
  static const clock = Symbols.schedule_rounded;
  static const pending = Symbols.hourglass_top_rounded;
  static const expand = Symbols.expand_more_rounded;
  static const back = Symbols.chevron_left_rounded;
  static const chevron = Symbols.chevron_right_rounded;
  static const close = Symbols.close_rounded;
  static const more = Symbols.more_horiz_rounded;
  static const check = Symbols.check_rounded;
  static const add = Symbols.add_rounded;
  static const flash = Symbols.flash_on_rounded;
  static const flashOff = Symbols.flash_off_rounded;
  static const show = Symbols.visibility_rounded;
  static const hide = Symbols.visibility_off_rounded;
  static const copy = Symbols.content_copy_rounded;
  static const school = Symbols.school_rounded;
  static const person = Symbols.person_rounded;
  static const forward = Symbols.arrow_forward_rounded;
  static const openInNew = Symbols.open_in_new_rounded;
  static const sort = Symbols.sort_rounded;
  static const refresh = Symbols.refresh_rounded;
  static const delete = Symbols.delete_rounded;
  static const camera = Symbols.photo_camera_rounded;
  static const image = Symbols.image_rounded;
  static const file = Symbols.description_rounded;
}

/// Icon with the variable-font axes the system asks for: weight 500 at 24 pt,
/// 600 at 16–20 pt, a lower grade in the dark theme.
class GIcon extends StatelessWidget {
  const GIcon(this.icon, {super.key, this.size = 24, this.color, this.fill = 0, this.semanticLabel});

  final IconData icon;
  final double size;
  final Color? color;
  final double fill;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Icon(
      icon,
      size: size,
      color: color,
      fill: fill,
      weight: size <= 20 ? 600 : 500,
      grade: dark ? -25 : 0,
      opticalSize: size.clamp(20, 48),
      semanticLabel: semanticLabel,
    );
  }
}
