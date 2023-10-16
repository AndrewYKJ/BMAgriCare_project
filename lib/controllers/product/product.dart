import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/product/product_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/page_argument/page_arguments.dart';
import 'package:behn_meyer_flutter/models/product/product_category.dart';
import 'package:behn_meyer_flutter/models/product/product_data.dart';
import 'package:behn_meyer_flutter/models/product/product_filter.dart';
import 'package:behn_meyer_flutter/models/product/product_item.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:behn_meyer_flutter/widget/floating_button_scroll_to_top.dart';
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class Product extends StatefulWidget {
  Product() : super();

  @override
  ProductState createState() => ProductState();
}

class ProductState extends State<Product> {
  ScrollController _sc = new ScrollController();
  static int page = 1;
  final int size = 20;
  bool isLoading = false;
  bool noMore = false;
  List categories = [];
  List products = [];
  int selectedCategory;
  int _selectedMenuIndex = 0;
  ItemScrollController _scrollController = ItemScrollController();
  final searchField = TextEditingController();
  double scrollMark;
  bool isReversing = false;
  bool isBackward = false;
  bool hideMenu = false;
  List selectedTags = [];
  List selectedSubCategories = [];
  List selectedCategories = [];
  ProductFilter filters;
  List filterList = [];
  int total;
  bool hasFilter = false;
  List selectFilterTags = [];

