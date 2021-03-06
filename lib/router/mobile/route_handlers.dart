import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/all_topics.dart';
import 'package:memorare/screens/account.dart';
import 'package:memorare/screens/add_quote.dart';
import 'package:memorare/screens/admin_quotes.dart';
import 'package:memorare/screens/admin_temp_quotes.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/screens/delete_account.dart';
import 'package:memorare/screens/drafts.dart';
import 'package:memorare/screens/edit_email.dart';
import 'package:memorare/screens/edit_password.dart';
import 'package:memorare/screens/favourites.dart';
import 'package:memorare/screens/forgot_password.dart';
import 'package:memorare/screens/full_page_quotidian.dart';
import 'package:memorare/screens/home.dart';
import 'package:memorare/screens/published_quotes.dart';
import 'package:memorare/screens/quote_page.dart';
import 'package:memorare/screens/quotes_list.dart';
import 'package:memorare/screens/quotes_lists.dart';
import 'package:memorare/screens/quotidians.dart';
import 'package:memorare/screens/reference_page.dart';
import 'package:memorare/screens/signin.dart';
import 'package:memorare/screens/signup.dart';
import 'package:memorare/screens/temp_quotes.dart';
import 'package:memorare/screens/topic_page.dart';

class MobileRouteHandlers {
  static Handler account = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Account());

  static Handler addQuote = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuote());

  static Handler adminTempQuotes = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AdminTempQuotes());

  static Handler author = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AuthorPage(id: params['id'][0]));

  static Handler dashboard = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Home(initialIndex: 2,));

  static Handler deleteAccount = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DeleteAccount());

  static Handler drafts = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Drafts());

  static Handler favourites = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Favourites());

  static Handler editEmail = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          EditEmail());

  static Handler editPassword = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          EditPassword());

  static Handler forgotPassword = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ForgotPassword());

  static Handler home = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Home());

  static Handler lists = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          QuotesLists());

  static Handler list = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          QuotesList(id: params['id'][0],));

  static Handler pubQuotes = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          MyPublishedQuotes());

  static Handler quote = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          QuotePage(id: params['id'][0]));

  static Handler quotes = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AdminQuotes());

  static Handler quotidian = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          FullPageQuotidian());

  static Handler quotidians = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Quotidians());

  static Handler reference = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ReferencePage(id: params['id'][0]));

  static Handler signin = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Signin());

  static Handler signup = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Signup());

  static Handler tempquotes = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          MyTempQuotes());

  static Handler topic = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          TopicPage(name: params['name'][0]));

  static Handler topics = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AllTopics());

  static Handler welcomeBack = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Home(initialIndex: 2,));
}
