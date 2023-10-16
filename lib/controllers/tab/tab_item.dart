import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:flutter/material.dart';

enum TabItem { home, product, news, dealer, settings, qna }

const Map<TabItem, String> tabName = {
  TabItem.home: 'tab_item_home',
  TabItem.product: 'tab_item_product',
  TabItem.news: 'tab_item_news',
  TabItem.dealer: 'tab_item_dealer',
  TabItem.settings: 'tab_item_settings',
  TabItem.qna: 'tab_item_qna'
};

Map<TabItem, Image> tabIconSelected = {
  TabItem.home: Image.asset(
    Constants.ASSET_IMAGES + 'active_home_icon.png',
    width: 22,
    fit: BoxFit.contain,
  ),
  TabItem.product: Image.asset(
    Constants.ASSET_IMAGES + 'active_product_icon.png',
    width: 22,
    fit: BoxFit.contain,
  ),
  TabItem.news: Image.asset(
    Constants.ASSET_IMAGES + 'active_news_icon.png',
    width: 22,
    fit: BoxFit.contain,
  ),
  TabItem.dealer: Image.asset(
    Constants.ASSET_IMAGES + 'active_dealer_icon.png',
    width: 22,
    fit: BoxFit.contain,
  ),
  TabItem.settings: Image.asset(
    Constants.ASSET_IMAGES + 'active_settings_icon.png',
    width: 22,
    fit: BoxFit.contain,
  ),
  TabItem.qna: Image.asset(
    Constants.ASSET_IMAGES + 'active_Q_A_icon.png',
    width: 22,
    fit: BoxFit.contain,
  )
};

Map<TabItem, Image> tabIconUnselected = {
  TabItem.home: Image.asset(
    Constants.ASSET_IMAGES + 'inactive_home_icon.png',
    width: 22,
    fit: BoxFit.contain,
  ),
  TabItem.product: Image.asset(
    Constants.ASSET_IMAGES + 'inactive_product_icon.png',
    width: 22,
    fit: BoxFit.contain,
  ),
  TabItem.news: Image.asset(
    Constants.ASSET_IMAGES + 'inactive_news_icon.png',
    width: 22,
    fit: BoxFit.contain,
  ),
  TabItem.dealer: Image.asset(
    Constants.ASSET_IMAGES + 'inactive_dealer_icon.png',
    width: 22,
    fit: BoxFit.contain,
  ),
  TabItem.settings: Image.asset(
    Constants.ASSET_IMAGES + 'inactive_settings_icon.png',
    width: 22,
    fit: BoxFit.contain,
  ),
  TabItem.qna: Image.asset(
    Constants.ASSET_IMAGES + 'inactive_Q_A_icon.png',
    width: 22,
    fit: BoxFit.contain,
  )
};
