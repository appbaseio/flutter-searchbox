import 'package:flutter/material.dart';
import 'package:searchbase/searchbase.dart';

class StarDisplay extends StatelessWidget {
  final int value;
  const StarDisplay({Key? key, this.value = 0}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return Icon(
            index < value ? Icons.star : Icons.star_border,
            size: 20,
          );
        }),
      ),
    );
  }
}

class ResultsWidget extends StatelessWidget {
  final SearchController searchController;
  Map<String, dynamic> otherBooks = {};

  ResultsWidget(this.searchController);
  @override
  Widget build(BuildContext context) {
    var books;
    // iterating through the inner_hits object, to filter out the other books by the same author(s)
    // that doesn't match the parent book title and storing the result list in the otherBooks map with parent
    // book id as key and result list (books) as value
    searchController.results?.rawData?['hits']['hits'].forEach((hit) => {
          books = [],
          hit['inner_hits']?['other_books']?['hits']?['hits']
              .forEach((book) => {
                    if (book['_id'].toString() != hit['_id'].toString())
                      {books.add(book)}
                  }),
          if (books.length > 0 && otherBooks[hit['_id']] == null)
            {otherBooks[hit['_id']] = books},
        });
    return Column(
      children: [
        Card(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              color: Colors.white,
              height: 20,
              child: Text(
                  '${searchController.results!.numberOfResults} results found in ${searchController.results!.time.toString()} ms'),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                var offset = (searchController.from != null
                        ? searchController.from
                        : 0)! +
                    searchController.size!;
                if (index == offset - 1) {
                  if (searchController.results!.numberOfResults > offset) {
                    // Load next set of results
                    searchController.setFrom(offset,
                        options: Options(triggerDefaultQuery: true));
                  }
                }
              });

              return Container(
                  child: (index < searchController.results!.data.length)
                      ? Container(
                          margin: const EdgeInsets.all(0.5),
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                          decoration: new BoxDecoration(
                              border: Border.all(color: Colors.black26)),
                          height: 200,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Card(
                                      semanticContainer: true,
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: Image.network(
                                        searchController.results!.data[index]
                                            ["image_medium"],
                                        fit: BoxFit.fill,
                                      ),
                                      elevation: 5,
                                      margin: EdgeInsets.all(10),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 90,
                                          width: 280,
                                          child: ListTile(
                                            title: Tooltip(
                                              padding: EdgeInsets.all(5),
                                              height: 35,
                                              textStyle: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                  fontWeight:
                                                      FontWeight.normal),
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    spreadRadius: 1,
                                                    blurRadius: 1,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                                color: Colors.white,
                                              ),
                                              message:
                                                  'By: ${searchController.results!.data[index]["original_title"]}',
                                              child: Text(
                                                searchController
                                                            .results!
                                                            .data[index][
                                                                "original_title"]
                                                            .length <
                                                        40
                                                    ? searchController.results!
                                                            .data[index]
                                                        ["original_title"]
                                                    : '${searchController.results!.data[index]["original_title"].substring(0, 30)}...',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                ),
                                              ),
                                            ),
                                            subtitle: Tooltip(
                                              padding: EdgeInsets.all(5),
                                              height: 35,
                                              textStyle: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                  fontWeight:
                                                      FontWeight.normal),
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    spreadRadius: 1,
                                                    blurRadius: 1,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                                color: Colors.white,
                                              ),
                                              message:
                                                  'By: ${searchController.results!.data[index]["authors"]}',
                                              child: Text(
                                                searchController
                                                            .results!
                                                            .data[index]
                                                                ["authors"]
                                                            .length >
                                                        50
                                                    ? 'By: ${searchController.results!.data[index]["authors"].substring(0, 49)}...'
                                                    : 'By: ${searchController.results!.data[index]["authors"]}',
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      13, 0, 0, 0),
                                              child: IconTheme(
                                                data: IconThemeData(
                                                  color: Colors.amber,
                                                  size: 48,
                                                ),
                                                child: StarDisplay(
                                                    value: searchController
                                                            .results!
                                                            .data[index][
                                                        "average_rating_rounded"]),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 5, 0, 0),
                                              child: Text(
                                                '(${searchController.results!.data[index]["average_rating"]} avg)',
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      17, 10, 0, 0),
                                              child: Text(
                                                'Pub: ${searchController.results!.data[index]["original_publication_year"]}',
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              child:
                                                  otherBooks[searchController
                                                                  .results!
                                                                  .data[index]
                                                              ['_id']] !=
                                                          null
                                                      ? Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  17, 0, 0, 8),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                'Other Books: ',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      12.0,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            10,
                                                                            0,
                                                                            5,
                                                                            0),
                                                                child: Row(
                                                                    children: List<
                                                                            Widget>.generate(
                                                                        otherBooks[searchController.results!.data[index]['_id']]
                                                                            ?.length,
                                                                        (idx) {
                                                                  return Row(
                                                                    children: [
                                                                      Card(
                                                                        semanticContainer:
                                                                            true,
                                                                        clipBehavior:
                                                                            Clip.antiAliasWithSaveLayer,
                                                                        child: Image
                                                                            .network(
                                                                          otherBooks[searchController
                                                                              .results!
                                                                              .data[index]['_id']][idx]['_source']['image_medium'],
                                                                          fit: BoxFit
                                                                              .contain,
                                                                          height:
                                                                              35,
                                                                        ),
                                                                        elevation:
                                                                            2,
                                                                        margin: EdgeInsets.only(
                                                                            right:
                                                                                5),
                                                                      ),
                                                                      Container(
                                                                        width: otherBooks[searchController.results!.data[index]['_id']]?.length >
                                                                                1
                                                                            ? 45
                                                                            : 80,
                                                                        child:
                                                                            Text(
                                                                          otherBooks[searchController
                                                                              .results!
                                                                              .data[index]['_id']][idx]['_source']['original_title'],
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          softWrap:
                                                                              false,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                10.0,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                })),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      : null,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : (searchController.requestPending
                          ? Center(child: CircularProgressIndicator())
                          : ListTile(
                              title: Center(
                                child: RichText(
                                  text: TextSpan(
                                    text:
                                        searchController.results!.data.length >
                                                0
                                            ? "No more results"
                                            : 'No results found',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            )));
            },
            itemCount: searchController.results!.data.length + 1,
          ),
        ),
      ],
    );
  }
}
