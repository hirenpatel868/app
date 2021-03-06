import 'package:flutter/material.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/temp_quote.dart';

class TempQuoteRow extends StatefulWidget {
  final TempQuote quote;
  final PopupMenuButton popupMenuButton;
  final Function itemBuilder;
  final Function onSelected;
  final Function onTap;
  final bool isDraft;

  TempQuoteRow({
    this.quote,
    this.popupMenuButton,
    this.itemBuilder,
    this.onSelected,
    this.onTap,
    this.isDraft = false,
  });

  @override
  _TempQuoteRowState createState() => _TempQuoteRowState();
}

class _TempQuoteRowState extends State<TempQuoteRow> {
  double elevation = 0.0;
  Color iconColor;
  Color iconHoverColor;

  @override
  initState() {
    super.initState();
    final topics = widget.quote.topics;
    Color color = stateColors.foreground;

    if (topics != null && topics.length > 0) {
      final topicColor = appTopicsColors.find(widget.quote.topics.first);
      color = Color(topicColor.decimal);
    }

    setState(() {
      iconHoverColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.quote;
    final author = quote.author;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 70.0,
        vertical: 30.0,
      ),
      child: Card(
        elevation: elevation,
        color: stateColors.appBackground,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (isHover) {
            elevation = isHover
              ? 2.0
              : 0.0;

            iconColor = isHover
              ? iconHoverColor
              : null;

            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (widget.isDraft)
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Tooltip(
                      message: quote.isOffline
                        ? 'Saved locally only'
                        : 'Saved online',
                      child: ClipOval(
                        child: Material(
                          color: quote.isOffline
                            ? Colors.red
                            : Colors.green,
                          child: InkWell(
                            child: SizedBox(width: 15, height: 15,),
                            onTap: () {
                              final text = quote.isOffline
                                ? "This quote is saved in your device's offline storage. You can save it in the cloud after an edit. It can prevent data loss."
                                : "This quote is saved in the cloud so you can edit it on any other device.";

                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Row(
                                      children: <Widget>[
                                        Icon(Icons.info, color: Colors.blue,),
                                        Padding(padding: const EdgeInsets.only(right: 15.0,)),
                                        Text('Information'),
                                      ],
                                    ),
                                    content: Container(
                                      width: 300.0,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Divider(thickness: 1.0,),
                                          Padding(padding: const EdgeInsets.only(top: 15.0,)),
                                          Text(
                                            text,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.quote.name,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),

                      Padding(padding: const EdgeInsets.only(top: 10.0)),

                      GestureDetector(
                        onTap: () {
                          if (author == null || author.id == null || author.id.isEmpty) {
                            return;
                          }

                          FluroRouter.router.navigateTo(
                            context,
                            AuthorRoute.replaceFirst(':id', author.id),
                          );
                        },
                        child: Opacity(
                          opacity: .5,
                          child: Text(
                            author == null || author.name.isEmpty
                            ? ''
                            : author.name,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: 50.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      PopupMenuButton<String>(
                        icon: Opacity(
                          opacity: .6,
                          child: iconColor != null
                            ? Icon(Icons.more_vert, color: iconColor,)
                            : Icon(Icons.more_vert),
                        ),
                        onSelected: widget.onSelected,
                        itemBuilder: widget.itemBuilder,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
