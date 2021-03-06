import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/lists.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/quote_row.dart';
import 'package:memorare/components/simple_appbar.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/user_quotes_list.dart';
import 'package:memorare/utils/snack.dart';

class QuotesList extends StatefulWidget {
  final String id;

  QuotesList({this.id,});

  @override
  _QuotesListState createState() => _QuotesListState();
}

class _QuotesListState extends State<QuotesList> {
  bool descending     = true;
  bool hasErrors      = false;
  bool hasNext        = true;
  bool isLoading      = false;
  bool isLoadingMore  = false;
  bool isDeletingList = false;
  int limit           = 10;

  var lastDoc;
  final scrollController = ScrollController();

  List<Quote> quotes = [];
  UserQuotesList quotesList;

  ScrollController listScrollController = ScrollController();

  String updateListName = '';
  String updateListDesc = '';
  bool updateListIsPublic   = false;

  @override
  initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
    );
  }

  Widget body() {
    return RefreshIndicator(
      onRefresh: () async {
        await fetch();
        return null;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollNotif) {
          if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
            return false;
          }

          if (hasNext && !isLoadingMore) {
            fetchMore();
          }

          return false;
        },
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            appBar(),
            bodyListContent(),
          ],
        ),
      )
    );
  }

  Widget appBar() {
    return SimpleAppBar(
      textTitle: quotesList == null
        ? 'List'
        : quotesList.name,
      subHeader: Observer(
        builder: (context) {
          return Wrap(
            spacing: 20.0,
            children: <Widget>[
              FadeInY(
                beginY: 10.0,
                delay: 2.0,
                child: OutlineButton(
                  onPressed: () => showEditListDialog(),
                  color: stateColors.background.withAlpha(100),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.edit),
                      ),
                      Text('Edit'),
                    ],
                  ),
                ),
              ),

              FadeInY(
                beginY: 10.0,
                delay: 2.5,
                child: OutlineButton(
                  onPressed: () => showDeleteListDialog(),
                  color: stateColors.background.withAlpha(100),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.delete),
                      ),
                      Text('Delete'),
                    ],
                  ),
                )
              ),
            ],
          );
        },
      ),
    );
  }

  Widget bodyListContent() {
    if (isLoading) {
      return loadingView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    if (quotes.length == 0) {
      return emptyView();
    }

    return sliverQuotesList();
  }

  Widget emptyView() {
    return SliverList(
      delegate: SliverChildListDelegate([
          FadeInY(
            delay: 2.0,
            beginY: 50.0,
            child:
            Container(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 80.0),
                    child: Opacity(
                      opacity: .8,
                      child: Icon(
                        Icons.chat_bubble_outline,
                        size: 100.0,
                        color: Color(0xFFFF005C),
                      ),
                    ),
                  ),

                  Opacity(
                    opacity: .8,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Text(
                        'No quote yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                    child: Opacity(
                      opacity: .6,
                      child: Text(
                        "You can add some from other pages" ,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }

  Widget errorView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(top: 150.0),
          child: ErrorContainer(
            onRefresh: () => fetch(),
          ),
        ),
      ]),
    );
  }

  Widget loadingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: LoadingAnimation(),
          ),
        ]
      ),
    );
  }

  Widget popupMenuButton() {
    return PopupMenuButton(
      onSelected: (value) {
        switch (value) {
          case 'delete':
            showDeleteListDialog();
            break;
          case 'edit':
            showEditListDialog();
            break;
          default:
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Delete'),
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit'),
          ),
        ),
      ],
    );
  }

  Widget sliverQuotesList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final quote = quotes.elementAt(index);

          return QuoteRow(
            quote: quote,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: 'remove',
                child: ListTile(
                  leading: Icon(Icons.remove_circle),
                  title: Text('Remove'),
                )
              ),
              PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                )
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'remove':
                  removeQuote(quote);
                  break;
                case 'share':
                  kIsWeb
                    ? shareTwitter(quote: quote)
                    : shareFromMobile(
                        context: context,
                        quote: quote
                      );
                  break;
                default:
              }
            },
          );
        },
        childCount: quotes.length,
      ),
    );
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      quotes.clear();

      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        setState(() {
          isLoading = false;
        });

        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }

      final docList = await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .collection('lists')
        .document(widget.id)
        .get();

      if (!docList.exists) {
        showSnack(
          context: context,
          message: "This list doesn't' exist anymore",
          type: SnackType.error,
        );

        FluroRouter.router.pop(context);
        return;
      }

      final data = docList.data;
      data['id'] = docList.documentID;
      quotesList = UserQuotesList.fromJSON(data);

      updateListIsPublic = quotesList.isPublic;

      final collSnap = await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .collection('lists')
        .document(quotesList.id)
        .collection('quotes')
        .limit(limit)
        .getDocuments();

      if (collSnap.documents.isEmpty) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      collSnap.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;
        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        hasNext = collSnap.documents.length == limit;
        isLoading = false;
      });

    } catch (err) {
      debugPrint(err.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchMore() async {
    setState(() {
      isLoadingMore = true;
    });

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        setState(() {
          isLoadingMore = false;
        });

        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }

      final snapshot = await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .collection('lists')
        .document(quotesList.id)
        .collection('quotes')
        .startAfterDocument(lastDoc)
        .limit(limit)
        .getDocuments();

      if (snapshot.documents.isEmpty) {
        setState(() {
          hasNext = false;
        });

        return;
      }

      snapshot.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        hasNext = snapshot.documents.length == limit;
        isLoadingMore = false;
      });

    } catch (err) {
      debugPrint(err.toString());

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void showEditListDialog() {
    updateListName = quotesList.name;
    updateListDesc = quotesList.description;
    updateListIsPublic = quotesList.isPublic;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, childSetState) {
            return SimpleDialog(
              title: Text(
                'Edit ${quotesList.name}',
                overflow: TextOverflow.ellipsis,
              ),
              children: <Widget>[
                Divider(thickness: 1.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 10.0,
                  ),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: stateColors.primary),
                      hintText: quotesList.name,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: stateColors.primary,
                          width: 2.0
                        ),
                      ),
                    ),
                    onChanged: (newValue) {
                      updateListName = newValue;
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 10.0,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: stateColors.primary),
                      hintText: quotesList.description,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: stateColors.primary,
                          width: 2.0
                        ),
                      ),
                    ),
                    onChanged: (newValue) {
                      updateListDesc = newValue;
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: updateListIsPublic,
                        onChanged: (newValue) {
                          childSetState(() {
                            updateListIsPublic = newValue;
                          });
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Opacity(
                          opacity: .6,
                          child: Text(
                            'Is public?'
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 15.0,),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          updateListName = '';
                          updateListDesc = '';
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                      ),

                      RaisedButton(
                        color: stateColors.primary,
                        onPressed: () {
                          update();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void showDeleteListDialog() {
    final name = quotesList.name;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete $name?'),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(padding: const EdgeInsets.only(top: 10.0)),
                Divider(thickness: 1.0,),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                  ),
                  child: Opacity(
                  opacity: 0.6,
                  child: Text(
                      'This action is irreversible.',
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Cancel',
                ),
              ),
            ),
            RaisedButton(
              color: Colors.red,
              onPressed: () {
                Navigator.of(context).pop();
                delete();
              },
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  void showQuoteSheet(Quote quote) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 60.0,
          ),
          child: Wrap(
            spacing: 30.0,
            alignment: WrapAlignment.center,
            children: <Widget>[
              IconButton(
                iconSize: 40.0,
                tooltip: 'Delete',
                onPressed: () {
                  Navigator.of(context).pop();
                  removeQuote(quote);
                },
                icon: Opacity(
                  opacity: .6,
                  child: Icon(
                    Icons.delete_outline,
                  ),
                ),
              ),

              IconButton(
                iconSize: 40.0,
                tooltip: 'Delete',
                onPressed: () {
                  Navigator.of(context).pop();
                  shareFromMobile(
                    context: context,
                    quote: quote,
                  );
                },
                icon: Opacity(
                  opacity: .6,
                  child: Icon(
                    Icons.share,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void delete() async {
    setState(() {
      isDeletingList = true;
    });

    final success = await deleteList(
      context: context,
      id: widget.id,
    );

    setState(() {
      isDeletingList = false;
    });

    if (!success) {
      showSnack(
        context: context,
        message: 'There was and issue while deleting the list. Try again later',
        type: SnackType.error,
      );

      return;
    }

    Navigator.pop(context, true);
  }

  void removeQuote(Quote quote) async {
    int index = quotes.indexOf(quote);

    setState(() {
      quotes.removeAt(index);
    });

    final success = await removeFromList(
      context: context,
      id: widget.id,
      quote: quote,
    );

    if (!success) {
      setState(() {
        quotes.insert(index, quote);
      });

      showSnack(
        context: context,
        message: "Sorry, could not remove the quote from your list. Please try again later.",
        type: SnackType.error,
      );
    }
  }

  void update() async {
    final success = await updateList(
      context     : context,
      id          : widget.id,
      name        : updateListName,
      description : updateListDesc,
      isPublic    : updateListIsPublic,
      iconUrl     : quotesList.iconUrl,
    );

    if (!success){
      showSnack(
        context: context,
        message: "Sorry, could not update your list. Please try again later.",
        type: SnackType.error,
      );

      return;
    }

    setState(() {
      quotesList.name = updateListName;
      quotesList.description = updateListDesc;
      quotesList.isPublic = updateListIsPublic;
    });
  }
}
