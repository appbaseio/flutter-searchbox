import 'package:flutter/material.dart';
import 'package:searchbase/searchbase.dart';

class FilterHeader extends PreferredSize {
  final double height;
  final Widget child;

  FilterHeader({@required this.child, this.height = kToolbarHeight});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      // color: Colors.white,
      alignment: Alignment.centerLeft,
      child: child,
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
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
    );
  }
}

class AuthorFilter extends StatelessWidget {
  final SearchWidget searchWidget;

  AuthorFilter(this.searchWidget);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 105, 0, 0),
        child: Column(
          children: [
            Container(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: 750,
                  color: Colors.white,
                  child: Scaffold(
                    appBar: FilterHeader(
                      height: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                                text: 'Select Authors',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ],
                      ),
                    ),
                    body: searchWidget.requestPending
                        ? Center(child: CircularProgressIndicator())
                        : ListView(
                            children:
                                searchWidget.aggregationData.data.map((bucket) {
                              return Container(
                                child: Column(
                                  children: [
                                    new CheckboxListTile(
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      activeColor: Colors.black54,
                                      dense: true,
                                      title: new Text(
                                          "${bucket['_key']} (${bucket['_doc_count']})"),
                                      value: (searchWidget.value == null
                                              ? []
                                              : searchWidget.value)
                                          .contains(bucket['_key']),
                                      onChanged: (bool value) {
                                        final List<String> values =
                                            searchWidget.value == null
                                                ? []
                                                : searchWidget.value;
                                        if (values.contains(bucket['_key'])) {
                                          values.remove(bucket['_key']);
                                        } else {
                                          values.add(bucket['_key']);
                                        }
                                        searchWidget.setValue(values);
                                      },
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ),
            ),
            Container(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  color: Colors.black,
                  height: 70,
                  width: 500,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 6,
                          child: RaisedButton(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 23.0),
                            color: Colors.black,
                            child: Text(
                              'Apply',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              searchWidget.triggerCustomQuery();
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.center,
                            child: RichText(
                              text: TextSpan(
                                text: '|',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 50,
                                    fontWeight: FontWeight.w100),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: RaisedButton(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 23.0),
                            color: Colors.black,
                            child: Text(
                              'Close',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
