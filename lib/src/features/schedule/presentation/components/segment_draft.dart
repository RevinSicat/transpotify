import 'package:flutter/material.dart';

class SegmentDraft {
    final String mode;
    final TextEditingController nameController;
    final TextEditingController durationController;

    SegmentDraft(this.mode)
        : nameController = TextEditingController(text: mode),
          durationController = TextEditingController();

    void dispose() {
        nameController.dispose();
        durationController.dispose();
    }
}
