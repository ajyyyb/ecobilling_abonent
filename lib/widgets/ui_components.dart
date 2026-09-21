import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: padding ?? EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.border.withValues(alpha: .68)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x080B2545),
                blurRadius: 16,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.height,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height ?? 50.h,
      child: FilledButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? SizedBox(
                width: 18.r,
                height: 18.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon ?? Icons.arrow_forward_rounded, size: 18.r),
        label: Text(
          loading ? 'Подождите…' : label,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.blue.withValues(alpha: .7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.title, {
    super.key,
    this.trailing,
    this.onTrailingTap,
    this.bottom = 12,
  });
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          if (trailing != null)
            TextButton(
              onPressed: onTrailingTap,
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: Text(trailing!, style: TextStyle(fontSize: 13.sp)),
            ),
        ],
      ),
    );
  }
}

class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F7),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: selected ? AppColors.paleBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? AppColors.blueDark : AppColors.secondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge(
    this.icon, {
    super.key,
    this.background = AppColors.ice,
    this.foreground = AppColors.blue,
    this.size = 42,
  });
  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size.w,
    height: size.w,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(13.r),
    ),
    child: Icon(icon, size: (size * .52).r, color: foreground),
  );
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
    this.color = AppColors.blue,
  });
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 13.h),
      child: Row(
        children: [
          Icon(icon, size: 19.r, color: color),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14.sp, color: AppColors.secondary),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
          ),
          if (trailing != null) ...[SizedBox(width: 6.w), trailing!],
        ],
      ),
    ),
  );
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, this.success = true});
  final String label;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final color = success ? AppColors.success : AppColors.warning;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            success ? Icons.check_circle : Icons.schedule,
            size: 14.r,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

void showAppSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.error : const Color(0xFF26374A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 44.h, horizontal: 26.w),
    child: Column(
      children: [
        IconBadge(icon, size: 62, background: AppColors.ice),
        SizedBox(height: 16.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
        ),
        SizedBox(height: 6.h),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.sp, color: AppColors.secondary),
        ),
      ],
    ),
  );
}

class SheetTitle extends StatelessWidget {
  const SheetTitle({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Center(
        child: Container(
          width: 38.w,
          height: 4.h,
          margin: EdgeInsets.only(bottom: 18.h),
          decoration: BoxDecoration(
            color: const Color(0xFFD0D5DD),
            borderRadius: BorderRadius.circular(99.r),
          ),
        ),
      ),
      Text(
        title,
        style: TextStyle(
          fontSize: 21.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
      if (subtitle != null) ...[
        SizedBox(height: 5.h),
        Text(
          subtitle!,
          style: TextStyle(fontSize: 14.sp, color: AppColors.secondary),
        ),
      ],
      SizedBox(height: 20.h),
    ],
  );
}

Widget screenPadding({required Widget child}) =>
    Padding(padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 24.h), child: child);
