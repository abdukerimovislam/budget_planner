import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../data/datasources/local/local_storage_service.dart';
import '../../data/models/expense_category.dart';
import '../../data/models/parsed_expense_input_model.dart';

class SmartExpenseParser {
  GenerativeModel? _model;

  SmartExpenseParser() {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey != null && apiKey.isNotEmpty) {
        _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json', // Форсируем JSON ответ
            temperature: 0.1, // Делаем ответы предсказуемыми и строгими
          ),
        );
      } else {
        debugPrint('AI Model Init Error: GEMINI_API_KEY is missing or empty in .env file');
      }
    } catch (e) {
      debugPrint('AI Model Init Error: $e');
    }
  }

  static final Map<ExpenseCategory, List<String>> _keywords = {
    ExpenseCategory.food: [
      'coffee','latte','cappuccino','americano','espresso',
      'cafe','burger','food','pizza','breakfast','lunch','dinner',
      'restaurant','fastfood','takeaway','delivery',
      'mcdonalds','kfc','starbucks','subway','burgerking',
      'grocery','supermarket','market','store',
      'bread','milk','cheese','meat','fish','chicken','egg',
      'water','drink','snacks','chips','soda','cola',
      'sushi','ramen','noodle','shawarma','doner','kebab',
      'bakery','pastry','cake','dessert','icecream','ice cream',
      'кофе','латте','капучино','эспрессо','американо',
      'кафе','бургер','еда','пицца','обед','ужин','завтрак',
      'ресторан','фастфуд','доставка',
      'макдональдс','мак','кфс','бургер кинг','старбакс',
      'продукты','супермаркет','магазин','гипермаркет',
      'хлеб','молоко','сыр','мясо','рыба','курица','яйца',
      'вода','напиток','газировка','кола','сок',
      'суши','роллы','рамен','лапша','шаурма','донер','кебаб',
      'пекарня','выпечка','десерт','мороженое',
      'spar','metro','lenta','globus','ашан','магнит',
      'пятерочка','перекресток','дикси','верный',
      'народный','фрунзе','корзинка',
      'wolt','glovo','yandex eats','яндекс еда','delivery club'
    ],
    ExpenseCategory.transport: [
      'taxi','uber','yandex','bolt',
      'bus','metro','subway','tram','trolley',
      'fuel','gas','petrol','diesel',
      'ticket','train','railway',
      'parking','car','vehicle','auto',
      'repair','carwash','wash',
      'flight','airplane','airport',
      'такси','убер','яндекс','болт',
      'автобус','метро','маршрутка','трамвай','троллейбус',
      'бензин','топливо','дизель','газ',
      'заправка','азс','газпром',
      'поезд','жд','билет',
      'парковка','машина','авто','тачка',
      'ремонт','сто','шиномонтаж','запчасти',
      'мойка','автомойка',
      'самокат','каршеринг',
      'yandex go','indriver','maxim','citymobil'
    ],
    ExpenseCategory.subscriptions: [
      'netflix','spotify','apple music','youtube premium',
      'youtube','premium','subscription',
      'chatgpt','openai','midjourney','notion',
      'dropbox','google drive','icloud',
      'vpn','nordvpn','expressvpn',
      'amazon prime','patreon','boosty',
      'нетфликс','спотифай','айклауд','ютуб',
      'подписка','премиум',
      'яндекс плюс','кинопоиск',
      'иви','okko','премьер',
      'телеграм премиум','telegram premium',
      'вк музыка','vk music'
    ],
    ExpenseCategory.entertainment: [
      'cinema','movie','film','theatre',
      'game','gaming','steam','epic games',
      'psn','playstation','xbox','nintendo',
      'concert','festival',
      'club','bar','party','pub',
      'museum','gallery',
      'bowling','billiard','arcade',
      'karaoke','quest','escape room',
      'кино','фильм','кинотеатр',
      'игра','игры','стим',
      'концерт','фестиваль',
      'клуб','бар','тусовка','вечеринка','паб',
      'музей','галерея','выставка',
      'боулинг','бильярд','аркада',
      'караоке','квест','кальянная',
      'парк','аттракцион'
    ],
    ExpenseCategory.shopping: [
      'shop','shopping','store','mall',
      'clothes','fashion','brand',
      'shoes','sneakers','boots',
      'tshirt','t-shirt','hoodie',
      'pants','jeans','dress','jacket',
      'electronics','gadget',
      'phone','smartphone','laptop','tablet',
      'watch','headphones','camera',
      'шопинг','покупка','магазин',
      'одежда','вещи','мода','бренд',
      'обувь','кроссовки','ботинки',
      'футболка','худи','штаны','джинсы',
      'платье','куртка','пальто',
      'техника','гаджет',
      'телефон','смартфон','айфон',
      'ноутбук','планшет',
      'наушники','часы','камера',
      'ozon','wildberries','wb','amazon',
      'aliexpress','taobao','ebay',
      'zara','h&m','uniqlo','bershka','pullbear',
      'цум','гум','спортмастер',
      'золотое яблоко','лэтуаль'
    ],
    ExpenseCategory.health: [
      'pharmacy','drugstore',
      'doctor','hospital','clinic',
      'dentist','therapy','treatment',
      'medicine','pills','vitamins',
      'supplements',
      'fitness','gym','workout',
      'yoga','massage','spa',
      'аптека','лекарство','врач','доктор',
      'больница','клиника','стоматолог',
      'таблетки','витамины','добавки',
      'анализ','анализы','узи','мрт',
      'массаж','спа',
      'фитнес','зал','тренировка',
      'инвитро','гемотест'
    ],
    ExpenseCategory.bills: [
      'internet','wifi','broadband',
      'electricity','power',
      'water','heating','gas',
      'rent','utility','utilities',
      'mobile','phone bill','sim',
      'интернет','вайфай',
      'электричество','свет',
      'вода','газ','отопление',
      'коммуналка','жкх',
      'аренда','квартплата',
      'связь','мобильная связь',
      'megacom','beeline','o!','tele2',
      'мегаком','билайн','ошка'
    ],
    ExpenseCategory.education: [
      'course','courses',
      'school','university','college',
      'academy','training',
      'book','books','ebook',
      'tutor','lesson',
      'english','language',
      'курс','курсы','обучение',
      'школа','университет','универ',
      'колледж','академия',
      'книга','книги','учебник',
      'репетитор','урок',
      'английский','язык',
      'семинар','лекция','тренинг'
    ],
    ExpenseCategory.gifts: [
      'gift','present',
      'flowers','bouquet',
      'donation','charity',
      'tips','tip',
      'подарок','цветы','букет',
      'донат','чаевые',
      'благотворительность',
      'пожертвование'
    ],
    ExpenseCategory.travel: [
      'hotel','hostel','resort',
      'booking','airbnb',
      'trip','travel','vacation',
      'tour','tourism',
      'visa','airport',
      'luggage','baggage',
      'отель','гостиница','хостел',
      'букинг','airbnb',
      'поездка','путешествие',
      'отпуск','тур',
      'виза','аэропорт',
      'багаж','чемодан',
      'экскурсия','гид'
    ],
  };

  /// Метод для обычного (локального) парсинга текста
  ParsedExpenseInputModel parse(String input) {
    final text = input.trim().toLowerCase();

    final amountMatch = RegExp(r'(\d+[\d\s]*[.,]?\d{0,2})').firstMatch(text);
    final amount = amountMatch != null
        ? double.tryParse(amountMatch.group(1)!.replaceAll(' ', '').replaceAll(',', '.'))
        : null;

    final currency = _detectCurrency(text);
    final category = _detectCategory(text);
    final merchant = _detectMerchant(text);

    return ParsedExpenseInputModel(
      amount: amount,
      currency: currency,
      category: category,
      merchant: merchant,
      rawText: input,
    );
  }

  /// Умный метод, который использует Gemini AI, если локальный парсер не справился
  Future<ParsedExpenseInputModel> parseWithAI(String input, String activeCurrency) async {
    final localParsed = parse(input);

    // Если локальный парсер всё понял (нашел сумму и конкретную категорию) — возвращаем сразу
    if (localParsed.amount != null && localParsed.category != ExpenseCategory.other) {
      return localParsed;
    }

    // Если нет ИИ модели или превышен лимит — возвращаем результат локального парсера (fallback)
    if (_model == null || !LocalStorageService.instance.canUseAiParser()) {
      return localParsed;
    }

    try {
      final prompt = '''
You are a smart financial parser. Extract transaction details from the user's text.
Rules:
1. "amount": The transaction amount (number, double).
2. "currency": The currency code (USD, EUR, RUB, KGS, KZT, etc.). If not mentioned, return "$activeCurrency".
3. "category": Must be strictly one of these: [food, transport, subscriptions, entertainment, shopping, health, bills, education, gifts, travel, other].
4. "merchant": The name of the place, service, or person (e.g., "Starbucks", "Yandex", "Netflix"). Capitalize properly. If missing, return null.

Return ONLY a valid JSON object. Do not wrap in markdown blocks. Example:
{"amount": 150.5, "currency": "USD", "category": "food", "merchant": "Starbucks"}

User's text: "$input"
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      if (response.text == null) return localParsed;

      // Увеличиваем счетчик использований (защита от спама)
      await LocalStorageService.instance.incrementAiParserUsage();

      final jsonText = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
      final json = jsonDecode(jsonText) as Map<String, dynamic>;

      return ParsedExpenseInputModel(
        amount: (json['amount'] as num?)?.toDouble() ?? localParsed.amount,
        currency: json['currency'] as String? ?? localParsed.currency,
        category: _parseCategoryString(json['category'] as String?) ?? localParsed.category,
        merchant: json['merchant'] as String? ?? localParsed.merchant,
        rawText: input,
      );
    } catch (e) {
      debugPrint('AI Parsing Error: $e');
      return localParsed; // В случае ошибки (нет интернета и т.д.) возвращаем локальный результат
    }
  }

  ExpenseCategory? _parseCategoryString(String? catStr) {
    if (catStr == null) return null;
    return ExpenseCategory.values.firstWhere(
          (e) => e.name.toLowerCase() == catStr.toLowerCase(),
      orElse: () => ExpenseCategory.other,
    );
  }

  String? _detectCurrency(String text) {
    if (text.contains('\$') || text.contains('usd') || text.contains('доллар') || text.contains('бакс')) return 'USD';
    if (text.contains('€') || text.contains('eur') || text.contains('евро')) return 'EUR';
    if (text.contains('£') || text.contains('gbp') || text.contains('фунт')) return 'GBP';
    if (text.contains('₽') || text.contains('rub') || text.contains('руб')) return 'RUB';
    if (text.contains('сом') || text.contains('kgs') || text.contains('kyrgyz som')) return 'KGS';
    if (text.contains('тенге') || text.contains('kzt')) return 'KZT';
    if (text.contains('сум') || text.contains('uzs')) return 'UZS';
    if (text.contains('грив') || text.contains('uah')) return 'UAH';
    if (text.contains('byn') || text.contains('бел руб')) return 'BYN';
    return null;
  }

  ExpenseCategory? _detectCategory(String text) {
    for (final entry in _keywords.entries) {
      for (final keyword in entry.value) {
        if (RegExp(r'(^|\s)' + RegExp.escape(keyword) + r'(\s|$)').hasMatch(text)) {
          return entry.key;
        }
      }
    }
    for (final entry in _keywords.entries) {
      for (final keyword in entry.value) {
        if (text.contains(keyword)) {
          return entry.key;
        }
      }
    }
    return ExpenseCategory.other;
  }

  String? _detectMerchant(String text) {
    final words = text.split(' ');
    final stopWords = [
      'за','на','в','для','и','с',
      'купил','потратил','оплатил','скинул',
      'usd','kgs','rub','руб','сом',
      'доллар','евро','тенге'
    ];
    final cleaned = words.where((w) {
      final isNumber = double.tryParse(w.replaceAll(',', '.')) != null;
      final isStopWord = stopWords.contains(w.toLowerCase());
      return !isNumber && !isStopWord;
    });

    if (cleaned.isEmpty) return null;
    final merchantString = cleaned.join(' ').trim();
    if (merchantString.isEmpty) return null;
    return merchantString[0].toUpperCase() + merchantString.substring(1);
  }

  @visibleForTesting
  ExpenseCategory? detectCategoryForTest(String text) => _detectCategory(text);
}