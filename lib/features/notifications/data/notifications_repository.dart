import '../../../models/notification_model.dart';
import '../../../data/database/database_helper.dart';

class NotificationsRepository {
  NotificationsRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<List<NotificationModel>> fetchNotifications() {
    return _databaseHelper.getNotifications();
  }

  Future<void> saveNotification(NotificationModel notification) {
    return _databaseHelper.upsertNotification(notification);
  }

  Future<void> replaceStockNotifications(List<NotificationModel> notifications) {
    return _databaseHelper.replaceStockNotifications(notifications);
  }

  Future<void> markAsRead(String id) {
    return _databaseHelper.markNotificationAsRead(id);
  }

  Future<void> markAllAsRead() {
    return _databaseHelper.markAllNotificationsAsRead();
  }

  Future<int> deleteNotification(String id) {
    return _databaseHelper.deleteNotification(id);
  }
}
