import 'package:flutter/material.dart';
import '../../../data/models/invitation_model.dart';
import '../../../data/models/remote_template_model.dart';
import 'template_ui_model.dart';
import 'dynamic_template.dart';
import 'hardcoded/gold_red_mandala.dart';
import 'hardcoded/maroon_peacock.dart';
import 'hardcoded/rose_gold_floral.dart';
import 'hardcoded/mughal_vintage_arch.dart';
import 'hardcoded/lotus_mandap.dart';
import 'hardcoded/regal_maroon_arch.dart';
import 'hardcoded/dark_floral_elegance.dart';

class InvitationTemplateFactory {
  static Widget getTemplate({
    required int templateId,
    required InvitationModel invitation,
    bool isPreview = true,
    List<RemoteTemplateModel> availableTemplates = const [],
  }) {
    // Build the precomputed UI model once
    final uiModel = TemplateUIModel.build(invitation, templateId, availableTemplates);

    // IDs 1–7 are static hardcoded widgets; 8+ are remote dynamic templates
    if (templateId > 7 && availableTemplates.any((t) => t.id == templateId)) {
      return DynamicTemplateWidget(
        uiModel: uiModel,
        isPreview: isPreview,
      );
    }

    switch (templateId) {
      case 1:
        return GoldRedMandalaTemplate(uiModel: uiModel, isPreview: isPreview);
      case 2:
        return MaroonPeacockTemplate(uiModel: uiModel, isPreview: isPreview);
      case 3:
        return RoseGoldFloralTemplate(uiModel: uiModel, isPreview: isPreview);
      case 4:
        return MughalVintageArchTemplate(uiModel: uiModel, isPreview: isPreview);
      case 5:
        return LotusMandapSaveTheDateTemplate(uiModel: uiModel, isPreview: isPreview);
      case 6:
        return RegalMaroonSideArchTemplate(uiModel: uiModel, isPreview: isPreview);
      case 7:
        return DarkFloralEleganceTemplate(uiModel: uiModel, isPreview: isPreview);
      default:
        if (availableTemplates.any((t) => t.id == templateId)) {
          return DynamicTemplateWidget(
            uiModel: uiModel,
            isPreview: isPreview,
          );
        }
        return GoldRedMandalaTemplate(uiModel: uiModel, isPreview: isPreview);
    }
  }
}
