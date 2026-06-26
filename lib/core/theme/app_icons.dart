import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

abstract final class AppIcons {
  // Navigation
  static const IconData back = Symbols.arrow_back_rounded;
  static const IconData dropdown = Symbols.arrow_drop_down_rounded;

  // App bars
  static const IconData library = Symbols.library_books_rounded;
  static const IconData settings = Symbols.settings_rounded;
  static const IconData refresh = Symbols.refresh_rounded;

  // Settings
  static const IconData folder = Symbols.folder_rounded;
  static const IconData add = Symbols.folder_managed_rounded;
  static const IconData themeSystem = Symbols.contrast_rounded;
  static const IconData themeLight = Symbols.light_mode_rounded;
  static const IconData themeDark = Symbols.dark_mode_rounded;
  static const IconData showRemainingTime = Symbols.sms_rounded;
  static const IconData showBufferedProgress = Symbols.hourglass_empty_rounded;
  static const IconData systemBackBehavior = Symbols.chevron_left_rounded;
  static const IconData enableNotificationSlider = Symbols.sliders_rounded;
  static const IconData language = Symbols.language_rounded;
  static const IconData creator = Symbols.person_rounded;
  static const IconData legal = Symbols.gavel_rounded;
  static const IconData legalDocument = Symbols.description_rounded;
  static const IconData appVersion = Symbols.mobile_friendly_rounded;

  // Player
  static const IconData sleepTimer = Symbols.timer_rounded;
  static const IconData playbackSpeed = Symbols.speed_rounded;
  static const IconData skipSilence = Symbols.graphic_eq_rounded;
  static const IconData playerLock = Symbols.lock_rounded;
  static const IconData skipPrevious = Symbols.skip_previous_rounded;
  static const IconData skipNext = Symbols.skip_next_rounded;
  static const IconData fastRewind = Symbols.fast_rewind_rounded;
  static const IconData fastForward = Symbols.fast_forward_rounded;
  static const IconData replay10 = Symbols.replay_10_rounded;
  static const IconData forward10 = Symbols.forward_10_rounded;
  static const IconData play = Symbols.play_arrow_rounded;
  static const IconData pause = Symbols.pause_rounded;
  static const IconData replay = Symbols.replay_rounded;
  static const IconData loading = Symbols.hourglass_empty_rounded;

  // Library
  static const IconData rename = Symbols.edit_rounded;
  static const IconData toggleReadStatusToLeft =
      Symbols.move_selection_left_rounded;
  static const IconData toggleReadStatusToRight =
      Symbols.move_selection_right_rounded;
  static const IconData fallbackBook = Symbols.menu_book_rounded;

  // Feedback
  static const IconData info = Symbols.info_rounded;
  static const IconData warning = Symbols.warning_rounded;
  static const IconData error = Symbols.error_rounded;
  static const IconData success = Symbols.check_circle_rounded;
}

abstract final class AppIconSizes {
  static const double small = 20;
  static const double medium = 24;
  static const double large = 28;
  static const double xLarge = 36;
  static const double hero = 48;
}
