import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterWidget extends StatelessWidget {
  final String? selectedValue;
  final List<String> options;
  final String hintText;
  final String labelText;
  final ValueChanged<String?> onChanged;
  final bool showClearButton;

  const FilterWidget({
    Key? key,
    required this.selectedValue,
    required this.options,
    required this.hintText,
    required this.labelText,
    required this.onChanged,
    this.showClearButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues( alpha: 0.5),
            ),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: selectedValue,
            hint: Text(
              hintText,
              overflow: TextOverflow.ellipsis,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              border: InputBorder.none,
              suffixIcon: showClearButton && selectedValue != null
                  ? IconButton(
                      icon: Icon(Icons.clear, size: 16.sp),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: 32.w,
                        minHeight: 32.h,
                      ),
                      onPressed: () => onChanged(null),
                    )
                  : null,
            ),
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onChanged,
            isExpanded: true,
          ),
        ),
      ],
    );
  }
}

class SearchBarWidget extends StatefulWidget {
  final String initialValue;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const SearchBarWidget({
    Key? key,
    required this.initialValue,
    required this.hintText,
    required this.onChanged,
    this.onClear,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the controller text if the initial value changed
    // and the user is not currently typing (controller text differs from current value)
    if (widget.initialValue != oldWidget.initialValue &&
        _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.outline.withValues( alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withValues( alpha: 0.6)),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, size: 20.sp),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                    widget.onClear?.call();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    );
  }
}

class FilterChipsWidget extends StatelessWidget {
  final String? designationFilter;
  final int? levelFilter;
  final VoidCallback onClearFilters;

  const FilterChipsWidget({
    Key? key,
    this.designationFilter,
    this.levelFilter,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFilters = designationFilter != null || levelFilter != null;

    if (!hasFilters) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Wrap(
        children: [
          Text(
            'Filters:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues( alpha: 0.7),
            ),
          ),
          SizedBox(width: 8.w),

          if (designationFilter != null) ...[
            _buildFilterChip(
              context,
              'Designation: $designationFilter',
              () {}, // Could add individual filter removal
            ),
            SizedBox(width: 8.w),
          ],

          if (levelFilter != null) ...[
            _buildFilterChip(
              context,
              'Level: $levelFilter',
              () {}, // Could add individual filter removal
            ),
            SizedBox(width: 8.w),
          ],

          TextButton.icon(
            onPressed: onClearFilters,
            icon: Icon(Icons.clear, size: 16.sp),
            label: Text(
              'Clear All',
              style: theme.textTheme.bodySmall,
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              minimumSize: Size.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, VoidCallback onRemove) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues( alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.colorScheme.primary.withValues( alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14.sp,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}