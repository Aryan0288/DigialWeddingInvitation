import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/invitation_model.dart';
import '../../../../data/models/remote_template_model.dart';
import '../../../widgets/common/app_text.dart';
import '../../../widgets/templates_widgets.dart';
import '../../../viewmodels/builder_viewmodel.dart';

// ── Category / description helpers ─────────────────────────────────────────

const Map<String, String> _collectionDescriptions = {
  'Royal':  'Classic Indian royalty — deep reds & rich gold accents',
  'Luxury': 'Opulent dark-toned with premium metallic detailing',
  'Floral': 'Romantic blooms with soft botanical elegance',
  'Modern': 'Clean contemporary design with refined simplicity',
};

String _getCollectionDescription(String collection) =>
    _collectionDescriptions[collection] ?? 'Elegant premium wedding design';

const Map<int, String> _collectionCategoryMap = {
  1: 'Royal', 2: 'Royal', 4: 'Royal', 5: 'Royal', 6: 'Royal',
  7: 'Luxury', 8: 'Luxury', 9: 'Luxury',
  3: 'Floral', 10: 'Floral', 11: 'Floral', 12: 'Floral',
};

String _getCollectionName(int id) =>
    _collectionCategoryMap[id] ?? 'Modern';

// ── Providers ───────────────────────────────────────────────────────────────

final builderTemplateCategoryProvider =
    StateProvider<String>((ref) => 'All');

final builderFilteredTemplatesProvider =
    Provider<List<RemoteTemplateModel>>((ref) {
  final templates =
      ref.watch(builderViewModelProvider.select((s) => s.availableTemplates));
  final category = ref.watch(builderTemplateCategoryProvider);
  if (category == 'All') return templates;
  return templates
      .where((t) => _getCollectionName(t.id) == category)
      .toList();
});

// Stub invitation used only for gallery previews
final _galleryStub = InvitationModel(
  id: 'gallery_stub',
  brideName: 'Priya',
  groomName: 'Aryan',
  weddingDate: DateTime(2026, 10, 18),
  weddingTime: '18:00',
  venueName: 'Grand Palace Hall',
  venueAddress: 'New Delhi, India',
  personalMessage: 'Together with our families, we joyfully invite you.',
  selectedTemplateId: 1,
);

/// Cached gallery preview widgets — built once per template list change.
final _builderGalleryCacheProvider =
    Provider<Map<int, Widget>>((ref) {
  final allTemplates =
      ref.watch(builderViewModelProvider.select((s) => s.availableTemplates));
  return {
    for (final t in allTemplates)
      t.id: RepaintBoundary(
        child: InvitationTemplateFactory.getTemplate(
          templateId: t.id,
          invitation: _galleryStub.copyWith(selectedTemplateId: t.id),
          isPreview: true,
          availableTemplates: allTemplates,
        ),
      ),
  };
});

// ── Section widget ──────────────────────────────────────────────────────────

class TemplateSelectorSection extends ConsumerWidget {
  const TemplateSelectorSection({super.key});

  static const List<String> _categories = [
    'All', 'Royal', 'Luxury', 'Floral', 'Modern'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates =
        ref.watch(builderViewModelProvider.select((s) => s.availableTemplates));
    final selectedId = ref.watch(
        builderViewModelProvider.select((s) => s.invitation.selectedTemplateId));
    final selectedCategory = ref.watch(builderTemplateCategoryProvider);
    final filteredTemplates = ref.watch(builderFilteredTemplatesProvider);
    final cachedPreviews = ref.watch(_builderGalleryCacheProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _StepSectionHeader(
          stepNum: '01',
          title: 'Choose Your Design',
          subtitle: 'Pick the perfect theme — previews update live',
        ),
        const SizedBox(height: 20),

        // Category filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((cat) {
              final isSel = cat == selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => ref
                      .read(builderTemplateCategoryProvider.notifier)
                      .state = cat,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.accent : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSel ? AppColors.accent : AppColors.border,
                      ),
                      boxShadow: isSel
                          ? [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.22),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      cat.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isSel ? Colors.white : AppColors.secondaryText,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Gallery or fallback
        if (templates.isEmpty)
          _FallbackTemplateList(selectedId: selectedId, ref: ref)
        else if (filteredTemplates.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off_outlined,
                      size: 40, color: AppColors.mutedText),
                  const SizedBox(height: 10),
                  AppBody(
                    'No templates in "$selectedCategory"',
                    color: AppColors.mutedText,
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              for (int i = 0; i < filteredTemplates.length; i++) ...[
                _TemplateListItem(
                  key: ValueKey(filteredTemplates[i].id),
                  id: filteredTemplates[i].id,
                  title: filteredTemplates[i].title,
                  collection: _getCollectionName(filteredTemplates[i].id),
                  isSelected: filteredTemplates[i].id == selectedId,
                  previewWidget:
                      cachedPreviews[filteredTemplates[i].id] ?? const SizedBox.shrink(),
                  onTap: () => ref
                      .read(builderViewModelProvider.notifier)
                      .selectTemplate(filteredTemplates[i].id),
                ),
                if (i < filteredTemplates.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
      ],
    );
  }
}

// ── List-style template row (thumbnail left, info right) ────────────────────

class _TemplateListItem extends StatefulWidget {
  final int id;
  final String title;
  final String collection;
  final bool isSelected;
  final Widget previewWidget;
  final VoidCallback onTap;

