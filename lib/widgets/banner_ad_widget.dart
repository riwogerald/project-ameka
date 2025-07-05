import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_manager.dart';

class BannerAdWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdManager>(
      builder: (context, adManager, child) {
        if (!adManager.isBannerAdReady || adManager.bannerAd == null) {
          return SizedBox.shrink();
        }
        
        return Container(
          alignment: Alignment.center,
          width: adManager.bannerAd!.size.width.toDouble(),
          height: adManager.bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: adManager.bannerAd!),
        );
      },
    );
  }
}