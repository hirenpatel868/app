import 'package:memorare/types/author.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/reference.dart';
import 'package:memorare/types/reference_type.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/types/urls.dart';

class AddQuoteInputs {
  /// If not empty, the author already exists.
  static Author author = Author.empty();

  static String comment = '';
  static TempQuote draft;

  /// True if the quote which is being is edited
  static bool isOfflineDraft = false;

  /// Navigated to new quote page
  /// from Dashboard or Admin temp quote?
  static String navigatedFromPath = '';

  /// Quote's id is not empty if this is an edit.
  static Quote quote = Quote.empty();

  /// If not empty, the reference already exists.
  static Reference reference = Reference.empty();

  static String region = '';


  static void clearAll() {
    clearAuthor();
    clearComment();
    clearQuoteData();
    clearReference();
    clearTopics();
  }

  static void clearAuthor() {
    author = Author.empty();
  }

  static void clearComment() {
    comment = '';
  }

  static void clearQuoteData({bool keepLang = true}) {
    final prevLang = quote.lang;

    quote = Quote.empty();
    quote.lang = keepLang ? prevLang : 'en';
    draft = null;
    isOfflineDraft = false;
  }

  static void clearReference() {
    reference = Reference.empty();
  }

  static void clearTopics() {
    quote.topics.clear();
  }

  static populateWithTempQuote(TempQuote tempQuote) {
    quote = Quote(
      id: tempQuote.id ?? '',
      name: tempQuote.name,
      lang: tempQuote.lang,
      topics: tempQuote.topics,
    );

    author = Author(
      id      : tempQuote.author.id,
      job     : tempQuote.author.job,
      name    : tempQuote.author.name,
      summary : tempQuote.author.summary,
      urls: Urls(
        affiliate : tempQuote.author.urls.affiliate,
        amazon    : tempQuote.author.urls.amazon,
        facebook  : tempQuote.author.urls.facebook,
        image     : tempQuote.author.urls.image,
        netflix   : tempQuote.author.urls.netflix,
        primeVideo: tempQuote.author.urls.primeVideo,
        twitch    : tempQuote.author.urls.twitch,
        twitter   : tempQuote.author.urls.twitter,
        website   : tempQuote.author.urls.website,
        wikipedia : tempQuote.author.urls.wikipedia,
        youtube   : tempQuote.author.urls.youtube,
      ),
    );

    if (tempQuote.references.length > 0) {
      final ref = tempQuote.references.first;

      reference = Reference(
        id      : ref.id,
        lang    : ref.lang,
        name    : ref.name,
        summary : ref.summary,
        type    : ReferenceType(
          primary   : ref.type.primary,
          secondary : ref.type.secondary,
        ),
        urls    : Urls(
          affiliate : ref.urls.affiliate,
          amazon    : ref.urls.amazon,
          facebook  : ref.urls.facebook,
          image     : ref.urls.image,
          netflix   : ref.urls.netflix,
          primeVideo: ref.urls.primeVideo,
          twitch    : ref.urls.twitch,
          twitter   : ref.urls.twitter,
          website   : ref.urls.website,
          wikipedia : ref.urls.wikipedia,
          youtube   : ref.urls.youtube,
        ),
      );
    } else {
      clearReference();
    }

    if (tempQuote.comments.length > 0) {
      comment = tempQuote.comments.first;
    }

    region = tempQuote.region;
  }
}
