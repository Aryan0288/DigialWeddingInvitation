import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/common/app_text.dart';
import '../../../widgets/templates_widgets.dart';
import '../../../viewmodels/builder_viewmodel.dart';
import '../../../../data/models/remote_template_model.dart';

const Map<int, String> _collectionCategoryMap = {
  1: 'Royal',
  2: 'Royal',
  4: 'Royal',
  5: 'Royal',
  6: 'Royal',
  7: 'Luxury',
  8: 'Luxury',
  9: 'Luxury',
  3: 'Floral',
  10: 'Floral',
  11: 'Floral',
  12: 'Floral',
};

String _getCollectionName(int id) {
  return _collectionCategoryMap[id] ?? 'Modern';
}

final builderTemplateCategoryProvider = StateProvider.autoDispose<String>((ref) => 'All');

final builderFilteredTemplatesProvider = Provider.autoDispose<List<RemoteTemplateModel>>((ref) {
  final templates = ref.watch(builderViewModelProvider.select((s) => s.availableTemplates));
  final category = ref.watch(builderTemplateCategoryProvider);
  if (category == 'All') return templates;
  return templates.where((t) {
    return _getCollectionName(t.id) == category;
  }).toList();
});

class TemplateSelectorSection extends ConsumerWidget {
  const TemplateSelectorSection({super.key});

  static const List<String> _categories = ['All', 'Royal', 'Luxury', 'Floral', 'Modern'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(builderViewModelProvider.select((s) => s.availableTemplates));
    final selectedTemplateId = ref.watch(builderViewModelProvider.select((s) => s.invitation.selectedTemplateId));
    final selectedCategory = ref.watch(builderTemplateCategoryProvider);
    final filteredTemplates = ref.watch(builderFilteredTemplatesProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTitle(
          'Step 1: Select Design Template',
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: isLight ? AppColors.primaryText : Colors.white,
        ),
        const SizedBox(height: 8),
        AppBody(
          'Choose the premium theme style for your digital wedding card. You can toggle this dynamically at any time.',
          color: isLight ? AppColors.secondaryText : Colors.white54,
          fontSize: 12,
        ),
        const SizedBox(height: 24),
        
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((category) {
              final isSelected = selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: AppText(
                    category.toUpperCase(),
                    color: isSelected 
                        ? Colors.white 
                        : (isLight ? AppColors.secondaryText : Colors.white70),
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(builderTemplateCategoryProvider.notifier).state = category;
                    }
                  },
                  selectedColor: AppColors.accent,
                  backgroundColor: isLight ? Colors.white : const Color(0xFF1E2638),
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected 
                        ? AppColors.accent 
                        : (isLight ? AppColors.border : Colors.white12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        if (templates.isEmpty) ...[
          // Fallback static templates when API list is empty
          TemplateItemCard(
            id: 1,
            title: "Classic Mandala (Gold & Red)",
            desc: "Rich dark royal red with golden concentric patterns and luxury Sanskrit headers.",
            isSelected: selectedTemplateId == 1,
            primaryColor: const Color(0xFF5B0000),
            secondaryColor: const Color(0xFFD4AF37),
            isLight: isLight,
            onTap: () => ref.read(builderViewModelProvider.notifier).selectTemplate(1),
          ),
          const SizedBox(height: 16),
          TemplateItemCard(
            id: 2,
            title: "Royal Peacock (Maroon & Teal)",
            desc: "Elegant deep maroon backdrop complemented by teal peacock elements and gold frames.",
            isSelected: selectedTemplateId == 2,
            primaryColor: const Color(0xFF380208),
            secondaryColor: const Color(0xFFD4AF37),
            isLight: isLight,
            onTap: () => ref.read(builderViewModelProvider.notifier).selectTemplate(2),
          ),
          const SizedBox(height: 16),
          TemplateItemCard(
            id: 3,
            title: "Rose Gold (Minimalist Floral)",
            desc: "Beautiful blush rose gold shimmers bordered with detailed thin floral leafy branches.",
            isSelected: selectedTemplateId == 3,
            primaryColor: const Color(0xFFFFF0F2),
            secondaryColor: const Color(0xFF4A3437),
            isLight: isLight,
            onTap: () => ref.read(builderViewModelProvider.notifier).selectTemplate(3),
          ),
        ] else ...[
          if (filteredTemplates.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_outlined,
                      size: 48,
                      color: isLight ? AppColors.mutedText : Colors.white38,
                    ),
                    const SizedBox(height: 12),
                    AppBody(
                      'No templates found in "$selectedCategory" collection',
                      color: isLight ? AppColors.mutedText : Colors.white38,
                    ),
                  ],
                ),
              ),
            )
          else
            ...filteredTemplates.map((t) {
              final primaryColor = HexColor.fromHex(t.primaryColorHex);
              final secondaryColor = HexColor.fromHex(t.secondaryColorHex);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TemplateItemCard(
                  id: t.id,
                  title: t.title,
                  desc: t.description,
                  isSelected: t.id == selectedTemplateId,
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                  isLight: isLight,
                  onTap: () => ref.read(builderViewModelProvider.notifier).selectTemplate(t.id),
                ),
              );
            }).toList(),
        ],
      ],
    );
  }
}

class TemplateItemCard extends StatelessWidget {
  final int id;
  final String title;
  final String desc;
  final bool isSelected;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isLight;
  final VoidCallback onTap;

  const TemplateItemCard({
    super.key,
    required this.id,
    required this.title,
    required this.desc,
    required this.isSelected,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isLight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final collection = _getCollectionName(id);
    final Color cardBgColor = isLight
        ? (isSelected ? const Color(0xFFFAF5EC) : Colors.white)
        : const Color(0xFF1E2638).withValues(alpha: isSelected ? 0.95 : 0.6);
    
    final Color cardBorderColor = isSelected
        ? AppColors.accent
        : (isLight ? AppColors.border : const Color(0x0AFFFFFF));

    final Color badgeBgColor = isSelected 
        ? AppColors.accent.withValues(alpha: 0.12)
        : (isLight ? const Color(0xFFF5EFE6) : const Color(0x0DFFFFFF));

    return InkWell(
      onTap: onTap,
      borderRadius: AppDesign.borderMedium,
      child: AnimatedContainer(
        duration: AppDesign.durationFast,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: AppDesign.borderMedium,
          border: Border.all(
            color: cardBorderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected ? AppDesign.glowShadow(AppColors.accent) : AppDesign.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Miniature 9:16 Card Thumbnail Mockup
            Container(
              width: 70,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: primaryColor,
                border: Border.all(
                  color: isSelected ? AppColors.accent : const Color(0x33FFFFFF),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Gold thin inner border
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: secondaryColor.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  // Abstract card pattern indicator
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: secondaryColor.withValues(alpha: 0.15),
                      border: Border.all(
                        color: secondaryColor.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.favorite,
                        color: secondaryColor,
                        size: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeBgColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: AppText(
                          collection.toUpperCase(),
                          color: isSelected 
                              ? AppColors.accent 
                              : (isLight ? AppColors.secondaryText : Colors.white38),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    title,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected 
                        ? AppColors.accent 
                        : (isLight ? AppColors.primaryText : Colors.white),
                  ),
                  const SizedBox(height: 6),
                  AppBody(
                    desc,
                    color: isLight ? AppColors.secondaryText : Colors.white54,
                    fontSize: 11,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Radio Button / Active Check Circle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.accent : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.accent : (isLight ? AppColors.border : Colors.white30),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
