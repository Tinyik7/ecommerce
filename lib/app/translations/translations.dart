import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'app_title': 'E-commerce App',
          'home': 'Home',
          'favorites': 'Favorites',
          'cart': 'Cart',
          'notifications': 'Notifications',
          'account': 'Account',
          'purchase_now': 'Purchase Now',
          'dark_mode': 'Dark Mode',
          'language': 'Language',
          'help': 'Help',
          'sign_out': 'Sign Out',
          'settings': 'Settings',
          'no_data': 'No products found',
          'online': 'Online',
          'shopping': 'Shopping',
          'new_notification':
              'New notification received\nyour cart is waiting for checkout',
          'notification_date': '10/06/2022 AT 05:30 PM',
        },
        'ru_RU': {
          'app_title': 'Echoes Shop',
          'home': 'Главная',
          'favorites': 'Избранное',
          'cart': 'Корзина',
          'notifications': 'Уведомления',
          'account': 'Профиль',
          'purchase_now': 'Купить сейчас',
          'dark_mode': 'Тёмная тема',
          'language': 'Язык',
          'help': 'Помощь',
          'sign_out': 'Выйти',
          'settings': 'Настройки',
          'no_data': 'Ничего не найдено',
          'online': 'Онлайн',
          'shopping': 'Покупки',
          'new_notification': 'Новый товар ждёт вас в корзине',
          'notification_date': '10.06.2022 17:30',
        }
      };
}
