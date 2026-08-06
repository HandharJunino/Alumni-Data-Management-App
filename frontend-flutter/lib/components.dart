import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  const AppDropdownFormField({
    super.key,
    required this.value,
    required this.labelText,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
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

// FFButton widget
class FFButtonOptions {
  const FFButtonOptions({
    this.textAlign,
    this.textStyle,
    this.elevation,
    this.height,
    this.width,
    this.padding,
    this.color,
    this.disabledColor,
    this.disabledTextColor,
    this.splashColor,
    this.iconSize,
    this.iconColor,
    this.iconPadding,
    this.borderRadius,
    this.borderSide,
    this.hoverColor,
    this.hoverBorderSide,
    this.hoverTextColor,
    this.hoverElevation,
    this.maxLines,
  });

  /// The alignment of the button's text within its bounds.
  final TextAlign? textAlign;

  /// The style of the button's text.
  final TextStyle? textStyle;

  /// The elevation of the button.
  final double? elevation;

  /// The height of the button.
  final double? height;

  /// The width of the button.
  final double? width;

  /// The padding around the button's content.
  final EdgeInsetsGeometry? padding;

  /// The background color of the button.
  final Color? color;

  /// The background color of the button when it is disabled.
  final Color? disabledColor;

  /// The text color of the button when it is disabled.
  final Color? disabledTextColor;

  /// The maximum number of lines for the button's text.
  final int? maxLines;

  /// The color of the splash effect when the button is pressed.
  final Color? splashColor;

  /// The size of the button's icon.
  final double? iconSize;

  /// The color of the button's icon.
  final Color? iconColor;

  /// The padding around the button's icon.
  final EdgeInsetsGeometry? iconPadding;

  /// The border radius of the button.
  final BorderRadius? borderRadius;

  /// The border of the button.
  final BorderSide? borderSide;

  /// The background color of the button when it is hovered.
  final Color? hoverColor;

  /// The border of the button when it is hovered.
  final BorderSide? hoverBorderSide;

  /// The text color of the button when it is hovered.
  final Color? hoverTextColor;

  /// The elevation of the button when it is hovered.
  final double? hoverElevation;
}

/// A customizable button widget that can display text, an icon, and a loading indicator.
class FFButtonWidget extends StatefulWidget {
  /// Creates a [FFButtonWidget].
  ///
  /// - [text] parameter is required and specifies the text to be displayed on the button.
  /// - [onPressed] parameter is a callback function that will be called when the button is pressed.
  /// - [icon] parameter is an optional widget that can be used to display an icon alongside the text.
  /// - [iconData] parameter is an optional icon data that can be used to display an icon alongside the text.
  /// - [options] parameter is required and specifies the visual options for the button.
  /// - [showLoadingIndicator] parameter is an optional boolean value that determines whether to show a loading indicator when the button is pressed.
  const FFButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconData,
    required this.options,
    this.showLoadingIndicator = true,
  });

  final String text;
  final Widget? icon;
  final IconData? iconData;
  final Function()? onPressed;
  final FFButtonOptions options;
  final bool showLoadingIndicator;

  @override
  State<FFButtonWidget> createState() => _FFButtonWidgetState();
}

class _FFButtonWidgetState extends State<FFButtonWidget> {
  bool loading = false;

  int get maxLines => widget.options.maxLines ?? 1;

  String? get text =>
      widget.options.textStyle?.fontSize == 0 ? null : widget.text;

