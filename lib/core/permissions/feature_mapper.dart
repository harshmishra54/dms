import 'feature_access.dart';

class FeatureMapper {
  static const Map<int, FeatureAccess> map = {
    // ===== CORE MASTER DATA =====
    400: FeatureAccess.distributerDetails,
    401: FeatureAccess.cfaDetails,
    402: FeatureAccess.farmerDetails,
    403: FeatureAccess.retailerDetails,

    // ===== ORDER & RETURN =====
    404: FeatureAccess.orderDisRet,
    405: FeatureAccess.returnDistRet,
    406: FeatureAccess.orderTsm,
    407: FeatureAccess.returnTsm,

    // ===== HR & POLICY =====
    408: FeatureAccess.leaveManagement,
    409: FeatureAccess.creditLimit,
    410: FeatureAccess.meeting,
    411: FeatureAccess.attendance,

    // ===== ROUTE & ACTIVITY =====
    412: FeatureAccess.routeOrder,
    413: FeatureAccess.routeMeetingReport,

    // ===== EXPENSE =====
    414: FeatureAccess.expense,
    415: FeatureAccess.expenseLimit,
    416: FeatureAccess.holidays,

    // ===== PRODUCT & SCHEME =====
    417: FeatureAccess.focusProduct,
    418: FeatureAccess.loyaltyScheme,

    // ===== REWARDS =====
    419: FeatureAccess.rewards,
    420: FeatureAccess.rewardsClaim,
    421: FeatureAccess.loyaltyHistory,
    422: FeatureAccess.schemeBanner,
    423: FeatureAccess.spinWheelConfiguration,
    424: FeatureAccess.globalPrize,
    425: FeatureAccess.luckyDraw,
    428: FeatureAccess.luckyDrawHistory,

    // ===== MARKETING =====
    429: FeatureAccess.marketingDashboard,
    430: FeatureAccess.marketingReports,

    // ===== COUNTERFEIT =====
    431: FeatureAccess.counterfeitDashboard,
    432: FeatureAccess.counterfeits,

    // ===== SECURITY =====
    433: FeatureAccess.geofencing,

    // ===== SALES =====
    434: FeatureAccess.distributerTargetsAndSales,

    // ===== ORDER ON BEHALF =====
    435: FeatureAccess.placeOrderOnBehalfOfDistributer,
    436: FeatureAccess.placeOrderOnBehalfOfRetailer,

    // ===== CREDIT =====
    437: FeatureAccess.requestCreditLimitForDistributer,

    // ===== DEMO & STOCK =====
    438: FeatureAccess.planProductDemo,
    439: FeatureAccess.viewStockOfCfa,
    440: FeatureAccess.viewStockOfDistributer,

    // ===== FARMER =====
    441: FeatureAccess.takeFarmersDetails,

    // ===== AI =====
    442: FeatureAccess.productRecommendation,

    // ===== APPROVAL & BEAT PLAN =====
    445: FeatureAccess.approveDistributerRetailer,
    450: FeatureAccess.beatPlan,
    451: FeatureAccess.beatPlanSelf,

    // ===== REGISTRATION =====
    452: FeatureAccess.registerDistributer,
    453: FeatureAccess.registerRetailer,
    454: FeatureAccess.registerFarmer,

    // ===== FINAL APPROVAL =====
    455: FeatureAccess.approveDistributer,
    456: FeatureAccess.approveRetailer,
    457: FeatureAccess.orderHistory,
    458: FeatureAccess.DistributerOrder,
    459: FeatureAccess.RetailerOrder,
    460: FeatureAccess.distributerReturn,
    461: FeatureAccess.retailerReturn,
  };

  static FeatureAccess? fromId(int featureId) {
    return map[featureId];
  }
}
