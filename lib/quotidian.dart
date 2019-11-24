
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/types/quotidian.dart';

class QuotidianWidget extends StatelessWidget {
  final String fetchQuotidian = """
    query {
      quotidian {
        id
        quote {
          author {
            id
            name
          }
          id
          name
        }
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: fetchQuotidian
        ),
      builder: (QueryResult result, { VoidCallback refetch, FetchMore fetchMore }) {
        if (result.errors != null) {
          return Text(result.errors.toString());
        }

        if (result.loading) {
          return Text('Loading...');
        }

        var quotidian = Quotidian.fromJSON(result.data['quotidian']);

        return Expanded(
          child: Container(
            decoration: BoxDecoration(color: Color(0xFF706FD3)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${quotidian.quote.name}',
                  style: TextStyle(
                    color: Colors.white,
                    // fontFamily: 'Comfortaa',
                    fontSize: 35,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: CircleAvatar(
                          backgroundColor: Color(0xFFF56098),
                          child: Text('${quotidian.quote.author.name.substring(0,1)}'),
                        ),
                      ),
                      Text(
                        '${quotidian.quote.author.name}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.more_horiz),
                      color: Colors.white,
                      iconSize: 40.0,
                      onPressed: () {
                        print('show quotidian actions');
                      },
                    ),
                  ],
                )
              ],
            ),
            padding: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
          )
        );
      },
    );
  }
}
