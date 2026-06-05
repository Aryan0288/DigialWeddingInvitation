import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/common/app_text.dart';
import '../../../widgets/templates_widgets.dart';
import '../../../viewmodels/builder_viewmodel.dart';

class TemplateSelectorSection extends ConsumerStatefulWidget {
  const TemplateSelectorSection({super.key});

  @override
  ConsumerState<TemplateSelectorSection> createState() => _TemplateSelectorSectionState();
}

class _TemplateSelectorSectionState extends ConsumerState<TemplateSelectorSection> {
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Royal', 'Luxury', 'Floral', 'Modern'];

  String _getCollectionName(int id) {
    if ([1, 2, 4, 5, 6].contains(id)) return 'Royal';
    if ([7, 8, 9].contains(id)) return 'Luxury';
    if ([3, 10, 11, 12].contains(id)) return 'Floral';
    return 'Modern';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(builderViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Filter templates
    final templates = state.availableTemplates;
    final filteredTemplates = _selectedCategory == 'All'
        ? templates
        : templates.where((t) => _getCollectionName(t.id) == _selectedCategory).toList();

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
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: AppText(
                    category,
                    color: isSelected 
                        ? Colors.white 
                        : (isLight ? AppColors.secondaryText : Colors.white70),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
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
          _buildTemplateItem(
            id: 1,
            title: "Classic Mandala (Gold & Red)",
            desc: "Rich dark royal red with golden concentric patterns and luxury Sanskrit headers.",
            selectedId: state.invitation.selectedTemplateId,
            primaryColor: const Color(0xFF5B0000),
            secondaryColor: const Color(0xFFD4AF37),
            isLight: isLight,
          ),
          const SizedBox(height: 16),
          _buildTemplateItem(
            id: 2,
            title: "Royal Peacock (Maroon & Teal)",
            desc: "Elegant deep maroon backdrop complemented by teal peacock elements and gold frames.",
            selectedId: state.invitation.selectedTemplateId,
            primaryColor: const Color(0xFF380208),
            secondaryColor: const Color(0xFFD4AF37),
            isLight: isLight,
          ),
          const SizedBox(height: 16),
          _buildTemplateItem(
            id: 3,
            title: "Rose Gold (Minimalist Floral)",
            desc: "Beautiful blush rose gold shimmers bordered with detailed thin floral leafy branches.",
            selectedId: state.invitation.selectedTemplateId,
            primaryColor: const Color(0xFFFFF0F2),
            secondaryColor: const Color(0xFF4A3437),
            isLight: isLight,
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
                      'No templates found in "$_selectedCategory" collection',
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
                child: _buildTemplateItem(
                  id: t.id,
                  title: t.title,
                  desc: t.description,
                  selectedId: state.invitation.selectedTemplateId,
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                  isLight: isLight,
                ),
              );
            }).toList(),
        ],
      ],
    );
  }

  Widget _buildTemplateItem({
    required int id,
    required String title,
    required String desc,
    required int selectedId,
    required Color primaryColor,
    required Color secondaryColor,
    required bool isLight,
  }) {
    final isSelected = id == selectedId;
    final collection = _getCollectionName(id);

    return InkWell(
      onTap: () {
        ref.read(builderViewModelProvider.notifier).selectTemplate(id);
      },
      borderRadius: AppDesign.borderMedium,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isLight
              ? (isSelected ? AppColors.accent.withOpacity(0.06) : Colors.white)
              : const Color(0xFF1E2638).withOpacity(isSelected ? 0.95 : 0.6),
          borderRadius: AppDesign.borderMedium,
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : (isLight ? AppColors.border : Colors.white.withOpacity(0.04)),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected ? AppDesign.glowShadow(AppColors.accent) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                ),
                border: Border.all(color: Colors.white24, width: 0.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: secondaryColor,
                      border: Border.all(color: Colors.black26, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          title,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? AppColors.accent 
                              : (isLight ? AppColors.primaryText : Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isLight 
                              ? AppColors.accent.withOpacity(0.08) 
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: AppText(
                          collection.toUpperCase(),
                          color: isSelected 
                              ? AppColors.accent 
                              : (isLight ? AppColors.secondaryText : Colors.white38),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppBody(
                    desc,
                    color: isLight ? AppColors.mutedText : Colors.white54,
                    fontSize: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected 
                  ? AppColors.accent 
                  : (isLight ? AppColors.border : Colors.white24),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
