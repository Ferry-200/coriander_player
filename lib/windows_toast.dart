import 'package:windows_ui/windows_ui.dart';

void sendWindowsNotification({required String title, required String content}) {
  const applicationId = 'Coriander Player';
  // Create a toast notifier
  final toastNotifier =
      ToastNotificationManager.createToastNotifierWithId(applicationId);
  if (toastNotifier != null) {
    final toastContent = ToastNotificationManager.getTemplateContent(
        ToastTemplateType.toastText02);
    if (toastContent != null) {
      final xmlNodeList = toastContent.getElementsByTagName('text');
      // Set the title on the toast notification
      xmlNodeList.item(0)?.appendChild(toastContent.createTextNode(title));
      // Set the content on the toast notification
      xmlNodeList.item(1)?.appendChild(toastContent.createTextNode(content));

      // Create a toast notification
      final toastNotification =
          ToastNotification.createToastNotification(toastContent);

      // Show the toast notification
      toastNotifier.show(toastNotification);
    }
  }
}