  @override
  Widget build(BuildContext context) {
    Widget textWidget = loading
        ? SizedBox(
      width: widget.options.width == null
          ? _getTextWidth(text, widget.options.textStyle, maxLines)
          : null,
      child: Center(
        child: SizedBox(
          width: 23,
          height: 23,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.options.textStyle?.color ?? Colors.white,
            ),
          ),
        ),
      ),
    )
        : AutoSizeText(
      text ?? '',
      style:
      text == null ? null : widget.options.textStyle?.withoutColor(),
      textAlign: widget.options.textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );

    final onPressed = widget.onPressed != null
        ? (widget.showLoadingIndicator
        ? () async {
      if (loading) {
        return;
      }
      setState(() => loading = true);
      try {
        await widget.onPressed!();
      } finally {
        if (mounted) {
          setState(() => loading = false);
        }
      }
    }
        : () => widget.onPressed!())
        : null;

    ButtonStyle style = ButtonStyle(
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>(
            (states) {
          if (states.contains(WidgetState.hovered) &&
              widget.options.hoverBorderSide != null) {
            return RoundedRectangleBorder(
              borderRadius:
              widget.options.borderRadius ?? BorderRadius.circular(8),
              side: widget.options.hoverBorderSide!,
            );
          }
          return RoundedRectangleBorder(
            borderRadius:
            widget.options.borderRadius ?? BorderRadius.circular(8),
            side: widget.options.borderSide ?? BorderSide.none,
          );
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
          if (states.contains(WidgetState.disabled) &&
              widget.options.disabledTextColor != null) {
            return widget.options.disabledTextColor;
          }
          if (states.contains(WidgetState.hovered) &&
              widget.options.hoverTextColor != null) {
            return widget.options.hoverTextColor;
          }
          return widget.options.textStyle?.color ?? Colors.white;
        },
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
          if (states.contains(WidgetState.disabled) &&
              widget.options.disabledColor != null) {
            return widget.options.disabledColor;
          }
          if (states.contains(WidgetState.hovered) &&
              widget.options.hoverColor != null) {
            return widget.options.hoverColor;
          }
          return widget.options.color;
        },
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return widget.options.splashColor;
        }
        return widget.options.hoverColor == null ? null : Colors.transparent;
      }),
      padding: WidgetStateProperty.all(widget.options.padding ??
          const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0)),
      elevation: WidgetStateProperty.resolveWith<double?>(
            (states) {
          if (states.contains(WidgetState.hovered) &&
              widget.options.hoverElevation != null) {
            return widget.options.hoverElevation!;
          }
          return widget.options.elevation ?? 2.0;
        },
      ),
    );

    if ((widget.icon != null || widget.iconData != null) && !loading) {
      Widget icon = widget.icon ??
          FaIcon(
            widget.iconData!,
            size: widget.options.iconSize,
            color: widget.options.iconColor,
          );

      if (text == null) {
        return Container(
          height: widget.options.height,
          width: widget.options.width,
          decoration: BoxDecoration(
            border: Border.fromBorderSide(
              widget.options.borderSide ?? BorderSide.none,
            ),
            borderRadius:
            widget.options.borderRadius ?? BorderRadius.circular(8),
          ),
          child: IconButton(
            splashRadius: 1.0,
            icon: Padding(
              padding: widget.options.iconPadding ?? EdgeInsets.zero,
              child: icon,
            ),
            onPressed: onPressed,
            style: style,
          ),
        );
      }
      return SizedBox(
        height: widget.options.height,
        width: widget.options.width,
        child: ElevatedButton.icon(
          icon: Padding(
            padding: widget.options.iconPadding ?? EdgeInsets.zero,
            child: icon,
          ),
          label: textWidget,
          onPressed: onPressed,
          style: style,
        ),
      );
    }

    return SizedBox(
      height: widget.options.height,
      width: widget.options.width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: textWidget,
      ),
    );
  }
}

/// Extension on [TextStyle] to create a new [TextStyle] without the color property.
/// This extension method returns a new [TextStyle] object with all properties of the original [TextStyle] except for the color property, which is set to null.
///
/// Example usage:
/// ```dart
/// TextStyle myTextStyle = TextStyle(color: Colors.red, fontSize: 16);
/// TextStyle newTextStyle = myTextStyle.withoutColor();
/// ```
extension _WithoutColorExtension on TextStyle {
  /// Returns a new [TextStyle] object without the color property.
  TextStyle withoutColor() => TextStyle(
    inherit: inherit,
    color: null,
    backgroundColor: backgroundColor,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
    textBaseline: textBaseline,
    height: height,
    leadingDistribution: leadingDistribution,
    locale: locale,
    foreground: foreground,
    background: background,
    shadows: shadows,
    fontFeatures: fontFeatures,
    decoration: decoration,
    decorationColor: decorationColor,
    decorationStyle: decorationStyle,
    decorationThickness: decorationThickness,
    debugLabel: debugLabel,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    overflow: overflow,
  );
}

// Slightly hacky method of getting the layout width of the provided text.
double? _getTextWidth(String? text, TextStyle? style, int maxLines) =>
    text != null
        ? (TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    )..layout())
        .size
        .width
        : null;

