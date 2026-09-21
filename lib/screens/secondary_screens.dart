import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/app_theme.dart';
import '../state/subscriber_state.dart';
import '../widgets/ui_components.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Set<int> _read = {};
  final Set<int> _dismissed = {};
  final _items = const [
    (
      'Новый счет за сентябрь',
      'Счет на сумму 580 сом уже доступен. Оплатите его до 25 сентября 2026.',
      Icons.receipt_long_outlined,
    ),
    (
      'Напоминание передать показания',
      'Передайте показания счетчика до конца месяца, чтобы получить точный счет.',
      Icons.speed_outlined,
    ),
    (
      'Платеж успешно принят',
      'Последний платеж на сумму 290 сом успешно зачислен.',
      Icons.check_circle_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Уведомления'),
      actions: [
        IconButton(
          tooltip: 'Отметить прочитанными',
          onPressed: () => setState(
            () => _read.addAll(List.generate(_items.length, (i) => i)),
          ),
          icon: const Icon(Icons.done_all_rounded),
        ),
        IconButton(
          tooltip: 'Очистить уведомления',
          onPressed: () => setState(
            () => _dismissed.addAll(List.generate(_items.length, (i) => i)),
          ),
          icon: const Icon(Icons.delete_sweep_outlined),
        ),
      ],
    ),
    body: ListView(
      padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 24.h),
      children: [
        if (_dismissed.length == _items.length)
          const AppCard(
            child: EmptyState(
              title: 'У вас пока нет новых уведомлений',
              message: 'Новые сообщения появятся здесь.',
              icon: Icons.notifications_none_rounded,
            ),
          ),
        ..._items
            .asMap()
            .entries
            .where((entry) => !_dismissed.contains(entry.key))
            .map((entry) {
              final index = entry.key;
              final item = entry.value;
              final read = _read.contains(index);
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: AppCard(
                  onTap: () => setState(() => _read.add(index)),
                  color: read ? Colors.white : const Color(0xFFFCFEFF),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconBadge(
                        item.$3,
                        background: read
                            ? const Color(0xFFF2F4F7)
                            : AppColors.ice,
                        foreground: read ? AppColors.secondary : AppColors.blue,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.$1,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (!read)
                                  Container(
                                    width: 7.r,
                                    height: 7.r,
                                    decoration: const BoxDecoration(
                                      color: AppColors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              item.$2,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.secondary,
                                height: 1.45,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Сегодня',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Удалить уведомление',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() => _dismissed.add(index)),
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18.r,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ],
    ),
  );
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _phone;
  bool _loading = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final state = SubscriberScope.of(context);
    _first = TextEditingController(text: state.firstName);
    _last = TextEditingController(text: state.lastName);
    _phone = TextEditingController(text: state.phone);
    _initialized = true;
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate() || _loading) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    SubscriberScope.of(
      context,
    ).saveProfile(first: _first.text, last: _last.text, newPhone: _phone.text);
    showAppSnack(context, 'Профиль сохранен');
    Navigator.pop(context);
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? 'Заполните обязательное поле'
      : null;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Редактировать профиль')),
    body: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ваши данные',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.secondary),
                ),
                SizedBox(height: 18.h),
                TextFormField(
                  controller: _first,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Имя'),
                  validator: _required,
                ),
                SizedBox(height: 14.h),
                TextFormField(
                  controller: _last,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Фамилия'),
                  validator: _required,
                ),
                SizedBox(height: 14.h),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'Телефон'),
                  validator: (value) {
                    if (_required(value) != null) return _required(value);
                    if ((value ?? '').replaceAll(RegExp(r'\D'), '').length <
                        10) {
                      return 'Введите корректный номер телефона';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                PrimaryButton(
                  label: 'Сохранить',
                  icon: Icons.check_rounded,
                  loading: _loading,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});
  static const _questions = [
    (
      'Как передать показания счетчика?',
      'На главной странице нажмите на напоминание о показаниях, введите новое значение и подтвердите отправку.',
    ),
    (
      'Когда нужно оплачивать счет?',
      'Оплатить текущий счет нужно до 25 числа. Дата указана в карточке счета.',
    ),
    (
      'Как рассчитывается расход воды?',
      'Расход — это разница между текущим и предыдущим показанием счетчика.',
    ),
    (
      'Что делать при неправильном начислении?',
      'Напишите нам через раздел «Обратная связь» и укажите номер лицевого счета.',
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Частые вопросы')),
    body: ListView(
      padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 24.h),
      children: [
        Text(
          'Чем мы можем помочь?',
          style: TextStyle(fontSize: 14.sp, color: AppColors.secondary),
        ),
        SizedBox(height: 14.h),
        AppCard(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Column(
            children: _questions
                .map(
                  (item) => Column(
                    children: [
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.only(bottom: 15.h),
                        title: Text(
                          item.$1,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        iconColor: AppColors.blue,
                        collapsedIconColor: AppColors.secondary,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item.$2,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.secondary,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (item != _questions.last) const Divider(height: 1),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ),
  );
}

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  final _contact = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate() || _loading) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;
    setState(() => _loading = false);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_outline_rounded,
          color: AppColors.success,
          size: 34,
        ),
        title: const Text('Спасибо!'),
        content: const Text('Ваше обращение отправлено.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Обратная связь')),
    body: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Расскажите, чем мы можем помочь',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.secondary),
                ),
                SizedBox(height: 18.h),
                TextFormField(
                  controller: _subject,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Тема'),
                  validator: _required,
                ),
                SizedBox(height: 14.h),
                TextFormField(
                  controller: _message,
                  minLines: 4,
                  maxLines: 7,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'Сообщение',
                    alignLabelWithHint: true,
                  ),
                  validator: _required,
                ),
                SizedBox(height: 14.h),
                TextFormField(
                  controller: _contact,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Телефон для связи (необязательно)',
                  ),
                ),
                SizedBox(height: 22.h),
                PrimaryButton(
                  label: 'Отправить',
                  icon: Icons.send_rounded,
                  loading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? 'Заполните обязательное поле'
      : null;
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = SubscriberScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 24.h),
        children: [
          const SectionTitle('Уведомления'),
          AppCard(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 3.h),
            child: Column(
              children: [
                _SettingsToggle(
                  label: 'Напоминания о платежах',
                  value: state.paymentReminders,
                  onChanged: (v) =>
                      state.setNotification('paymentReminders', v),
                ),
                const Divider(height: 1),
                _SettingsToggle(
                  label: 'SMS-уведомления',
                  value: state.smsNotifications,
                  onChanged: (v) =>
                      state.setNotification('smsNotifications', v),
                ),
                const Divider(height: 1),
                _SettingsToggle(
                  label: 'Push-уведомления',
                  value: state.pushNotifications,
                  onChanged: (v) =>
                      state.setNotification('pushNotifications', v),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          const SectionTitle('Язык'),
          AppCard(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 1.h),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.language_rounded,
                color: AppColors.blueDark,
              ),
              title: Text(state.language, style: TextStyle(fontSize: 14.sp)),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.secondary,
              ),
              onTap: () => _chooseLanguage(context, state),
            ),
          ),
          SizedBox(height: 20.h),
          const SectionTitle('О приложении'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EcoBilling',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Версия 1.0.0',
                  style: TextStyle(fontSize: 13.sp, color: AppColors.secondary),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Сервис для удобного контроля потребления воды и оплаты счетов.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.secondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseLanguage(
    BuildContext context,
    SubscriberUiState state,
  ) async {
    final value = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetTitle(title: 'Язык приложения'),
            for (final language in ['Русский', 'Кыргызча'])
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(language),
                trailing: state.language == language
                    ? const Icon(Icons.check_rounded, color: AppColors.blue)
                    : null,
                onTap: () => Navigator.pop(context, language),
              ),
          ],
        ),
      ),
    );
    if (value != null) {
      await state.setLanguage(value);
      if (context.mounted) showAppSnack(context, 'Настройки сохранены');
    }
  }
}

class _SettingsToggle extends StatelessWidget {
  const _SettingsToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 5.h),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 14.sp)),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.blue,
          activeThumbColor: Colors.white,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    ),
  );
}
