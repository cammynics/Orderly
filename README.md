# Orderly

Offline-first order management for small sellers, built with Flutter, Provider,
and SQLite.

## Run

1. Install the Flutter stable SDK and configure an Android device/emulator or an
	 iOS simulator (iOS builds require macOS and Xcode).
2. From this directory, run `flutter pub get`.
3. Run `flutter run` with a connected Android or iOS target.

To check the code locally, run `flutter analyze` and `flutter test`. The app data
is stored in the platform SQLite database and remains available offline.

## Assumptions

- A customer's normalized phone number identifies the customer; punctuation and
	spaces are ignored when matching existing customers.
- Order numbers are sequential (`ORD-0001`, `ORD-0002`, ...) and are not reused
	after an order is deleted.
- Sales and customer spending exclude cancelled orders, while order counts still
	include them.
- Order dates can be selected from 2000 through five years in the future.
- The currency defaults to Philippine pesos (`₱`); change `currencySymbol` and
	`currencyLocale` in `lib/utils/constants.dart` to configure it.