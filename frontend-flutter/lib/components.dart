import 'package:flutter/material.dart';

/// Shared alumni "Availability" options, used by both the Add Member dialog
/// and the edit alumni form.
const availabilityOptions = ['In-person', 'Online', 'Unavailable'];

/// Shared alumni "Area of Expertise" options, used by both the Add Member
/// dialog and the edit alumni form.
const expertiseOptions = [
  'AI & ML',
  'Cloud Computing',
  'Cyber Security',
  'Data Science',
  'Web Development',
  'Mobile Development',
  'Blockchain',
  'DevOps',
  'Networking',
  'Internet of Things',
];

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final TextAlign textAlign;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomTextFormField({
    super.key,
    required this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.labelStyle,
    this.textStyle,
    this.fillColor,
    this.borderColor,
    this.borderRadius = 12,
    this.contentPadding,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines,
    this.textAlign = TextAlign.start,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLabelStyle = labelStyle ??
        Theme.of(context).textTheme.labelMedium?.copyWith(
              fontFamily: 'Outfit',
              letterSpacing: 0.0,
            );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: obscureText ? 1 : maxLines ?? 1,
      textAlign: textAlign,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: effectiveLabelStyle,
        hintStyle: effectiveLabelStyle,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor ?? Theme.of(context).dividerColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        filled: true,
        fillColor: fillColor ?? Theme.of(context).colorScheme.surface,
        contentPadding: contentPadding,
      ),
      style: textStyle ??
          Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'Plus Jakarta Sans',
                letterSpacing: 0.0,
              ),
    );
  }
}

/// Shows a themed [SnackBar]. Use [isError] for destructive/failure messages
/// and [isSuccess] for confirmations; omit both for a neutral message.
class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red
            : isSuccess
                ? Colors.green
                : null,
      ),
    );
  }
}

/// A container with the card styling (background, shadow, rounded corners)
/// shared by list items and small info cards throughout the app.
class AppCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final Color? color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.color,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.secondary,
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x32000000),
            offset: Offset(0.0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Renders a loading indicator, an empty-state message, or the list built
/// from [items] via [itemBuilder] — the pattern repeated by every list of
/// async data in the app.
class AsyncListView<T> extends StatelessWidget {
  final bool isLoading;
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String emptyText;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;

  const AsyncListView({
    super.key,
    required this.isLoading,
    required this.items,
    required this.itemBuilder,
    this.emptyText = 'Nothing found',
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
        ),
      );
    }

    return ListView.builder(
      padding: padding,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: items.length,
      itemBuilder: (context, index) => itemBuilder(context, items[index]),
    );
  }
}

/// A read-only [CustomTextFormField] that opens a date picker on tap.
class DatePickerFormField extends StatelessWidget {
  final DateTime selectedDate;
  final String labelText;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String Function(DateTime date)? formatDate;

  const DatePickerFormField({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.labelText = 'Date',
    this.firstDate,
    this.lastDate,
    this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final text = formatDate != null
        ? formatDate!(selectedDate)
        : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';

    return CustomTextFormField(
      controller: TextEditingController(text: text),
      labelText: labelText,
      readOnly: true,
      suffixIcon: const Icon(Icons.calendar_today),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: firstDate ?? DateTime.now(),
          lastDate: lastDate ?? DateTime(2100, 12, 31),
        );
        if (picked != null && picked != selectedDate) {
          onDateSelected(picked);
        }
      },
    );
  }
}

/// A read-only [CustomTextFormField] that opens a time picker on tap.
class TimePickerFormField extends StatelessWidget {
  final TimeOfDay selectedTime;
  final String labelText;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const TimePickerFormField({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected,
    this.labelText = 'Time',
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: TextEditingController(text: selectedTime.format(context)),
      labelText: labelText,
      readOnly: true,
      suffixIcon: const Icon(Icons.access_time),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: selectedTime,
        );
        if (picked != null && picked != selectedTime) {
          onTimeSelected(picked);
        }
      },
    );
  }
}

/// A [DropdownButtonFormField] with the app's shared field styling.
class AppDropdownFormField<T> extends StatelessWidget {
  final T? value;
  final String labelText;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final Color? fillColor;
  final Color? borderColor;

  const AppDropdownFormField({
    super.key,
    required this.value,
    required this.labelText,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.fillColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderSide: borderColor == null
              ? const BorderSide()
              : BorderSide(color: borderColor!, width: 2),
        ),
        filled: fillColor != null,
        fillColor: fillColor,
      ),
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

/// A labeled [Wrap] of toggleable [FilterChip]s for selecting zero or more
/// values from a fixed option list (e.g. "Area of Expertise").
class AppMultiSelectChips extends StatelessWidget {
  final String labelText;
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const AppMultiSelectChips({
    super.key,
    required this.labelText,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (value) {
                final updated = List<String>.from(selected);
                if (value) {
                  updated.add(option);
                } else {
                  updated.remove(option);
                }
                onChanged(updated);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// A themed [AlertDialog] wrapper for "enter some fields, then submit"
/// forms, matching the dialogs used for adding alumni/events.
class FormDialog extends StatelessWidget {
  final String title;
  final List<Widget> fields;
  final VoidCallback onSubmit;
  final String submitText;
  final double fieldSpacing;

  const FormDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.onSubmit,
    this.submitText = 'Add',
    this.fieldSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < fields.length; i++) ...[
              if (i > 0) SizedBox(height: fieldSpacing),
              fields[i],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onSubmit,
          child: Text(submitText),
        ),
      ],
    );
  }
}

/// An icon button that opens a [showMenu] popup built from [items].
class OverflowMenuButton extends StatelessWidget {
  final Widget icon;
  final List<OverflowMenuItem> items;
  final RelativeRect Function(BuildContext context)? positionBuilder;

  const OverflowMenuButton({
    super.key,
    required this.icon,
    required this.items,
    this.positionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      onPressed: () {
        final position =
            positionBuilder?.call(context) ?? RelativeRect.fromLTRB(0, 0, 100, 100);
        showMenu(
          context: context,
          position: position,
          items: items
              .map(
                (item) => PopupMenuItem(
                  child: ListTile(
                    leading: Icon(item.icon),
                    title: Text(item.label),
                    onTap: () {
                      Navigator.pop(context);
                      item.onTap();
                    },
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

/// A rounded, drop-shadowed icon button — used for floating back/action
/// buttons that sit on top of page content (e.g. a profile header).
class ShadowIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final double borderRadius;

  const ShadowIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 40,
    this.iconSize = 20,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x520E151B),
            offset: Offset(0.0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurface,
          size: iconSize,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class OverflowMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const OverflowMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

