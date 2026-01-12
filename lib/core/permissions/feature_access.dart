enum FeatureAccess {
  // ===== CORE MASTER DATA =====
  distributerDetails,            // 400
  cfaDetails,                    // 401
  farmerDetails,                 // 402
  retailerDetails,               // 403

  // ===== ORDER & RETURN =====
  orderDisRet,                   // 404
  returnDistRet,                 // 405
  orderTsm,                      // 406
  returnTsm,                     // 407

  // ===== HR & POLICY =====
  leaveManagement,               // 408
  creditLimit,                   // 409
  meeting,                       // 410
  attendance,                    // 411

  // ===== ROUTE & ACTIVITY =====
  routeOrder,                    // 412
  routeMeetingReport,            // 413

  // ===== EXPENSE =====
  expense,                       // 414
  expenseLimit,                  // 415
  holidays,                      // 416

  // ===== PRODUCT & SCHEME =====
  focusProduct,                  // 417
  loyaltyScheme,                 // 418

  // ===== REWARDS =====
  rewards,                       // 419
  rewardsClaim,                  // 420
  loyaltyHistory,                // 421
  schemeBanner,                  // 422
  spinWheelConfiguration,        // 423
  globalPrize,                   // 424
  luckyDraw,                     // 425
  luckyDrawHistory,              // 428

  // ===== MARKETING =====
  marketingDashboard,            // 429
  marketingReports,              // 430

  // ===== COUNTERFEIT =====
  counterfeitDashboard,          // 431
  counterfeits,                  // 432

  // ===== SECURITY =====
  geofencing,                    // 433

  // ===== SALES =====
  distributerTargetsAndSales,    // 434

  // ===== ORDER ON BEHALF =====
  placeOrderOnBehalfOfDistributer, // 435
  placeOrderOnBehalfOfRetailer,    // 436

  // ===== CREDIT =====
  requestCreditLimitForDistributer, // 437

  // ===== DEMO & STOCK =====
  planProductDemo,               // 438
  viewStockOfCfa,                // 439
  viewStockOfDistributer,         // 440

  // ===== FARMER =====
  takeFarmersDetails,            // 441

  // ===== AI =====
  productRecommendation,        // 442

  // ===== APPROVAL & BEAT PLAN =====
  approveDistributerRetailer,    // 445
  beatPlan,                      // 450
  beatPlanSelf,                  // 451

  // ===== REGISTRATION =====
  registerDistributer,           // 452
  registerRetailer,              // 453
  registerFarmer,                // 454

  // ===== FINAL APPROVAL =====
  approveDistributer,            // 455
  approveRetailer,               // 456
  orderHistory,
  DistributerOrder,
  RetailerOrder,
  distributerReturn,
  retailerReturn,
}
