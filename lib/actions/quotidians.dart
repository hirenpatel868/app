import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:memorare/types/quote.dart';

Future<bool> addToQuotidians({Quote quote, String lang = 'en'}) async {
  try {
    // Decide the next date
    final snapshot = await Firestore.instance
      .collection('quotidians')
      .where('lang', isEqualTo: lang)
      .orderBy('date', descending: true)
      .limit(1)
      .getDocuments();

    String id = '';
    DateTime nextDate;

    if (snapshot.documents.isEmpty) {
      final now = DateTime.now();
      nextDate = now;

      String month = now.month.toString();
      month = month.length == 2 ? month : '0$month';

      String day = now.day.toString();
      day = day.length == 2 ? day : '0$day';

      id = '${now.year}:$month:$day:$lang';

    } else {
      final first = snapshot.documents.first;
      final Timestamp lastTimestamp = first.data['date'];
      final DateTime lastDate = lastTimestamp.toDate();

      nextDate = lastDate.add(
        Duration(days: 1)
      );

      String nextMonth = nextDate.month.toString();
      nextMonth = nextMonth.length == 2 ? nextMonth : '0$nextMonth';

      String nextDay = nextDate.day.toString();
      nextDay = nextDay.length == 2 ? nextDay : '0$nextDay';

      id = '${nextDate.year}:$nextMonth:$nextDay:$lang';
    }

    await Firestore.instance
      .collection('quotidians')
      .document(id)
      .setData({
        'createdAt': DateTime.now(),
        'date': nextDate,
        'lang': lang,
        'quote': {
          'author': {
            'id': quote.author.id,
            'name': quote.author.name,
          },
          'id': quote.id,
          'mainReference': {
            'id': quote.mainReference.id,
            'name': quote.mainReference.name,
          },
          'name': quote.name,
          'topics': quote.topics,
        },
        'updatedAt': DateTime.now(),
        'urls': {
          'image': {
            'small': '',
            'medium': '',
            'large': '',
          },
          'imageAndText': {
            'small': '',
            'medium': '',
            'large': '',
          },
        }
      });

    return true;

  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}
