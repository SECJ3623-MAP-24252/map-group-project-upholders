import 'package:flutter/material.dart';
import 'emoji_options.dart';

Map<String, dynamic> mapEmotionToEmojiOption(String emotion) {
  switch (emotion.toLowerCase()) {
    case "happy":
      return emojiOptions[0];
    case "surprised":
      return emojiOptions[1];
    case "neutral":
      return emojiOptions[2];
    case "sad":
      return emojiOptions[3];
    case "angry":
      return emojiOptions[4];
    default:
      return emojiOptions[2];
  }
}
