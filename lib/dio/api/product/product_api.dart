import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:behn_meyer_flutter/models/product/product_article.dart';
import 'package:behn_meyer_flutter/models/product/product_category.dart';
import 'package:behn_meyer_flutter/models/product/product_desc.dart';
import 'package:behn_meyer_flutter/models/product/product_filter.dart';
import 'package:behn_meyer_flutter/models/product/product_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ProductApi extends DioRepo {
  ProductApi(BuildContext context){
    dioContext = context;
  }

  Future<List<ProductCategory>> fetchProductCategoryList() async {
    try {
      Response response = await mDio.get('products/categories');
      return (response.data as List)
          .map((x) => ProductCategory.fromJson(x))
          .toList();
    } catch (e) {
      throw e;
    }
  }

  Future<ProductItemWrapper> fetchProductList(String categoryId, int page, int size, {String subCategoryId, String tags}) async {
    Map<String, dynamic>  params = {};
    params['size'] = size;
    params['page'] = page;

    if (categoryId != null && categoryId.length > 0){
      params['categoryId'] = categoryId;
    }

    if (subCategoryId != null && subCategoryId.length > 0){
      params['subCategoryId'] = subCategoryId;
    }

    if (tags != null && tags.length > 0){
      params['tags'] = tags;
    }
  
    try {
      Response response = await mDio.get('v2/products', queryParameters: params);
      return ProductItemWrapper.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }

  Future<ProductItemWrapper> searchProduct(String keyword, int page, int size, {String categoryId, String subCategoryId, String tags}) async {
    Map<String, dynamic>  params = {};
    params['size'] = size;
    params['page'] = page;
    if (keyword != null && keyword.length > 0){
      params['keyword'] = keyword;
    }

    if (categoryId != null && categoryId.length > 0){
      params['categoryId'] = categoryId;
    }

    if (subCategoryId != null && subCategoryId.length > 0){
      params['subCategoryId'] = subCategoryId;
    }

    if (tags != null && tags.length > 0){
      params['tags'] = tags;
    }
    try {
      Response response = await mDio.get('v2/products', queryParameters: params);
      return ProductItemWrapper.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }

  Future<ProductDesc> getProductDetail(int productId) async {
     try {
      Response response = await mDio.get('products/$productId');
      return ProductDesc.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }

  Future<List<ProductArticle>> getProductArticle(int productId, int page, int size) async {
    try {
      Response response = await mDio.get('products/$productId/articles?page=$page&size=$size');
      return (response.data as List)
          .map((x) => ProductArticle.fromJson(x))
          .toList();
    } catch (e) {
      throw e;
    }
  }

  Future<ProductFilter> getProductFilter(String categoryId, String subCategoryId, String tags, String keyword) async {
    Map<String, dynamic>  params = {};
    if (categoryId != null && categoryId.length > 0){
      params['categoryId'] = categoryId;
    }

    if (subCategoryId != null && subCategoryId.length > 0){
      params['subCategoryId'] = subCategoryId;
    }

    if (tags != null && tags.length > 0){
      params['tags'] = tags;
    }

    if (keyword != null && keyword.length > 0){
      params['keyword'] = keyword;
    }

    try {
      Response response = await mDio.get('products/filters', queryParameters: params);
      return ProductFilter.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }




}