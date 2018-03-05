//
//  PXReviewViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 27/2/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

final class PXReviewViewModel: NSObject {
    
    static let ERROR_DELTA = 0.001
    public static var CUSTOMER_ID = ""
    
    var preference: CheckoutPreference?
    var paymentData: PaymentData!
    var paymentOptionSelected: PaymentMethodOption
    var discount: DiscountCoupon?
    
    var reviewScreenPreference: ReviewScreenPreference!
    
    var summaryComponent: SummaryComponent!
    
    public init(checkoutPreference: CheckoutPreference, paymentData: PaymentData, paymentOptionSelected: PaymentMethodOption, discount: DiscountCoupon? = nil, reviewScreenPreference: ReviewScreenPreference = ReviewScreenPreference()) {
        PXReviewViewModel.CUSTOMER_ID = ""
        self.preference = checkoutPreference
        self.paymentData = paymentData
        self.discount = discount
        self.paymentOptionSelected = paymentOptionSelected
        self.reviewScreenPreference = reviewScreenPreference
        super.init()
        let screenWidth = UIScreen.main.bounds.width
        self.summaryComponent = SummaryComponent(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 0), summary: self.getValidSummary(amount: checkoutPreference.getAmount()), paymentData: self.paymentData, totalAmount:(self.preference?.getAmount())!)
    }
}

// MARK: - Logic.
extension PXReviewViewModel {
    
    // Logic.
    func isPaymentMethodSelectedCard() -> Bool {
        return self.paymentData.hasPaymentMethod() && self.paymentData.getPaymentMethod()!.isCard
    }
    
    func isPaymentMethodSelected() -> Bool {
        return paymentData.hasPaymentMethod()
    }
    
    func isUserLogged() -> Bool {
        // TODO: For footer. Ver lógica de terms and conditions.
        return !String.isNullOrEmpty(MercadoPagoContext.payerAccessToken())
    }
    
    func shouldShowInstallmentSummary() -> Bool {
        return isPaymentMethodSelectedCard() && self.paymentData.getPaymentMethod()!.paymentTypeId != "debit_card" && paymentData.hasPayerCost() && paymentData.getPayerCost()!.installments != 1
    }
    
    func shouldDisplayNoRate() -> Bool {
        return self.paymentData.hasPayerCost() && !self.paymentData.getPayerCost()!.hasInstallmentsRate() && self.paymentData.getPayerCost()!.installments != 1
    }
    
    func hasPayerCostAddionalInfo() -> Bool {
        return self.paymentData.hasPayerCost() && self.paymentData.getPayerCost()!.getCFTValue() != nil && self.paymentData.getPayerCost()!.installments != 1
    }
    
    func hasConfirmAdditionalInfo() -> Bool {
        return hasPayerCostAddionalInfo() || needUnlockCardComponent()
    }
    
    func needUnlockCardComponent() -> Bool {
        return getUnlockLink() != nil
    }
}

// MARK: - Getters
extension PXReviewViewModel {
    
    func getTotalAmount() -> Double {
        if let payerCost = paymentData.getPayerCost() {
            return payerCost.totalAmount
        }
        if MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable(), let discount = paymentData.discount {
            return discount.newAmount()
        }
        return self.preference!.getAmount()
    }
    
    func getUnlockLink() -> URL? {
        let path = MercadoPago.getBundle()!.path(forResource: "UnlockCardLinks", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: path!)
        let site = MercadoPagoContext.getSite()
        guard let issuerID = self.paymentData.getIssuer()?._id else {
            return nil
        }
        let searchString: String = site + "_" + "\(issuerID)"
        
        if let link = dictionary?.value(forKey: searchString) as? String {
            return URL(string:link)
        }
        
        return nil
    }
    
    func getClearPaymentData() -> PaymentData {
        let newPaymentData: PaymentData = paymentData
        newPaymentData.clearCollectedData()
        return newPaymentData
    }
    
    func getFloatingConfirmButtonHeight() -> CGFloat {
        return 82
    }
    
