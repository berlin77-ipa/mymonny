# My Money: iPhone-приложение с виджетом

Нужно: Mac (можно облачный), Xcode 16+, Node 20+, Apple Developer.

Поддерживаются iPhone с iOS 17 и новее (от iPhone XS и iPhone SE 2020 до новых моделей с Dynamic Island).
iPad не поддерживается: скрипт `setup-ios.sh` ставит минимальную версию iOS 17.0 и только iPhone.

## 1. Подготовка проекта
1. В `capacitor.config.json` замените `appId` на свой bundle ID.
2. Выполните:

       npm install
       npx cap add ios
       bash setup-ios.sh
       npx cap sync ios
       npx cap open ios

   Скрипт копирует Swift-файлы, добавляет URL-схему `finance://`, подключает
   `ViewController` и плагин передачи баланса, кладёт файл виджета в `ios/BalanceWidget.swift`.

## 2. Приложение в Xcode
3. Цель **App** → Signing & Capabilities → выберите Team.
   Нажмите **+ Capability** → **App Groups** → **+** → введите `group.<ваш appId>`
   (например, `group.com.mycompany.finance`).

## 3. Виджет
4. File → New → Target → **Widget Extension**. Имя: `BalanceWidget`.
   Снимите галочки Include Live Activity, Include Control, Include Configuration App Intent.
   На вопрос про активацию схемы ответьте Cancel.
5. В папке `BalanceWidget` в левой панели удалите все созданные .swift файлы (Move to Trash).
   Перетащите туда `ios/BalanceWidget.swift`, в Target Membership оставьте только `BalanceWidget`.
6. Цель **BalanceWidget** → Signing & Capabilities → Team, затем **+ Capability** → **App Groups**
   → выберите ту же группу `group.<ваш appId>`.
7. Цель **BalanceWidget** → General → Minimum Deployments: **iOS 17.0**; Supported Destinations: только iPhone.

## 4. Запуск и добавление виджета
8. Выберите схему **App**, свой iPhone и нажмите Run. Откройте приложение один раз.
9. Долгое нажатие на экране «Домой» → «+» → «My Money» → «Баланс» (средний размер).

Левая кнопка «−» открывает форму расхода, правая «+» открывает форму дохода.
Баланс в виджете обновляется при каждом изменении данных в приложении.

## Если что-то не работает
- В виджете 0 ₽: проверьте, что App Group одинаковая у обеих целей, и откройте приложение.
- Кнопки не открывают формы: проверьте URL Types (схема `finance`) в Info цели App
  и что в Main.storyboard у экрана класс `ViewController`.
- Иконка: положите `assets/icon.png` (1024×1024) и выполните
  `npm i -D @capacitor/assets && npx capacitor-assets generate --ios`.

Данные хранятся локально на устройстве и пропадут при удалении приложения.

## Совместимость экранов
- Вырез, Dynamic Island и нижняя полоса: учитываются через safe-area, отступы подстраиваются сами.
- iPhone SE 2020 (экран 375×667, кнопка Home, без выреза): включена компактная вёрстка для узких экранов.
- Альбомная ориентация: учтены боковые отступы под вырез.
- Проверьте в симуляторе Xcode: iPhone SE (3rd generation), iPhone 15, iPhone 16 Pro Max.