  const _TemplateListItem({
    super.key,
    required this.id,
    required this.title,
    required this.collection,
    required this.isSelected,
    required this.previewWidget,
    required this.onTap,
  });

  @override
  State<_TemplateListItem> createState() => _TemplateListItemState();
}

class _TemplateListItemState extends State<_TemplateListItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final collection = widget.collection;
    final description = _getCollectionDescription(collection);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.accent.withOpacity(0.05)
                : (_hovered ? const Color(0xFFFBF9F6) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected ? AppColors.accent : AppColors.border,
              width: widget.isSelected ? 1.5 : 1.0,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(_hovered ? 0.06 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Row(
            children: [
              // ── Left: thumbnail preview ──────────────────────────────
              SizedBox(
                width: 68,
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 360,
                        height: 640,
                        child: widget.previewWidget,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // ── Right: collection badge + title + description ─────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Collection badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? AppColors.accent.withOpacity(0.10)
                            : const Color(0xFFF5EFE6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        collection.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: widget.isSelected
                              ? AppColors.accent
                              : AppColors.secondaryText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    // Title
                    AppText(
                      widget.title,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: widget.isSelected
                          ? AppColors.accent
                          : AppColors.primaryText,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    // Description
                    AppBody(
                      description,
                      fontSize: 11,
                      color: AppColors.secondaryText,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // ── Right: selected indicator ────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected ? AppColors.accent : Colors.transparent,
                  border: Border.all(
                    color: widget.isSelected ? AppColors.accent : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: widget.isSelected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 13)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Fallback list when no API templates available ───────────────────────────

class _FallbackTemplateList extends StatelessWidget {
  final int selectedId;
  final WidgetRef ref;

  const _FallbackTemplateList({required this.selectedId, required this.ref});

  static const _fallback = [
    (id: 1, title: 'Classic Mandala', collection: 'Royal',
      primary: Color(0xFF5B0000), secondary: Color(0xFFD4AF37)),
    (id: 2, title: 'Royal Peacock', collection: 'Royal',
      primary: Color(0xFF380208), secondary: Color(0xFFD4AF37)),
    (id: 3, title: 'Rose Gold Floral', collection: 'Floral',
      primary: Color(0xFFFFF0F2), secondary: Color(0xFF4A3437)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _fallback.map((item) {
        final isSelected = item.id == selectedId;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => ref
                .read(builderViewModelProvider.notifier)
                .selectTemplate(item.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withOpacity(0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [
                        const BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
              ),
              child: Row(
                children: [
                  // Color swatch
                  Container(
                    width: 48,
                    height: 68,
                    decoration: BoxDecoration(
                      color: item.primary,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: item.secondary.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.favorite,
                          color: item.secondary, size: 14),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent.withOpacity(0.10)
                                : const Color(0xFFF5EFE6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.collection.toUpperCase(),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.secondaryText,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        AppText(
                          item.title,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.primaryText,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.accent
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 13)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Shared step section header ──────────────────────────────────────────────

class _StepSectionHeader extends StatelessWidget {
  final String stepNum;
  final String title;
  final String subtitle;

  const _StepSectionHeader({
    required this.stepNum,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'STEP $stepNum',
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AppTitle(
          title,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        const SizedBox(height: 4),
        AppBody(subtitle, color: AppColors.secondaryText, fontSize: 11),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 1.5,
          decoration: BoxDecoration(
            color: AppColors.accentGold.withOpacity(0.55),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}