  @override
  void initState() {
    page = 1;
    noMore = false;
    this._getCategories();
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_tab_product);

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        if (!noMore) {
          if (searchField.text.length > 0) {
            _searchData(page, searchField.text,
                selectedCategories: selectedCategories.join(','),
                selectedSubCategories: selectedSubCategories.join(','),
                tags: selectedTags.join(','));
          } else {
            _getMoreData(page, selectedCategories.join(','),
                selectedSubCategories: selectedSubCategories.join(','),
                tags: selectedTags.join(','));
          }
        }
      }

      if (_sc.position.userScrollDirection == ScrollDirection.forward) {
        if (scrollMark != null) {
          if ((scrollMark - _sc.position.pixels) > 50.0) {
            setState(() {
              isReversing = true;
            });
          }
        }
      } else {
        scrollMark = _sc.position.pixels;
        setState(() {
          isReversing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    setState(() {
      page = 1;
      _selectedMenuIndex = 0;
      noMore = false;
      hideMenu = false;
      products.clear();
      categories.clear();
      searchField.text = "";
      selectedCategories = [];
      selectedSubCategories = [];
      selectedTags = [];
      selectFilterTags = [];
      filterList = [];
      filters = null;
    });
    _getCategories();
  }

  Future<List<ProductCategory>> fetchCategories(BuildContext context) async {
    ProductApi productApi = ProductApi(context);
    return productApi.fetchProductCategoryList();
  }

  Future<ProductItemWrapper> fetchProducts(
      BuildContext context, String catId, int page, int size,
      {String subCatId, String tag}) async {
    ProductApi productApi = ProductApi(context);
    return productApi.fetchProductList(catId, page, size,
        subCategoryId: subCatId, tags: tag);
  }

  Future<ProductItemWrapper> searchProducts(
      BuildContext context, String keyword, int page, int size,
      {String catId, String subCatId, String tag}) async {
    ProductApi productApi = ProductApi(context);
    return productApi.searchProduct(keyword, page, size,
        categoryId: catId, subCategoryId: subCatId, tags: tag);
  }

  Future<ProductFilter> fetchProductFilters(BuildContext context, String catId,
      String subCatId, String tags, String keyword) async {
    ProductApi productApi = ProductApi(context);
    return productApi.getProductFilter(catId, subCatId, tags, keyword);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButton: floatingButtonScrollToTop(_sc, isReversing),
          primary: true,
          appBar: CustomAppBar(
            child: appBarIcon(context),
          ),
          body: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Container(
                height: screenHeight,
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                color: Colors.white,
                child: RefreshIndicator(
                  color: AppColor.appBlue(),
                  onRefresh: refresh,
                  child: ListView(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    shrinkWrap: true,
                    children: [
                      SizedBox(height: 16),
                      searchWrapper(context),
                      SizedBox(height: 8),
                      dottedLineSeperator(height: 1, color: AppColor.appBlue()),
                      SizedBox(height: 16),
                      if (!hideMenu)
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _horizontalMenuListView(context),
                              backButton(context)
                            ]),
                      if (!hideMenu)
                        SizedBox(
                          height: 16,
                        ),
                      if (!hideMenu && this.total != null) divider(context),
                      if (!hideMenu && this.total != null)
                        SizedBox(
                          height: 10,
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (this.total != null)
                            Text(
                                Util.getTranslated(context, "total_product_1") +
                                    ' ${this.total} ' +
                                    Util.getTranslated(
                                        context, "total_product_2"),
                                style: AppFont.regular(
                                  14,
                                  color: AppColor.appBlack(),
                                )),
                          filters != null
                              ? InkWell(
                                  onTap: () {
                                    _showBottomSheet(context, this.hideMenu);
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                          Util.getTranslated(
                                                  context, 'filter') +
                                              ' :',
                                          style: AppFont.regular(
                                            14,
                                            color: AppColor.appBlack(),
                                          )),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      if (!hideMenu)
                                        selectedCategories.length > 1 ||
                                                (selectedSubCategories.length >
                                                        0 ||
                                                    selectedTags.length > 0)
                                            ? Image.asset(
                                                Constants.ASSET_IMAGES +
                                                    "active_filter_icon.png")
                                            : Image.asset(
                                                Constants.ASSET_IMAGES +
                                                    "inactive_filter_icon.png",
                                                width: 30,
                                                height: 30,
                                              ),
                                      if (hideMenu)
                                        selectedCategories.length > 0 ||
                                                (selectedSubCategories.length >
                                                        0 ||
                                                    selectedTags.length > 0)
                                            ? Image.asset(
                                                Constants.ASSET_IMAGES +
                                                    "active_filter_icon.png")
                                            : Image.asset(
                                                Constants.ASSET_IMAGES +
                                                    "inactive_filter_icon.png",
                                                width: 30,
                                                height: 30,
                                              )
                                    ],
                                  ),
                                )
                              : Container()
                        ],
                      ),
                      if (!hideMenu && this.total != null)
                        SizedBox(
                          height: 10,
                        ),
                      if (!hideMenu && this.total != null) divider(context),
                      SizedBox(height: 16),
                      productGridView(context),
                      SizedBox(height: 16)
                    ],
                    controller: _sc,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget appBarIcon(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      // color: Colors.white,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          Constants.ASSET_IMAGES + "s_behn_meyer_logo.png",
        ),
      ),
    );
  }

  Widget searchWrapper(BuildContext context) {
    return InkWell(
      onTap: () {
        Util.printInfo('tap Search');
      },
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Constants.ASSET_IMAGES + "search_icon.png",
              width: 30,
              height: 30,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    _searchTextField(context),
                    searchField.text.length > 0
                        ? clearButton(context)
                        : Container(
                            height: 0.0,
                          )
                  ],
                ),
              ),
            ),

            // closeButton(context)
          ],
        ),
      ),
    );
  }

  Widget _searchTextField(BuildContext context) {
    return TextField(
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        Util.printInfo("SEARCH KEYWORD: $value");
        setState(() {
          page = 1;
          noMore = false;
          hideMenu = true;
          selectedCategories = [];
          products.clear();
          filterList = [];
          filters = null;
          selectedSubCategories = [];
          selectedTags = [];
          selectFilterTags = [];
        });
        _searchData(page, value,
            selectedCategories: selectedCategories.join(','),
            selectedSubCategories: selectedSubCategories.join(','),
            tags: selectedTags.join(','));
        getFilters(
            selectedCategories.join(','),
            selectedSubCategories.join(','),
            selectedTags.join(','),
            searchField.text);
      },
      maxLines: 1,
      onChanged: (text) {
        setState(() {
          print(text);
        });
      },
      controller: searchField,
      decoration: InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintStyle: AppFont.regular(24,
            color: AppColor.appHintTextGreyColor(),
            decoration: TextDecoration.none),
        hintText: Util.getTranslated(context, "product_search_hint_text"),
      ),
      style: AppFont.regular(
        24,
        color: AppColor.appBlack(),
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget clearButton(BuildContext context) {
    return Container(
      child: ClipOval(
        child: Material(
          color: Colors.black.withOpacity(0.3), // button color
          child: InkWell(
            splashColor: Colors.black.withOpacity(0.3), // inkwell color
            child: SizedBox(
                width: 20,
                height: 20,
                child:
                    Icon(Icons.close_rounded, size: 15, color: Colors.white)),
            onTap: () {
              Util.printInfo('clear search text');
              searchField.clear();
              setState(() {
                page = 1;
                noMore = false;
                hideMenu = false;
                products.clear();
                categories.clear();
                _selectedMenuIndex = 0;
                selectedCategories = [];
                selectedSubCategories = [];
                selectedTags = [];
                selectFilterTags = [];
              });
              _getCategories();
            },
          ),
        ),
      ),
    );
  }

  Widget _horizontalMenuListView(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 40,
      width: screenWidth - 90,
      child: ScrollablePositionedList.separated(
        itemCount: categories == null ? 0 : categories.length,
        itemScrollController: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: ClampingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          var item = categories[index];
          return _buildMenu(context, index, item);
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(width: 10);
        },
      ),
    );
  }

  Widget backButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ClipOval(
          child: Material(
            color: AppColor.appBlue(), // button color
            child: InkWell(
              splashColor: Colors.black.withOpacity(0.5), // inkwell color
              child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(
                      isBackward
                          ? Icons.arrow_back_ios_rounded
                          : Icons.arrow_forward_ios_rounded,
                      size: 20,
                      color: Colors.white)),
              onTap: () {
                Util.printInfo("tap next");

                if (isBackward) {
                  _scrollController.scrollTo(
                      index: 0,
                      duration: Duration(seconds: 1),
                      curve: Curves.linear);
                  setState(() {
                    isBackward = false;
                  });
                } else {
                  _scrollController.scrollTo(
                      index: categories.length - 1,
                      duration: Duration(seconds: 1),
                      curve: Curves.linear);
                  setState(() {
                    isBackward = true;
                  });
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context, int index, ProductCategory category) {
    return GestureDetector(
      onTap: () {
        Util.printInfo('tap menu ${category.name}');
        // if (index != categories.length-1) {
        _scrollController.scrollTo(
            index: index,
            duration: Duration(seconds: 1),
            curve: Curves.easeInOutCubic);
        // }
        setState(() {
          ProductCategory item = categories[index];
          selectedCategory = item.id;
          _selectedMenuIndex = index;
          if (_selectedMenuIndex == categories.length - 1) {
            isBackward = true;
          } else {
            isBackward = false;
          }
        });

        onTapMenu(selectedCategory);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color:
                _selectedMenuIndex == index ? AppColor.appBlue() : Colors.white,
            border: Border.all(
              color: Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(25)),
        child: Text(category.name,
            style: _selectedMenuIndex == index
                ? AppFont.bold(16,
                    color: Colors.white, decoration: TextDecoration.none)
                : AppFont.bold(16,
                    color: AppColor.productMenuUnselectedBlue(),
                    decoration: TextDecoration.none)),
      ),
    );
  }

  Widget productGridView(BuildContext context) {
    var gridWidth = ((MediaQuery.of(context).size.width - 60)) / 2;
    var gridHeight = gridWidth * 1.05;
    return Container(
        child: CustomScrollView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      slivers: [
        new SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(

              ///no.of items in the horizontal axis
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: gridWidth / gridHeight),
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            var item = products[index];
            return InkWell(
              onTap: () {
                Util.printInfo("tap grid: ${item.id}");
                Navigator.pushNamed(context, MyRoute.productDetailsRoute,
                    arguments: PageArguments(item.id));
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.grey, width: 1)),
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    DisplayImage(
                      item.imageUrl,
                      'placeholder_3.png',
                      width: double.infinity,
                      height: gridWidth * 0.65,
                      boxFit: BoxFit.contain,
                    ),
                    SizedBox(height: 3),
                    productTextView(item.name),
                    // Text(item.name, style: AppFont.bold(14, color: AppColor.appBlack(), decoration: TextDecoration.none)),
                  ],
                ),
              ),
            );
          }, childCount: products.length),
        ),
        new SliverToBoxAdapter(
          child: _buildProgressIndicator(),
        ),
      ],
    ));
  }

  // Widget gridContent(BuildContext context){
  //   return GridView.builder(
  //         shrinkWrap: true,
  //         physics: NeverScrollableScrollPhysics(),
  //         itemCount: products.length,
  //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //           mainAxisSpacing: 20,
  //           crossAxisSpacing: 20,
  //           crossAxisCount: 2,
  //           // childAspectRatio: 1.5
  //         ),
  //         itemBuilder: (BuildContext context, int index) {
  //           var item = products[index];
  //           return
  //           InkWell(
  //             onTap: (){
  //               Util.printInfo("tap grid: ${item.id}");
  //               Navigator.pushNamed(context, MyRoute.productDetailsRoute, arguments: PageArguments(item.id));
  //             },
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.all(Radius.circular(10)),
  //                 border: Border.all(color: Colors.grey, width: 1)
  //                 ),
  //               // width: double.infinity,
  //               // height: double.infinity,
  //               child: Column(
  //                 children: [
  //                   DisplayImage(item.imageUrl,'image_placeholder.png', width: double.infinity, height: 110, boxFit: BoxFit.contain,),
  //                   SizedBox(height: 2),
  //                   productTextView(item.name),
  //                   // Text(item.name, style: AppFont.bold(14, color: AppColor.appBlack(), decoration: TextDecoration.none)),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  // }

  Widget productTextView(String name) {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Text(
        name,
        style: AppFont.bold(14,
            color: AppColor.appBlack(), decoration: TextDecoration.none),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget divider(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 1,
      width: screenWidth,
      color: AppColor.appLightGreyColor(),
    );
  }

  void _getCategories() async {
    List tcategory = [];
    await fetchCategories(context).then((value) {
      value.forEach((item) {
        tcategory.add(item);
      });
    }, onError: (error) {
      if (error is DioError) {
        if (error.response != null) {
          if (error.response.data != null) {
            ErrorDTO errorDTO = ErrorDTO.fromJson(error.response.data);
            Util.showAlertDialog(
                context,
                Util.getTranslated(context, 'alert_dialog_title_error_text'),
                errorDTO.message);
          } else {
            Util.showAlertDialog(
                context,
                Util.getTranslated(context, 'alert_dialog_title_error_text'),
                Util.getTranslated(
                    context, 'general_alert_message_error_response'));
          }
        } else {
          Util.showAlertDialog(
              context,
              Util.getTranslated(context, 'alert_dialog_title_error_text'),
              Util.getTranslated(
                  context, 'general_alert_message_error_response'));
        }
      } else {
        Util.showAlertDialog(
            context,
            Util.getTranslated(context, 'alert_dialog_title_error_text'),
            Util.getTranslated(
                context, 'general_alert_message_error_response_2'));
      }
      Util.printInfo('FETCH PRODUCT CATEGORY ERROR: $error');
    });

    setState(() {
      categories.addAll(tcategory);
      if (categories.length > 0) {
        var firstCat = categories.first;
        if (firstCat is ProductCategory) {
          selectedCategory = firstCat.id;
        }
      }
    });

    if (selectedCategory != null) {
      checkCategoryFilters(selectedCategory);
      _getMoreData(page, selectedCategories.join(','));
      getFilters(selectedCategories.join(','), selectedSubCategories.join(','),
          selectedTags.join(','), searchField.text);
    } else {
      Util.showAlertDialog(
          context,
          Util.getTranslated(context, 'alert_dialog_title_error_text'),
          Util.getTranslated(
              context, 'general_alert_message_error_response_2'));
      Util.printInfo('Selected Category is null');
    }
  }

  void onTapMenu(int selectedCategory) async {
    setState(() {
      page = 1;
      noMore = false;
      products.clear();
      selectedCategories = [];
      selectedSubCategories = [];
      selectedTags = [];
      selectFilterTags = [];
      filterList = [];
      filters = null;
    });

    checkCategoryFilters(selectedCategory);
    if (searchField.text.length > 0) {
      _searchData(page, searchField.text,
          selectedCategories: selectedCategories.join(','),
          selectedSubCategories: selectedSubCategories.join(','),
          tags: selectedTags.join(','));
      getFilters(selectedCategories.join(','), selectedSubCategories.join(','),
          selectedTags.join(','), searchField.text);
    } else {
      _getMoreData(page, selectedCategories.join(','));
      getFilters(selectedCategories.join(','), selectedSubCategories.join(','),
          selectedTags.join(','), searchField.text);
    }
  }

  void _searchData(int index, String keyword,
      {String selectedCategories,
      String selectedSubCategories,
      String tags}) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      List tList = [];
      await searchProducts(context, keyword, page, size,
              catId: selectedCategories,
              subCatId: selectedSubCategories,
              tag: tags)
          .then((value) {
        if (value != null) {
          if (value.total != null) {
            this.total = value.total;
          }

          if (value.result.length > 0) {
            value.result.forEach((product) {
              tList.add(product);
            });

            setState(() {
              Util.printInfo('RESULT LENGTH: ${value.result.length}');
              noMore = value.result.length < size;
            });
          } else {
            setState(() {
              noMore = true;
            });
          }
        } else {
          setState(() {
            noMore = true;
          });
        }
      }, onError: (error) {
        if (error is DioError) {
          if (error.response != null) {
            if (error.response.data != null) {
              ErrorDTO errorDTO = ErrorDTO.fromJson(error.response.data);
              Util.showAlertDialog(
                  context,
                  Util.getTranslated(context, 'alert_dialog_title_error_text'),
                  errorDTO.message);
            } else {
              Util.showAlertDialog(
                  context,
                  Util.getTranslated(context, 'alert_dialog_title_error_text'),
                  Util.getTranslated(
                      context, 'general_alert_message_error_response'));
            }
          } else {
            Util.showAlertDialog(
                context,
                Util.getTranslated(context, 'alert_dialog_title_error_text'),
                Util.getTranslated(
                    context, 'general_alert_message_error_response'));
          }
        } else {
          Util.showAlertDialog(
              context,
              Util.getTranslated(context, 'alert_dialog_title_error_text'),
              Util.getTranslated(
                  context, 'general_alert_message_error_response_2'));
        }
        Util.printInfo('FETCH PRODUCTS ERROR: $error');
      });

      setState(() {
        isLoading = false;
        products.addAll(tList);
        Util.printInfo('set page add');
        page++;
      });
    }
  }

  void _getMoreData(int index, String selectedCategory,
      {String selectedSubCategories, String tags}) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      List tList = [];
      await fetchProducts(context, selectedCategory, page, size,
              subCatId: selectedSubCategories, tag: tags)
          .then((value) {
        if (value != null) {
          if (value.total != null) {
            this.total = value.total;
          }

          if (value.result.length > 0) {
            value.result.forEach((product) {
              tList.add(product);
            });
            setState(() {
              Util.printInfo('RESULT LENGTH: ${value.result.length}');
              noMore = value.result.length < size;
            });
          } else {
            setState(() {
              noMore = true;
            });
          }
        } else {
          setState(() {
            noMore = true;
          });
        }
      }, onError: (error) {
        if (error is DioError) {
          if (error.response != null) {
            if (error.response.data != null) {
              ErrorDTO errorDTO = ErrorDTO.fromJson(error.response.data);
              Util.showAlertDialog(
                  context,
                  Util.getTranslated(context, 'alert_dialog_title_error_text'),
                  errorDTO.message);
            } else {
              Util.showAlertDialog(
                  context,
                  Util.getTranslated(context, 'alert_dialog_title_error_text'),
                  Util.getTranslated(
                      context, 'general_alert_message_error_response'));
            }
          } else {
            Util.showAlertDialog(
                context,
                Util.getTranslated(context, 'alert_dialog_title_error_text'),
                Util.getTranslated(
                    context, 'general_alert_message_error_response'));
          }
        } else {
          Util.showAlertDialog(
              context,
              Util.getTranslated(context, 'alert_dialog_title_error_text'),
              Util.getTranslated(
                  context, 'general_alert_message_error_response_2'));
        }
        Util.printInfo('FETCH PRODUCTS ERROR: $error');
      });

      setState(() {
        isLoading = false;
        products.addAll(tList);
        Util.printInfo('set page add');
        page++;
      });
    }
  }

  void checkCategoryFilters(int catId) {
    if (selectedCategories.length > 0) {
      var isFound = false;
      selectedCategories.forEach((element) {
        if (element.id == catId) {
          isFound = true;
        }
      });

      if (!isFound) {
        selectedCategories.add(catId);
      }
    } else {
      selectedCategories.add(catId);
    }
  }

  void getFilters(String selectedCat, String selectedSubCat, String tags,
      String keyword) async {
    await fetchProductFilters(
            context, selectedCat, selectedSubCat, tags, keyword)
        .then((value) {
      if (value != null) {
        setState(() {
          filterList = formatFilterList(value);
          filters = value;
        });
      }
    }, onError: (error) {
      if (error is DioError) {
        if (error.response != null) {
          if (error.response.data != null) {
            ErrorDTO errorDTO = ErrorDTO.fromJson(error.response.data);
            Util.showAlertDialog(
                context,
                Util.getTranslated(context, 'alert_dialog_title_error_text'),
                errorDTO.message);
          } else {
            Util.showAlertDialog(
                context,
                Util.getTranslated(context, 'alert_dialog_title_error_text'),
                Util.getTranslated(
                    context, 'general_alert_message_error_response'));
          }
        } else {
          Util.showAlertDialog(
              context,
              Util.getTranslated(context, 'alert_dialog_title_error_text'),
              Util.getTranslated(
                  context, 'general_alert_message_error_response'));
        }
      } else {
        Util.showAlertDialog(
            context,
            Util.getTranslated(context, 'alert_dialog_title_error_text'),
            Util.getTranslated(
                context, 'general_alert_message_error_response_2'));
      }
      Util.printInfo('FETCH PRODUCT FILTER ERROR: $error');
    });
  }

  Future<void> _showBottomSheet(BuildContext context, bool hidMenu) async {
    var isFirstTime = true;
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_product_filter);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext modalContext, StateSetter setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) => SafeArea(
                child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: filterList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                            padding: EdgeInsets.all(16),
                            height: 50,
                            child: Stack(
                              alignment: AlignmentDirectional.centerStart,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Text(Util.getTranslated(context, 'filter'), style: AppFont.semibold(16, color: AppColor.appBlack()),),
                                    if (hidMenu)
                                      selectedCategories.length > 0 ||
                                              selectedSubCategories.length >
                                                  0 ||
                                              selectedTags.length > 0
                                          ? InkWell(
                                              onTap: () {
                                                clearFilter(setModalState,
                                                    hideMenu, filterList);
                                              },
                                              child: Text(
                                                  Util.getTranslated(
                                                      context, 'clear_btn'),
                                                  style: AppFont.regular(14,
                                                      color:
                                                          AppColor.appGreen())),
                                            )
                                          : Container(
                                              width: 35,
                                            ),
                                    if (!hidMenu)
                                      selectedSubCategories.length > 0 ||
                                              selectedTags.length > 0
                                          ? InkWell(
                                              onTap: () {
                                                clearFilter(setModalState,
                                                    hideMenu, filterList);
                                              },
                                              child: Text(
                                                  Util.getTranslated(
                                                      context, 'clear_btn'),
                                                  style: AppFont.regular(14,
                                                      color:
                                                          AppColor.appGreen())),
                                            )
                                          : Container(
                                              width: 35,
                                            ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      Util.getTranslated(context, 'filter'),
                                      style: AppFont.semibold(16,
                                          color: AppColor.appBlack()),
                                    ),
                                  ],
                                ),
                              ],
                            ));
                      }
                      var item = filterList[index - 1];
                      if (isFirstTime && index == 1) {
                        item.selected = true;
                      }
                      return ExpansionTile(
                        initiallyExpanded: item.selected,
                        title: Text(
                          item.name,
                          style: AppFont.bold(16, color: AppColor.appBlue()),
                        ),
                        subtitle: showSelected(
                            context,
                            item,
                            selectedCategories,
                            selectedSubCategories,
                            selectedTags),
                        trailing: item.selected
                            ? Icon(
                                Icons.keyboard_arrow_up_rounded,
                                color: AppColor.appBlue(),
                              )
                            : Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColor.appBlue(),
                              ),
                        children: [
                          if (item.code != 'subCategories' &&
                              item.code != 'categories')
                            filterTagsWrapper(
                                context, setModalState, item, item.data, index),
                          if (item.code == 'subCategories')
                            filterSubCategoryWrapper(
                                context, setModalState, item, item.data, index),
                          if (item.code == 'categories')
                            filterCategoryWrapper(
                                context, setModalState, item, item.data, index)
                          // if (item.code != 'subCategories' && item.code != 'categories') for (var i = 0; i < item.data.length; i++) filterTagsItemCard(context, setModalState, item.data[i], index-1, i) ,
                          // if (item.code == 'subCategories') for (var i = 0; i < item.data.length; i++) filterSubCategoryItemCard(context, setModalState, item.data[i], index-1, i) ,
                          // if (item.code == 'categories') for (var i = 0; i < item.data.length; i++) filterCategoryItemCard(context, setModalState, item.data[i], index-1, i) ,
                        ],
                        onExpansionChanged: (bool expanded) {
                          setModalState(() {
                            isFirstTime = false;
                            headerChange(setModalState, expanded, index - 1);
                            item.selected = expanded;
                          });
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 50,
                  margin: EdgeInsets.only(bottom: 10),
                  child: viewButton(context),
                )
              ],
            )),
          );
        });
      },
    ).whenComplete(() {
      if (!hidMenu) {
        if (selectedSubCategories.length > 0 || selectedTags.length > 0) {
          setState(() {
            page = 1;
            noMore = false;
            products.clear();
            hasFilter = true;
          });
          _getMoreData(page, selectedCategories.join(','),
              selectedSubCategories: selectedSubCategories.join(','),
              tags: selectedTags.join(','));
        } else {
          Util.printInfo('no selected');
          if (hasFilter) {
            setState(() {
              page = 1;
              noMore = false;
              products.clear();
              hasFilter = false;
            });
            _getMoreData(page, selectedCategories.join(','),
                selectedSubCategories: selectedSubCategories.join(','),
                tags: selectedTags.join(','));
          }
        }
      } else {
        if (selectedCategories.length > 0 ||
            selectedSubCategories.length > 0 ||
            selectedTags.length > 0) {
          setState(() {
            page = 1;
            noMore = false;
            products.clear();
            hasFilter = true;
          });
          _searchData(page, searchField.text,
              selectedCategories: selectedCategories.join(','),
              selectedSubCategories: selectedSubCategories.join(','),
              tags: selectedTags.join(','));
        } else {
          if (hasFilter) {
            setState(() {
              page = 1;
              noMore = false;
              products.clear();
              hasFilter = false;
            });
            _searchData(page, searchField.text,
                selectedCategories: selectedCategories.join(','),
                selectedSubCategories: selectedSubCategories.join(','),
                tags: selectedTags.join(','));
          }
        }
      }
      setState(() {
        filterList.forEach((element) {
          element.viewMore = false;
          element.selected = false;
        });
      });
    });
  }

  String checkFilterCategory(List<dynamic> selectedCategories) {
    List cList = [];
    if (selectedCategories.length > 0) {
      if (filters.categories.length > 0) {
        for (var i = 0; i < selectedCategories.length; i++) {
          for (var j = 0; j < filters.categories.length; j++) {
            if (selectedCategories[i] == filters.categories[j].id) {
              cList.add(filters.categories[j].name);
              break;
            }
          }
        }

        if (cList.length > 0) {
          return cList.join(', ');
        } else {
          return '';
        }
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  String checkFilterSubCategory(List<dynamic> selectedSubCategories) {
    List cList = [];
    if (selectedSubCategories.length > 0) {
      if (filters.subCategories.length > 0) {
        for (var i = 0; i < selectedSubCategories.length; i++) {
          for (var j = 0; j < filters.subCategories.length; j++) {
            if (selectedSubCategories[i] == filters.subCategories[j].id) {
              cList.add(filters.subCategories[j].name);
              break;
            }
          }
        }

        if (cList.length > 0) {
          return cList.join(', ');
        } else {
          return '';
        }
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  String checkFilterTags(
      List<dynamic> selectedTags, String code, List<ProductData> tags) {
    if (selectedTags.length > 0) {
      List cList = [];

      for (var i = 0; i < selectedTags.length; i++) {
        if (selectedTags[i]['code'] == code) {
          for (var j = 0; j < tags.length; j++) {
            if (selectedTags[i]['id'] == tags[j].id) {
              cList.add(selectedTags[i]['name']);
              break;
            }
          }
        }
      }

      if (cList.length > 0) {
        return cList.join(', ');
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  Widget showSelected(
      BuildContext context,
      ProductFilterData item,
      List<dynamic> selectedCats,
      List<dynamic> selectedSubCats,
      List<dynamic> selectedTags) {
    if (item.code == 'categories') {
      if (item.selected) {
        return null;
      } else {
        if (checkFilterCategory(selectedCategories).length > 0) {
          return Text(checkFilterCategory(selectedCats),
              style:
                  AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
              maxLines: 2);
        } else {
          return Text(
            item.subTitle,
            style: AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
          );
        }
      }
    } else if (item.code == 'subCategories') {
      if (item.selected) {
        return null;
      } else {
        if (checkFilterSubCategory(selectedSubCategories).length > 0) {
          return Text(checkFilterSubCategory(selectedSubCats),
              style:
                  AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
              maxLines: 2);
        } else {
          return Text(
            item.subTitle,
            style: AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
          );
        }
      }
    } else {
      // Other Tags
      if (item.code == 'activityTag') {
        if (item.selected) {
          return null;
        } else {
          if (checkFilterTags(selectFilterTags, item.code, filters.activityTags)
                  .length >
              0) {
            return Text(
                checkFilterTags(
                    selectFilterTags, item.code, filters.activityTags),
                style:
                    AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
                maxLines: 2);
          } else {
            return Text(
              item.subTitle,
              style:
                  AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
            );
          }
        }
      } else if (item.code == 'characteristicsTags') {
        if (item.selected) {
          return null;
        } else {
          if (checkFilterTags(
                      selectFilterTags, item.code, filters.characteristicsTags)
                  .length >
              0) {
            return Text(
                checkFilterTags(
                    selectFilterTags, item.code, filters.characteristicsTags),
                style:
                    AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
                maxLines: 2);
          } else {
            return Text(
              item.subTitle,
              style:
                  AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
            );
          }
        }
      } else if (item.code == 'cropsTags') {
        if (item.selected) {
          return null;
        } else {
          if (checkFilterTags(selectFilterTags, item.code, filters.cropsTags)
                  .length >
              0) {
            return Text(
                checkFilterTags(selectFilterTags, item.code, filters.cropsTags),
                style:
                    AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
                maxLines: 2);
          } else {
            return Text(
              item.subTitle,
              style:
                  AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
            );
          }
        }
      } else if (item.code == 'compositionTags') {
        if (item.selected) {
          return null;
        } else {
          if (checkFilterTags(
                      selectFilterTags, item.code, filters.compositionTags)
                  .length >
              0) {
            return Text(
                checkFilterTags(
                    selectFilterTags, item.code, filters.compositionTags),
                style:
                    AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
                maxLines: 2);
          } else {
            return Text(
              item.subTitle,
              style:
                  AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
            );
          }
        }
      } else if (item.code == 'phenologicalPhaseTags') {
        if (item.selected) {
          return null;
        } else {
          if (checkFilterTags(selectFilterTags, item.code,
                      filters.phenologicalPhaseTags)
                  .length >
              0) {
            return Text(
                checkFilterTags(
                    selectFilterTags, item.code, filters.phenologicalPhaseTags),
                style:
                    AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
                maxLines: 2);
          } else {
            return Text(
              item.subTitle,
              style:
                  AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
            );
          }
        }
      } else if (item.code == 'formulationTags') {
        if (item.selected) {
          return null;
        } else {
          if (checkFilterTags(
                      selectFilterTags, item.code, filters.formulationTags)
                  .length >
              0) {
            return Text(
                checkFilterTags(
                    selectFilterTags, item.code, filters.formulationTags),
                style:
                    AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
                maxLines: 2);
          } else {
            return Text(
              item.subTitle,
              style:
                  AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
            );
          }
        }
      } else if (item.code == 'activeIngredientTags') {
        if (item.selected) {
          return null;
        } else {
          if (checkFilterTags(
                      selectFilterTags, item.code, filters.activeIngredientTags)
                  .length >
              0) {
            return Text(
                checkFilterTags(
                    selectFilterTags, item.code, filters.activeIngredientTags),
                style:
                    AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
                maxLines: 2);
          } else {
            return Text(
              item.subTitle,
              style:
                  AppFont.regular(14, color: AppColor.appHintTextGreyColor()),
            );
          }
        }
      } else {
        return null;
      }
    }
  }

  Widget viewButton(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth - 20,
      child: TextButton(
        onPressed: () {
          onView(context);
        },
        child: Text(Util.getTranslated(context, "view_btn")),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: AppColor.appBlue(),
          textStyle: screenWidth <= 375
              ? AppFont.bold(12, color: Colors.white)
              : AppFont.bold(14, color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  void onView(BuildContext context) {
    Navigator.pop(context);
  }

  Widget filterSubCategoryWrapper(
      BuildContext context,
      StateSetter setModalState,
      ProductFilterData data,
      List<ProductSubCategory> subs,
      int index) {
    if (subs.length > 5 && data.viewMore == false) {
      return Column(
        children: [
          for (var i = 0; i < 6; i++)
            if (i == 5)
              filterViewMore(context, setModalState, data)
            else
              filterSubCategoryItemCard(
                  context, setModalState, subs[i], index - 1, i)
        ],
      );
    } else {
      return Column(
        children: [
          for (var i = 0; i < subs.length; i++)
            filterSubCategoryItemCard(
                context, setModalState, subs[i], index - 1, i)
        ],
      );
    }
  }

  Widget filterCategoryWrapper(BuildContext context, StateSetter setModalState,
      ProductFilterData data, List<ProductCategory> cats, int index) {
    if (cats.length > 5 && data.viewMore == false) {
      return Column(
        children: [
          for (var i = 0; i < 5; i++)
            if (i == 4)
              filterViewMore(context, setModalState, data)
            else
              filterCategoryItemCard(
                  context, setModalState, cats[i], index - 1, i)
        ],
      );
    } else {
      return Column(
        children: [
          for (var i = 0; i < cats.length; i++)
            filterCategoryItemCard(
                context, setModalState, cats[i], index - 1, i)
        ],
      );
    }
  }

  Widget filterTagsWrapper(BuildContext context, StateSetter setModalState,
      ProductFilterData data, List<ProductData> tags, int index) {
    if (tags.length > 5 && data.viewMore == false) {
      return Column(
        children: [
          for (var i = 0; i < 6; i++)
            if (i == 5)
              filterViewMore(context, setModalState, data)
            else
              filterTagsItemCard(
                  context, setModalState, data, tags[i], index - 1, i)
        ],
      );
    } else {
      return Column(
        children: [
          for (var i = 0; i < tags.length; i++)
            filterTagsItemCard(
                context, setModalState, data, tags[i], index - 1, i)
        ],
      );
    }
  }

  Widget filterCategoryItemCard(BuildContext context, StateSetter setModalState,
      ProductCategory data, int header, int index) {
    return Container(
      height: 60,
      child: CheckboxListTile(
          activeColor: AppColor.appBlue(),
          title: Text(
            data.name,
            style: AppFont.regular(
              14,
              color: AppColor.appBlack(),
            ),
          ),
          value: data.selected,
          onChanged: (selected) {
            // Util.printInfo('SELECTED: $selected');
            setModalState(() {
              if (selected) {
                if (selectedCategories.length > 0) {
                  var isFound = false;
                  selectedCategories.forEach((element) {
                    if (element == data.id) {
                      isFound = true;
                    }
                  });

                  if (!isFound) {
                    selectedCategories.add(data.id);
                  }
                } else {
                  selectedCategories.add(data.id);
                }
              } else {
                if (selectedCategories.length > 0) {
                  var isFound = false;
                  var deleteIndex;
                  for (var index = 0;
                      index < selectedCategories.length;
                      ++index) {
                    if (selectedCategories[index] == data.id) {
                      isFound = true;
                      deleteIndex = index;
                      break;
                    }
                  }
                  if (isFound) {
                    selectedCategories.removeAt(deleteIndex);
                  }
                }
              }
              itemChange(setModalState, selected, header, index);
            });
          }),
    );
  }

  Widget filterSubCategoryItemCard(
      BuildContext context,
      StateSetter setModalState,
      ProductSubCategory data,
      int header,
      int index) {
    return Container(
      height: 60,
      child: CheckboxListTile(
          activeColor: AppColor.appBlue(),
          title: Text(
            data.name,
            style: AppFont.regular(
              14,
              color: AppColor.appBlack(),
            ),
          ),
          value: data.selected,
          onChanged: (selected) {
            // Util.printInfo('SELECTED: $selected');
            setModalState(() {
              if (selected) {
                if (selectedSubCategories.length > 0) {
                  var isFound = false;
                  selectedSubCategories.forEach((element) {
                    if (element == data.id) {
                      isFound = true;
                    }
                  });

                  if (!isFound) {
                    selectedSubCategories.add(data.id);
                  }
                } else {
                  selectedSubCategories.add(data.id);
                }
              } else {
                if (selectedSubCategories.length > 0) {
                  var isFound = false;
                  var deleteIndex;
                  for (var index = 0;
                      index < selectedSubCategories.length;
                      ++index) {
                    if (selectedSubCategories[index] == data.id) {
                      isFound = true;
                      deleteIndex = index;
                      break;
                    }
                  }
                  if (isFound) {
                    selectedSubCategories.removeAt(deleteIndex);
                  }
                }
              }
              itemChange(setModalState, selected, header, index);
            });
          }),
    );
  }

  Widget filterViewMore(
      BuildContext context, StateSetter setModalState, ProductFilterData data) {
    return InkWell(
        onTap: () {
          setModalState(() {
            data.viewMore = true;
          });
        },
        child: Container(
          height: 50,
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(Util.getTranslated(context, "view_more_btn"),
                style: AppFont.regular(
                  14,
                  color: AppColor.appBlue(),
                  decoration: TextDecoration.underline,
                )),
          ),
        ));
  }

  Widget filterTagsItemCard(BuildContext context, StateSetter setModalState,
      ProductFilterData item, ProductData data, int header, int index) {
    return Container(
      height: 60,
      child: CheckboxListTile(
          activeColor: AppColor.appBlue(),
          title: Text(
            data.info.name,
            style: AppFont.regular(
              14,
              color: AppColor.appBlack(),
            ),
          ),
          value: data.selected,
          onChanged: (selected) {
            // Util.printInfo('SELECTED: $selected');
            setModalState(() {
              if (selected) {
                if (selectedTags.length > 0) {
                  var isFound = false;
                  selectedTags.forEach((element) {
                    if (element == data.id) {
                      isFound = true;
                    }
                  });

                  if (!isFound) {
                    selectedTags.add(data.id);
                    selectFilterTags.add({
                      'id': data.id,
                      'code': item.code,
                      'name': data.info.name
                    });
                  }
                } else {
                  selectedTags.add(data.id);
                  selectFilterTags.add({
                    'id': data.id,
                    'code': item.code,
                    'name': data.info.name
                  });
                }
              } else {
                if (selectedTags.length > 0) {
                  var isFound = false;
                  var deleteIndex;
                  for (var index = 0; index < selectedTags.length; ++index) {
                    if (selectedTags[index] == data.id) {
                      isFound = true;
                      deleteIndex = index;
                      break;
                    }
                  }
                  if (isFound) {
                    selectedTags.removeAt(deleteIndex);
                    selectFilterTags.removeAt(deleteIndex);
                  }
                }
              }
              itemChange(setModalState, selected, header, index);
            });
          }),
    );
  }

  void itemChange(StateSetter setModalState, bool val, int header, int index) {
    setModalState(() {
      filterList[header].data[index].selected = val;
    });
  }

  void headerChange(StateSetter setModalState, bool val, int header) {
    setModalState(() {
      filterList[header].selected = val;
    });
  }

  void clearFilter(
      StateSetter setModalState, bool hideMenu, List<dynamic> filterList) {
    if (hideMenu) {
      selectedCategories = [];
      selectedSubCategories = [];
      selectedTags = [];
      selectFilterTags = [];
      setModalState(() {
        for (var index = 0; index < filterList.length; ++index) {
          if (filterList[index].data != null) {
            for (var j = 0; j < filterList[index].data.length; ++j) {
              filterList[index].data[j].selected = false;
            }
          }
        }
      });
      setState(() {
        page = 1;
        noMore = false;
        products.clear();
        hasFilter = false;
      });
      _searchData(page, searchField.text);
    } else {
      selectedSubCategories = [];
      selectedTags = [];
      selectFilterTags = [];
      setModalState(() {
        for (var index = 0; index < filterList.length; ++index) {
          if (filterList[index].data != null) {
            for (var j = 0; j < filterList[index].data.length; ++j) {
              filterList[index].data[j].selected = false;
            }
          }
        }
      });

      setState(() {
        page = 1;
        noMore = false;
        products.clear();
        hasFilter = false;
      });
      _getMoreData(page, selectedCategories.join(','));
    }
  }

  List formatFilterList(ProductFilter filter) {
    List tList = [];
    if (filter.categories != null) {
      tList.add(new ProductFilterData(
          name: Util.getTranslated(context, "filter_category"),
          subTitle: Util.getTranslated(context, "filter_all_category"),
          code: 'categories',
          data: filter.categories,
          selected: false,
          viewMore: false));
    }
    if (filter.subCategories != null) {
      tList.add(new ProductFilterData(
          name: Util.getTranslated(context, "filter_subcategory"),
          subTitle: Util.getTranslated(context, "filter_all_subcategory"),
          code: 'subCategories',
          data: filter.subCategories,
          selected: false,
          viewMore: false));
    }
    if (filter.activityTags != null) {
      tList.add(new ProductFilterData(
          name: Util.getTranslated(context, "filter_activity"),
          subTitle: Util.getTranslated(context, "filter_all_activity"),
          code: 'activityTag',
          data: filter.activityTags,
          selected: false,
          viewMore: false));
    }
    if (filter.characteristicsTags != null) {
      tList.add(new ProductFilterData(
          name: Util.getTranslated(context, "filter_characteristic"),
          subTitle: Util.getTranslated(context, "filter_all_characteristic"),
          code: 'characteristicsTags',
          data: filter.characteristicsTags,
          selected: false,
          viewMore: false));
    }
    if (filter.cropsTags != null) {
      tList.add(new ProductFilterData(
          name: Util.getTranslated(context, "filter_crops"),
          subTitle: Util.getTranslated(context, "filter_all_crops"),
          code: 'cropsTags',
          data: filter.cropsTags,
          selected: false,
          viewMore: false));
    }
    if (filter.compositionTags != null) {
      tList.add(new ProductFilterData(
          name: Util.getTranslated(context, "filter_composition"),
          subTitle: Util.getTranslated(context, "filter_all_composition"),
          code: 'compositionTags',
          data: filter.compositionTags,
          selected: false,
          viewMore: false));
    }
    if (filter.phenologicalPhaseTags != null) {
      tList.add(new ProductFilterData(
          name: Util.getTranslated(context, "filter_phenological"),
          subTitle: Util.getTranslated(context, "filter_all_phenological"),
          code: 'phenologicalPhaseTags',
          data: filter.phenologicalPhaseTags,
          selected: false,
          viewMore: false));
    }
    if (filter.formulationTags != null) {
      tList.add(new ProductFilterData(
          name: Util.getTranslated(context, "filter_formulation"),
          subTitle: Util.getTranslated(context, "filter_all_formulation"),
          code: 'formulationTags',
          data: filter.formulationTags,
          selected: false,
          viewMore: false));
    }
    if (filter.activeIngredientTags != null) {
      tList.add(new ProductFilterData(
          name: Util.getTranslated(context, "filter_active_ingre"),
          subTitle: Util.getTranslated(context, "filter_all_active_ingre"),
          code: 'activeIngredientTags',
          data: filter.activeIngredientTags,
          selected: false,
          viewMore: false));
    }
    return tList;
  }
}
