import 'package:flutter/material.dart' hide SearchController;
import 'package:searchbase/searchbase.dart';

class FilterHeader extends PreferredSize {
  final double height;
  final Widget child;

  FilterHeader({required this.child, this.height = kToolbarHeight, Key? key})
      : super(key: key, child: child, preferredSize: Size.fromHeight(height));
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
  final SearchController searchController;

  const AuthorFilter(this.searchController, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 9),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: Container(
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
                    body: searchController.requestPending
                        ? Center(child: CircularProgressIndicator())
                        : ListView(
                            children: searchController.aggregationData.data!
                                .map((bucket) {
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
                                      value: (searchController.value == null
                                              ? []
                                              : searchController.value)
                                          .contains(bucket['_key']),
                                      onChanged: (bool? value) {
                                        final List values =
                                            searchController.value == null
                                                ? []
                                                : [
                                                    ...searchController.value
                                                        as List
                                                  ];
                                        if (values.contains(bucket['_key'])) {
                                          values.remove(bucket['_key']);
                                        } else {
                                          values.add(bucket['_key']);
                                        }
                                        searchController.setValue(values);
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
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              backgroundColor: Colors.black,
                              minimumSize: Size(88, 36),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 23.0),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2)),
                              ),
                            ),
                            child: Text(
                              'Apply',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              searchController.triggerCustomQuery();
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
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              backgroundColor: Colors.black,
                              minimumSize: Size(88, 36),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 23.0),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2)),
                              ),
                            ),
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