    func getFloatingConfirmButtonViewFrame() -> CGRect {
        let height = self.getFloatingConfirmButtonHeight()
        let width = UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: UIScreen.main.bounds.maxY - height, width: width, height: height)
        return frame
    }
    
    func getValidSummary(amount: Double) -> Summary {
        var summary: Summary
        guard let choPref = self.preference else {
            return Summary(details: [:])
        }
        
        // TODO: Check Double type precision.
        if abs(amount - self.reviewScreenPreference.getSummaryTotalAmount()) <= PXReviewViewModel.ERROR_DELTA {
            summary = Summary(details: self.reviewScreenPreference.details)
            if self.reviewScreenPreference.details[SummaryType.PRODUCT]?.details.count == 0 { //Si solo le cambio el titulo a Productos
                summary.addAmountDetail(detail: SummaryItemDetail(amount: choPref.getAmount()), type: SummaryType.PRODUCT)
            }
        } else {
            summary = getDefaultSummary()
            if self.reviewScreenPreference.details[SummaryType.PRODUCT]?.details.count == 0 { //Si solo le cambio el titulo a Productos
                if let title = self.reviewScreenPreference.details[SummaryType.PRODUCT]?.title {
                    summary.updateTitle(type: SummaryType.PRODUCT, oneWordTitle:title)
                }
            }
        }
        
        if let discount = self.paymentData.discount {
            let discountAmountDetail = SummaryItemDetail(name: discount.description, amount: Double(discount.coupon_amount)!)
            
            if summary.details[SummaryType.DISCOUNT] != nil {
                summary.addAmountDetail(detail: discountAmountDetail, type: SummaryType.DISCOUNT)
            } else {
                let discountSummaryDetail = SummaryDetail(title: self.reviewScreenPreference.summaryTitles[SummaryType.DISCOUNT]!, detail: discountAmountDetail)
                summary.addSummaryDetail(summaryDetail:discountSummaryDetail, type: SummaryType.DISCOUNT)
            }
            summary.details[SummaryType.DISCOUNT]?.titleColor = ThemeManager.shared.getTheme().highlightedLabelTintColor()
            summary.details[SummaryType.DISCOUNT]?.amountColor = ThemeManager.shared.getTheme().highlightedLabelTintColor()
        }
        if let payerCost = self.paymentData.payerCost {
            let interest = payerCost.totalAmount - amount
            if interest > 0 {
                let interestAmountDetail = SummaryItemDetail(amount: interest)
                if summary.details[SummaryType.CHARGE] != nil {
                    summary.addAmountDetail(detail: interestAmountDetail, type: SummaryType.CHARGE)
                } else {
                    let interestSummaryDetail = SummaryDetail(title: self.reviewScreenPreference.summaryTitles[SummaryType.CHARGE]!, detail: interestAmountDetail)
                    summary.addSummaryDetail(summaryDetail:interestSummaryDetail, type: SummaryType.CHARGE)
                }
            }
        }
        if let disclaimer = self.reviewScreenPreference.disclaimer {
            summary.disclaimer = disclaimer
            summary.disclaimerColor = self.reviewScreenPreference.disclaimerColor
        }
        return summary
    }
    
    func getDefaultSummary() -> Summary {
        guard let choPref = self.preference else {
            return Summary(details: [:])
        }
        let productSummaryDetail = SummaryDetail(title: self.reviewScreenPreference.summaryTitles[SummaryType.PRODUCT]!, detail: SummaryItemDetail(amount: choPref.getAmount()))
        return Summary(details:[SummaryType.PRODUCT: productSummaryDetail])
    }
}

// MARK: - Components builders.
extension PXReviewViewModel {
    
    func buildPaymentMethodComponent(withAction:PXComponentAction?) -> PXPaymentMethodComponent {
        
        let pm = paymentData!.getPaymentMethod()!
        let issuer = paymentData!.getIssuer()
        let paymentMethodName = pm.name ?? ""
        let paymentMethodIssuerName = issuer?.name ?? "Otro"
        
        let image = buildPaymentMethodIcon(paymentMethod: pm)
        var title = NSAttributedString(string: "")
        var subtitle: NSAttributedString? = nil
        var accreditationTime: NSAttributedString? = nil
        var action = withAction
        
        if pm.isCard {
            if let lastFourDigits = (paymentData.token?.lastFourDigits) {
                let text = paymentMethodName + " " + "terminada en ".localized + lastFourDigits
                title = text.toAttributedString()
            }
        } else {
            title = paymentMethodName.toAttributedString()
            accreditationTime = Utils.getAccreditationTimeAttributedString(from: paymentOptionSelected.getComment())
        }
        
        // TODO: Localize "Otro"
        if paymentMethodIssuerName.lowercased() != paymentMethodName.lowercased() && paymentMethodIssuerName != "Otro".localized {
            subtitle = paymentMethodIssuerName.toAttributedString()
        }
        
        if !self.reviewScreenPreference.isChangeMethodOptionEnabled() {
            action = nil
        }
        
        let bodyProps = PXPaymentMethodProps(paymentMethodIcon: image, title: title, subtitle: subtitle, descriptionTitle: nil, descriptionDetail: accreditationTime, disclaimer: nil, action: action, backgroundColor: UIColor.pxWarmGray)
        
        return PXPaymentMethodComponent(props: bodyProps)
    }
    
    fileprivate func buildPaymentMethodIcon(paymentMethod: PaymentMethod) -> UIImage? {
        let defaultColor = paymentMethod.paymentTypeId == PaymentTypeId.ACCOUNT_MONEY.rawValue && paymentMethod.paymentTypeId != PaymentTypeId.PAYMENT_METHOD_PLUGIN.rawValue
        var paymentMethodImage: UIImage? =  MercadoPago.getImageFor(paymentMethod, forCell: true)
//        var paymentMethodImage: UIImage? =  MercadoPago.getImageForPaymentMethod(withDescription: paymentMethod._id, defaultColor: defaultColor)
        // Retrieve image for payment plugin or any external payment method.
        if paymentMethod.paymentTypeId == PaymentTypeId.PAYMENT_METHOD_PLUGIN.rawValue {
            paymentMethodImage = paymentMethod.getImageForExtenalPaymentMethod()
        }
        return paymentMethodImage
    }
}

// MARK: - Custom cells.
// TODO: Remove.
extension PXReviewViewModel {
    
    // Custom cells.
    func numberOfCustomAdditionalCells() -> Int {
        if !Array.isNullOrEmpty(reviewScreenPreference.additionalInfoCells) {
            return reviewScreenPreference.additionalInfoCells.count
        }
        return 0
    }
    
    func numberOfCustomItemCells() -> Int {
        if hasCustomItemCells() {
            return reviewScreenPreference.customItemCells.count
        }
        return 0
    }
    
    func hasCustomItemCells() -> Bool {
        return !Array.isNullOrEmpty(reviewScreenPreference.customItemCells)
    }
}