// icon button widget
/// A customizable icon button widget.
class FlutterFlowIconButton extends StatefulWidget {
  /// Creates a [FlutterFlowIconButton].
  ///
  /// - [icon] parameter is required and specifies the widget to be used as the icon.
  /// - [borderRadius] parameter specifies the border radius of the button.
  /// - [buttonSize] parameter specifies the size of the button.
  /// - [fillColor] parameter specifies the fill color of the button.
  /// - [disabledColor] parameter specifies the color of the button when it is disabled.
  /// - [disabledIconColor] parameter specifies the color of the icon when the button is disabled.
  /// - [hoverColor] parameter specifies the color of the button when it is hovered.
  /// - [hoverIconColor] parameter specifies the color of the icon when the button is hovered.
  /// - [borderColor] parameter specifies the border color of the button.
  /// - [borderWidth] parameter specifies the width of the button's border.
  /// - [showLoadingIndicator] parameter specifies whether to show a loading indicator on the button.
  /// - [onPressed] parameter specifies the callback function to be called when the button is pressed.
  const FlutterFlowIconButton({
    super.key,
    required this.icon,
    this.borderColor,
    this.borderRadius,
    this.borderWidth,
    this.buttonSize,
    this.fillColor,
    this.disabledColor,
    this.disabledIconColor,
    this.hoverColor,
    this.hoverIconColor,
    this.onPressed,
    this.showLoadingIndicator = false,
  });

  final Widget icon;
  final double? borderRadius;
  final double? buttonSize;
  final Color? fillColor;
  final Color? disabledColor;
  final Color? disabledIconColor;
  final Color? hoverColor;
  final Color? hoverIconColor;
  final Color? borderColor;
  final double? borderWidth;
  final bool showLoadingIndicator;
  final Function()? onPressed;

  @override
  State<FlutterFlowIconButton> createState() => _FlutterFlowIconButtonState();
}

class _FlutterFlowIconButtonState extends State<FlutterFlowIconButton> {
  bool loading = false;
  late double? iconSize;
  late Color? iconColor;
  late Widget effectiveIcon;

  @override
  void initState() {
    super.initState();
    _updateIcon();
  }

  @override
  void didUpdateWidget(FlutterFlowIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateIcon();
  }

  void _updateIcon() {
    final isFontAwesome = widget.icon is FaIcon;
    if (isFontAwesome) {
      FaIcon icon = widget.icon as FaIcon;
      effectiveIcon = FaIcon(
        icon.icon,
        size: icon.size,
      );
      iconSize = icon.size;
      iconColor = icon.color;
    } else {
      Icon icon = widget.icon as Icon;
      effectiveIcon = Icon(
        icon.icon,
        size: icon.size,
      );
      iconSize = icon.size;
      iconColor = icon.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle style = ButtonStyle(
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>(
            (states) {
          return RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
            side: BorderSide(
              color: widget.borderColor ?? Colors.transparent,
              width: widget.borderWidth ?? 0,
            ),
          );
        },
      ),
      iconColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
          if (states.contains(WidgetState.disabled) &&
              widget.disabledIconColor != null) {
            return widget.disabledIconColor;
          }
          if (states.contains(WidgetState.hovered) &&
              widget.hoverIconColor != null) {
            return widget.hoverIconColor;
          }
          return iconColor;
        },
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
          if (states.contains(WidgetState.disabled) &&
              widget.disabledColor != null) {
            return widget.disabledColor;
          }
          if (states.contains(WidgetState.hovered) &&
              widget.hoverColor != null) {
            return widget.hoverColor;
          }

          return widget.fillColor;
        },
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return null;
        }
        return widget.hoverColor == null ? null : Colors.transparent;
      }),
    );

    return SizedBox(
      width: widget.buttonSize,
      height: widget.buttonSize,
      child: Theme(
        data: ThemeData.from(
          colorScheme: Theme.of(context).colorScheme,
          useMaterial3: true,
        ),
        child: IgnorePointer(
          ignoring: widget.showLoadingIndicator && loading,
          child: IconButton(
            icon: (widget.showLoadingIndicator && loading)
                ? SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  iconColor ?? Colors.white,
                ),
              ),
            )
                : effectiveIcon,
            onPressed: widget.onPressed == null
                ? null
                : () async {
              if (loading) {
                return;
              }
              setState(() => loading = true);
              try {
                await widget.onPressed!();
              } finally {
                if (mounted) {
                  setState(() => loading = false);
                }
              }
            },
            splashRadius: widget.buttonSize,
            style: style,
          ),
        ),
      ),
    );
  }
}